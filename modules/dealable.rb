module Dealable
  def give_card(card)
    @cards << card
  end

  def first_card
    @cards.first
  end

  def hand_is_blackjack?
    @cards.count == 2 && hand_value == Blackjack::BLACKJACK_VALUE
  end

  def hand_is_bust?
    hand_value > Blackjack::BLACKJACK_VALUE
  end

  def hand_value
    calculate_value[:value]
  end

  def hand_is_soft_or_hard
    calculate_value[:soft_or_hard]
  end

  def calculate_value
    score      = { value: 0, soft_or_hard: nil }
    aces_count = 0

    @cards.each do |card|
      if card.numeric_value == 11
        aces_count += 1
      else
        score[:value] += card.numeric_value.to_i
      end
    end

    calculate_aces(score, aces_count)
  end

  # @param [Hash] current_score
  # @param [Fixnum] count
  def calculate_aces(current_score, count)
    # If any items are in the ace array, calculate them in based on whether
    #   they need to be 11 points or 1 point. 11 points is preferred, unless it
    #   will cause a bust, in which case, calculate it as 1 point.
    i = 0
    while i < count
      add_ace_to_score(current_score, i == 0)

      i += 1
    end
    current_score[:soft_or_hard] = nil if current_score[:value] > Blackjack::BLACKJACK_VALUE
    current_score
  end

  def add_ace_to_score(score, set_soft_or_hard)
    if (score[:value] + 11) > Blackjack::BLACKJACK_VALUE
      score[:value] += 1
      score[:soft_or_hard] = 'hard' if set_soft_or_hard
    else
      score[:value] += 11
      score[:soft_or_hard] = 'soft' if set_soft_or_hard
    end
  end

  def card_count
    cards.count
  end
end
