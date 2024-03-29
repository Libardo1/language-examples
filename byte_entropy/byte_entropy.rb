#!/usr/bin/env ruby
# Calculate the 'byte entropy' for blocks in a file.
# This differs from the standard byte entropy algorithm in that it generates
# an entropy value for multibyte strings. Each block is considered a
# collection of byte strings. The byte strings are powers of 2 from 1 to
# block_size.
# This can be used to detect the regularity of multibyte strings, for example
# memory addresses.

=begin rdoc
Inner namespace for methods that support entropy() and buf_entropy() 
methods.
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
Previous power of 2. This returns the closest power of 2 equal to or less
than 'num'. 63 -> 32. 64 -> 64. 127 -> 64. And so forth.
  def self.prev_power_2(num)
    2 ** log_n(2, num).floor
  end
=end

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

NOTE: this can be improved by varying the offset at which the buffer is split 
into elements.
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
Return the entropy stats of a buffer for all power-of-two element sizes. The
return value is a Hash where the key is the element size, and the value is the 
entropy for that element size.
=end
  def self.buf_entropy(buf, block_size=ByteEntropy::BLOCK_SIZE)
    ent = {}
    i = 1
    while i < block_size  # entropy of block_size will always be 0
      ent[i] = ByteEntropy.entropy_elem(buf, i)
      i *= 2
    end
    ent
  end

=begin rdoc
Given a file handle, return an array of entropy stats for each block in the 
file.
=end
  def self.entropy(f, block_size=ByteEntropy::BLOCK_SIZE, offset=0)
    ent = []
    f.seek(offset) if offset > 0
    while (buf = f.read(block_size)) do
      ent << buf_entropy(buf, block_size)
    end
    ent
  end

  def self.calc_interval_entropy(f, bs, interval)
    ent = entropy(f, bs, interval)
    f.rewind
    ent
  end

  def self.interval_entropy(f, bs, num_intervals=1)
    h = {}
    num_intervals.times { |off| h[off] = calc_interval_entropy(f, bs, off) }
    h
  end

end

# ----------------------------------------------------------------------
if __FILE__ == $0
  ByteEntropy.entropy(ARGF).each_with_index do |h, idx|
    ent_arr = []
    h.keys.sort.each { |k| ent_arr << "%d: %0.8f" % [k, h[k]] }
    puts "%08X: %s" % [idx * ByteEntropy::BLOCK_SIZE, 
                       ent_arr.join(', ') ]
  end
end
