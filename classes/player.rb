class Player
  attr_accessor :name, :chips, :bet, :cards, :stats

  def initialize
    @cards = []
  end

  def card_count
    cards.count
  end
end
