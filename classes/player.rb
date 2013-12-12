require_relative '../modules/dealable'
require_relative '../modules/bettable'

class Player
  include Dealable
  include Bettable

  attr_accessor :name, :cards, :stats, :finished

  def initialize
    @finished = false
    @cards    = []
  end
end
