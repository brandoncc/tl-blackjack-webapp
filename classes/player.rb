require_relative '../modules/dealable'

class Player
  include Dealable

  attr_accessor :name, :chips, :bet, :cards, :stats, :finished

  def initialize
    @finished = false
    @cards    = []
  end
end
