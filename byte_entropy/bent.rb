#!/usr/bin/env ruby

require 'stringio'
require 'byte_entropy'

require 'ostruct'
require 'optparse'

require 'descriptive_statistics'
# Graph: different block entropy based on offset
#        min, max entropy per block-size in file [error-bar]

module ByteEntropyApp

  def self.get_options(args)
    options = OpenStruct.new
    options.offset = 0
    options.json = nil
    options.delim = nil
    options.range = nil
    options.intervals = false
    options.max_block_size = nil

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: #{File.basename $0} "
      opts.separator "Options:"
      opts.on('-a', '--all-intervals', 'Calc entropy from 1 to block_size') { 
        options.intervals = true
      }
      opts.on('-d', '--delim char', 'Output in delimited format') { |c| 
        options.delim = c
      }
      opts.on('-j', '--json', 'Serialize to JSON') { options.json = true }
      opts.on('-m', '--max int', 'Max block size [0 = file size]') { |n| 
        options.max_block_size = Integer(n)
      }
      opts.on('-o', '--offset int', 'Offset in file [default: 0]') { |n| 
        options.offset = Integer(n)
      }
      opts.on_tail('-h', '--help', 'Show help screen') { puts opts; ext 1 }
    end

    opts.parse! args
    options
  end

  def self.calc_block_size(f, opts)
    sz = opts.max_block_size
    sz ||= 2 ** (Math.log(f.size)/Math.log(2)).floor
    sz == 0 ? d.size : sz
  end

  def self.calc_interval_entropy(f, bs, interval)
    ent = ByteEntropy.entropy(f, bs, interval)
    f.rewind
    ent
  end

  def self.calc_entropy(buf, opts)
    range = opts.range ? (opts.offset + opts.range) : -1
    f = StringIO.new(buf[opts.offset..range])

    sz = calc_block_size(f, opts)

    h = {}
    # TODO: print warning if num_ivl > 64
    num_ivl = opts.intervals ? sz : 1
    num_ivl.times { |off| h[off] = calc_interval_entropy(f, sz, off) }
    h
  end

  #def self.gen_entropy_stats(h)
#Array.number,sum,mean,median,variance,standard_deviation, percentile(70)
# TODO: data structure which includes byte entropy stats
#       should include average for each block and such
#ent.each_with_index do |h, idx|
#            #h.keys.sort.each { |k| ent_arr << "%d: %0.8f" % [k, h[k]] }
  #end

  def self.print_entropy_stats(arr)
    arr.each_with_index do |h, idx|
      ent_arr = []
      h.keys.sort.each { |k| ent_arr << "%d: %0.8f" % [k, h[k]] }
      # TODO: collect stats
      #Array.number,sum,mean,median,variance,standard_deviation, percentile(70)
      puts "%d: %s" % [idx, ent_arr.join(', ') ]
      # TODO: how to specify block
      #puts "%08X: %s" % [idx * blk, ent_arr.join(', ') ]
    end
  end

  def self.print_entropy(ent)
    ent.keys.sort.each do |iv|
      puts "INTERVAL #{iv} =================================================="
      print_entropy_stats ent[iv]
    end
  end

=begin
puts '-----------------------------------------------------------------'
puts "BLOCK SIZE #{sz} OFFSET #{offset}"
ent = BinaryObject.entropy(f, sz, offset)
ent_arr = []
ent.each_with_index do |h, idx|
            #h.keys.sort.each { |k| ent_arr << "%d: %0.8f" % [k, h[k]] }
            #puts "%08X: %s" % [idx * BinaryObject::ByteEntropy::BLOCK_SIZE, 
            #                   ent_arr.join(', ') ]
          end
=end
end

if __FILE__ == $0
  opts = ByteEntropyApp.get_options(ARGV)

  ByteEntropyApp.print_entropy ByteEntropyApp.calc_entropy( ARGF.read, opts )
end
