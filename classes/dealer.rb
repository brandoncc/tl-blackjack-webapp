require_relative '../modules/dealable'

class Dealer
  include Dealable

  attr_accessor :cards

  def initialize
    @cards = []
  end
end
