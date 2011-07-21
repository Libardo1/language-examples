#!/usr/bin/env ruby
# Calculate the 'byte entropy' for blocks in a file.
# This differs from the standard byte entropy algorithm in that it generates
# an entropy value for multibyte strings. Each block is considered a
# collection of byte strings. The byte strings are powers of 2 from 1 to
# (block size / 8).
# Thus, for a block size of 256, the following values are calculated:
#   1, 2, 4, 8, 16, 32
# This can be used to detect the regularity of multibyte strings, for example
# memory addresses.

=begin rdoc
Namespace for byte entropy methods
=end
module ByteEntropy

=begin rdoc
Hard-coded block size. In an application, this would be controlled by a
config option.
=end
  BLOCK_SIZE = 1024

=begin rdoc
Return logarithm of 'num' to base 'base'. Allows base to vary, which is
important when using multiple element sizes.
=end
  def self.log_n(base, num)
	  Math.log(num) / Math.log(base)
  end

=begin rdoc
Return an array of all distinct elements in buf. This just partitions buf into
elem_size-sized Strings.

Note that endianness is not a concern as this is a differential calculation.
=end
  def self.buf_elements(buf, elem_size)
    elems = []
    idx = 0 
    max_idx = buf.length
    while idx < max_idx
      elems << buf[idx,elem_size].unpack('C*').join('')
      idx += elem_size
    end
    elems
  end

=begin rdoc
Return the entropy of buf for elem_size. An elem_size of 1 returns the byte
entropy; larger sizes are 'multibyte entropy'.

NOTE: this can be improved by varying the offset at which the buffer is 
split into elements.
=end
  def self.entropy_elem(buf, elem_size)
    ent = 0.0
    base = 256 * elem_size                # of all possible combinations
    elems = buf_elements(buf, elem_size)
    total = elems.count.to_f

    counters = {}
    elems.each do |b|
      counters[b] ||= 0
      counters[b] += 1.0
    end

    counters.each do |byte, count|
      p_x = count / total
      ent -= (p_x * log_n(base, p_x)) if p_x != 0
    end

    ent
  end

=begin rdoc
Return the entropy stats of a buffer for all statistically significant element 
sizes. The return value is a Hash where the key is the element size, and the
value is the entropy for that element size.

Note that an element size which is too close to the size of 'buf' will not
be statistically significant. The top powers of two are invariant:
   BLOCK_SIZE     = 0.0
   BLOCK_SIZE / 2 = 0.06666667
   BLOCK_SIZE / 4 = 0.14285714
Therefore, the largest element size is BLOCK_SIZE / 8.
=end
  def self.buf_entropy(buf)
    max_elem = BLOCK_SIZE < buf.length ? BLOCK_SIZE : buf.length
    max_elem /= 8

    ent = {}
    i = 1
    while i <= max_elem
      ent[i] = entropy_elem(buf, i)
      i *= 2
    end
    ent
  end

=begin rdoc
Given a file handle, return an array of entropy stats for each block in the 
file.
=end
  def self.entropy(f)
    ent = []
    while (buf = f.read(BLOCK_SIZE)) do
      ent << buf_entropy(buf)
    end
    ent
  end

end

if __FILE__ == $0
  ByteEntropy.entropy(ARGF).each_with_index do |h, idx|
    ent_arr = []
    h.keys.sort.each { |k| ent_arr << "%d: %0.8f" % [k, h[k]] }
    puts "%08X: %s" % [idx * ByteEntropy::BLOCK_SIZE, ent_arr.join(', ') ]
  end
end
