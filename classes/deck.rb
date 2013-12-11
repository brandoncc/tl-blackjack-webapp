require_relative 'card'

class Deck
  attr_accessor :discard_pile, :shuffled_cards

  def initialize
    6.times do
      %w(Clubs Diamonds Hearts Spades).each do |s|
        %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace).each do |v|
          self.shuffled_cards << Card.new(v, s)
        end
      end
    end

    shuffle_deck!
  end

  def deal_one_card
    shuffle_deck! if self.shuffled_cards.count == 0
    self.shuffled_cards.shift
  end

  def shuffle_deck!
    discard_pile.count.times do
      self.shuffled_cards << self.discard_pile.pop
    end

    15.times do
      self.shuffled_cards.shuffle!
    end
  end
end
