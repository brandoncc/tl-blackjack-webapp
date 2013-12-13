#TODO: Maintain w/l/p stats
require_relative '../modules/dealable'
require_relative '../modules/bettable'

class Player
  include Dealable
  include Bettable

  attr_accessor :name, :cards, :stats, :finished

  def initialize
    @finished = false
    @cards    = []
    reset_stats
  end

  def reset_stats
    @stats[:wins]   = 0
    @stats[:losses] = 0
    @stats[:pushes] = 0
  end

  def add_win
    @stats[:wins] += 1
  end

  def add_loss
    @stats[:losses] += 1
  end

  def add_push
    @stats[:pushes] += 1
  end
end
