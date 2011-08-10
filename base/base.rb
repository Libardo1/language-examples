#!/usr/bin/env ruby
# A utility to print the value of a number in base 2, 8, 10, 12, 16, and 60.
# The input can in any format accepted by strtoul.

module BaseConvert

=begin rdoc
Map of integer values to base encoding. For decimal and lower, this maps
0-9 to 0-9. All numbers higher than 9 are mapped onto alphabetic characters.

Note that this list includes (0, O) and (1, I, l), which are easily confused
in some fonts. The sexagesimal representation is primarily intended to be
machine-readable, not human readable.
=end
  TR = %w{ 0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z _ - }

=begin
Generate a string representing Fixnum 'num' in radix 'base'.

Note: The ruby to_s method can only take radix arguments of up to 37, hence
the need for a generic version.
=end
  def self.convert(num, base)
    chars = []
    while num > 0
      chars << TR[num % base]
      num = (num/base).floor
    end

    (chars.empty?) ? '0': chars.reverse.join('')
  end
end

if __FILE__ == $0
  raise "Usage: $0 NUM [NUM...]" if ARGV.empty?

  bases = [60,16,12,10,8,2]
  ARGV.each do |arg| 
    meth = :to_i
    meth = :oct if arg.start_with? '0'
    meth = :hex if arg.start_with? '0x'
    num = arg.send(meth)
    raise "Invalid argument #{arg}" if not num
    puts bases.map { |b| BaseConvert.convert(num, b) }.join("\t")
  end
end
