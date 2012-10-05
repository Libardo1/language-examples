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
    options.range = nil
    options.intervals = false
    options.min_block_size = 1
    options.max_block_size = nil

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: #{File.basename $0} "
      opts.separator "Options:"
      opts.on('-a', '--all-intervals', 'Calc entropy from 1 to block_size') { 
        options.intervals = true
      }
      opts.on('-M', '--min int', 'Min block size [default: 1]') { |n| 
        options.min_block_size = Integer(n)
      }
      opts.on('-m', '--max int', 'Max block size [default: file size]') { |n| 
        options.max_block_size = Integer(n)
      }
      opts.on('-n', '--num int', 'Number of bytes [default: to EOF]') { |n| 
        options.length = Integer(n)
      }
      opts.on('-o', '--offset int', 'Offset in file [default: 0]') { |n| 
        options.offset = Integer(n)
      }
      opts.on_tail('-h', '--help', 'Show help screen') { puts opts; ext 1 }
    end

    opts.parse! args
    options
  end

  def self.log2(num)
    (Math.log(num) / Math.log(2)).floor
  end

  #def self.gen_entropy_stats(h)
#Array.number,sum,mean,median,variance,standard_deviation, percentile(70)
# TODO: data structure which includes byte entropy stats
#       should include average for each block and such
#ent.each_with_index do |h, idx|
#            #h.keys.sort.each { |k| ent_arr << "%d: %0.8f" % [k, h[k]] }
  #end

  def self.calc_interval_entropy(f, bs, interval)
    ent = BinaryObject.entropy(f, bs, interval)
    f.rewind
    ent
  end

  def self.calc_entropy(buf, opts)
    range = opts.range ? (opts.offset + opts.range) : -1
    f = StringIO.new(buf[opts.offset..range])

    # TODO: less than f.size? this gets triangular at some point. pow/2 ?
    opts.max_block_size = f.size
    #opts.max_block_size ||= log2(f.size)
    #block_sizes = (opts.min_block_size..opts.max_block_size).map { |x| 2 ** x }
    block_sizes = [opts.max_block_size]

    h = {}
    block_sizes.each do |blk|
      if opts.intervals
        h[blk] = []
        blk.times { |off| h[blk][off] = calc_interval_entropy(f, blk, off) }
      else
        h[blk] =  calc_interval_entropy(f, blk, 0)
      end
    end
    h
  end

  def self.print_entropy(ent)
    # for each block size
    ent.each do |blk, coll|
      puts "BLOCK SIZE #{blk} ========================================="
      if coll.kind_of? Hash
        # print intervals
      else
        coll.each_with_index do |h, idx|
          ent_arr = []
          h.keys.sort.each { |k| ent_arr << "%d: %0.8f" % [k, h[k]] }
#Array.number,sum,mean,median,variance,standard_deviation, percentile(70)
          # TODO: collect stats
          puts "%08X: %s" % [idx * blk, ent_arr.join(', ') ]
        end
        # TODO print stats, collect stats

      end

      # TODO: calc stats
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
end

if __FILE__ == $0
  opts = ByteEntropyApp.get_options(ARGV)

  ByteEntropyApp.print_entropy ByteEntropyApp.calc_entropy( ARGF.read, opts )
end
