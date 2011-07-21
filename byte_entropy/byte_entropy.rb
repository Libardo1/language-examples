#!/usr/bin/env ruby
# Entropy takes two parameters: block size, and elem size. Every possible
# value of elem in block is given a probability and an entropy.
# TODO: custom probability?
# e.g. address probability, ascii probability.

# note: endianness shouldn't really matter as this is a differential calc
module ByteEntropy
  BLOCK_SIZE = 1024

  def self.log_n(base, num)
	  Math.log(num) / Math.log(base)
  end

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

  def self.buf_entropy(buf)
    # NOTE: larger elem sizes are not statistically significant
    #        BLOCK_SIZE     = 0.0
    #        BLOCK_SIZE / 2 = 0.06666667
    #        BLOCK_SIZE / 4 = 0.14285714
    max_elem = BLOCK_SIZE / 8
    max_elem = buf.length if max_elem > buf.length

    ent = {}
    i = 1
    while i <= max_elem
      ent[i] = entropy_elem(buf, i)
      i *= 2
    end
    ent
  end

=begin rdoc
Given a file handle, return ...
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
