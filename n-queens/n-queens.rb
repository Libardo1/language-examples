#!/usr/bin/env ruby

INIT_TEMP = 30.0
FINAL_TEMP = 0.5
ALPHA = 0.99
STEPS_PER_CHANGE = 100

class Solution
  attr_reader :size
  attr_reader :columns
  attr_reader :energy

  def initialize(n)
    @size = n
    @columns = Array.new(n)
    @energy = 100
    n.times { |i| @columns[i] = i }
    n.times { tweak }
  end

  def initialize_copy(orig)
    @size = orig.size
    @columns = orig.columns.dup
    @energy = orig.energy
  end

  def tweak
    x = y = Kernel.rand(@size)
    while x == y 
      y = Kernel.rand(@size)
    end

    @columns[x], @columns[y] = @columns[y], @columns[x]
  end

  def compute_energy
    dx = [-1, 1, -1, 1]
    dy = [-1, 1, 1, -1]

    board = Array.new(size).map { Array.new(size, 0) }
    @size.times { |i| board[i][@columns[i]] = :queen }

    conflicts = 0
    @size.times do |i|
      x = i
      y = @columns[i]

      # check diagonals
      4.times do |j|
        tmpx = x + dx[j]
        tmpy = y + dy[j]
        while (tmpx >= 0 && tmpx < @size && tmpy >= 0 && tmpy < @size)
          conflicts += 1 if (board[tmpx][tmpy] == :queen)
          tmpx += dx[j]
          tmpy += dy[j]
        end
      end

    end
    @energy = conflicts
  end

  def report
    board = Array.new(size).map { Array.new(size, '_') }
    size.times { |x| board[x][columns[x]] = 'Q' }
    size.times { |x| puts board[x].join('') }
  end

  def to_s
    "[#{@size}] : " + @columns.join(" | ")
  end
end

def main(num)
  Kernel.srand Time.now.to_i

  best = Solution.new(num)
  current = Solution.new(num)
  current.compute_energy

  working = current.dup
  temp = INIT_TEMP
  while temp > FINAL_TEMP do

    # ye ole monte carlo
    STEPS_PER_CHANGE.times do |step|
      use_new = false
      working.tweak
      working.compute_energy
      if working.energy <= current.energy
        use_new = true
      else
        test = Kernel.rand
        delta = working.energy - current.energy
        calc = Math.exp(-delta/temp)
        if calc > test
          use_new = true
        end
      end
      if use_new
        use_new = false
        current = working.dup
        best = current.dup if current.energy < best.energy
      else
        working = current.dup
      end
    end

    # puts "%f %d" % [temp, best.energy ]
    temp *= ALPHA
  end
  
  best.compute_energy
  best.report if best.energy == 0
end

if __FILE__ == $0:
  main( (ARGV.shift || 30).to_i )
end
