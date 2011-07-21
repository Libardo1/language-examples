#!/usr/bin/env ruby
# Entropy takes two parameters: block size, and elem size. Every possible
# value of elem in block is given a probability and an entropy.
# TODO: custom probability?
# e.g. address probability, ascii probability.

# note: endianness shouldn't really matter as this is a differential calc
module ByteEntropy
  MAX_WIN = 16
  FMT_STR = { 1 => '',
              2 => '',
              4 => '',
              8 => '',
             16 => '',
             32 => '',
             :default => ''       # when the others do not apply
            }

  ELEM_SIZE = 1
  # note: probability of a byte is 1/256 as they have equal probability
  P_BYTE = 1.0 / (ELEM_SIZE * 256.0)

  class EntropyStats < Hash
    def initialize(*args)
      super

      # Create buckets for different window sizes
      i = 1
      # each window gets count, sum?
      #while (i <= MAX_WIN) do |x| 
      #  self[x] = {:calc => 0, :sum => 0}
      #  i *= 2
      #end
    end

    def append_window(win, buf)
      elem = 0
      while elem < win do
        # val = unpack
        elem += win
      end
    end

    def append_bytes(buf)
      # For each window (1, 2, 4, 8, 16)
      keys.sort.each do |win|
        append_win(win, buf)

      end
    end

    def fmt_str(win)
      FMT_STR.fetch(win, DEFAULT_FMT_STR)
    end
  end

  def self.log2(num)
	  Math.log(num) / Math.log(2)
  end

  def self.log_n(base, num)
	  Math.log(num) / Math.log(base)
  end

  def self.h_elem(buf, elem_size)
    ent = 0.0
    bytes = buf.unpack('C*')
    base = 256 * elem_size

    counters = {}
    total = 0.0
    bytes.each do |b|
      counters[b] ||= 0
      counters[b] += 1.0
      total += 1.0
    end

    counters.each do |byte, count|
      p_x = count / total
      ent -= (p_x * log_n(base, p_x)) if p_x > 0
    end

    ent
  end

  def self.h(buf)
    h_elem(buf, 1)
  end

=begin rdoc
Given a file handle, return ...
=end
  def self.entropy(f)
    # read block
    while (buf = f.read(256)) do
      # get block entropy
      # store block id!
      ent = h(buf)
      puts ent.inspect
    end
  end

  def old_ent(f)
    stats = EntropyStats.new

    while (buf = f.read(MAX_WIN)) do
      stats.append_bytes(buf)

      #bytes = buf.unpack 'C*'
      #lines << "%08X:%-48s |%-16s|" % [ 
      #             offset, 
      #             bytes.map { |b| " %02X" % b },
      #             bytes.map { |b| b.chr =~ /[[:print:]]/ ? b.chr : '.' }.join('') 
      #         ]
      #offset += 16
    end

  end
end

if __FILE__ == $0
  ByteEntropy.entropy(ARGF)
  #entropy(ARGF).each { |line| puts line }
end
