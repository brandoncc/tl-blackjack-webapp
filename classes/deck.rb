require_relative 'card'

class Deck
  attr_accessor :discard_pile, :shuffled_cards

  def initialize
    @discard_pile   = []
    @shuffled_cards = []

    build_deck
  end

  def build_deck
    6.times do
      %w(Clubs Diamonds Hearts Spades).each do |s|
        %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace).each do |v|
          @shuffled_cards << Card.new(v, s)
        end
      end
    end

    shuffle_deck!
  end

  def deal_one_card
    shuffle_deck! if @shuffled_cards.count == 0
    @shuffled_cards.shift
  end

  def shuffle_deck!
    discard_pile.count.times do
      @shuffled_cards << @discard_pile.pop
    end

    15.times do
      @shuffled_cards.shuffle!
    end
  end
end
