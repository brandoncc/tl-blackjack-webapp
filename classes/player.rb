require_relative '../modules/dealable'
require_relative '../modules/bettable'

class Player
  include Dealable
  include Bettable

  attr_accessor :name, :cards, :stats, :finished, :active, :last_hand_result

  def initialize
    @chips    = Blackjack::INITIAL_CHIPS_VALUE
    @active   = true
    @finished = false
    @cards    = []
    reset_stats
  end

  def reset_stats
    @stats          = {}
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

  def wins_num
    @stats[:wins]
  end

  def losses_num
    @stats[:losses]
  end

  def pushes_num
    @stats[:pushes]
  end

  def build_hand_result_message
    message   = "#{@name}"
    new_chips = @chips
    case @last_hand_result
    when Blackjack::PLAYER_HAS_BLACKJACK
      message   += " got backjack! #{@name} won $#{(@bet * Blackjack::BLACKJACK_PAYOUT).ceil}."
      new_chips = @chips + (@bet * Blackjack::BLACKJACK_PAYOUT).ceil
    when Blackjack::PLAYER_BUSTED
      message   += " busted. #{@name} lost his/her bet of $#{@bet}."
      new_chips = @chips - @bet
    when Blackjack::PLAYER_WINS
      message   += " won! #{@name} was awarded his/her winnings of $#{(@bet * Blackjack::WIN_PAYOUT).ceil}."
      new_chips = @chips + (@bet * Blackjack::WIN_PAYOUT).ceil
    when Blackjack::DEALER_HAS_BLACKJACK
      message   += " lost to the dealer's blackjack. #{@name} lost his/her bet of $#{@bet}."
      new_chips = @chips - @bet
    when Blackjack::DEALER_BUSTED
      message   += " won! #{@name} received $#{(@bet * Blackjack::WIN_PAYOUT).ceil}."
      new_chips = @chips + (@bet * Blackjack::WIN_PAYOUT).ceil
    when Blackjack::DEALER_WINS
      message   += " lost. #{@name} handed in his/her loss of $#{@bet}."
      new_chips = @chips - @bet
    when Blackjack::GAME_IS_PUSH
      message   += "'s hand was a push. The original $#{@bet} bet stays on the table."
      new_chips = @chips
    end

    unless @last_hand_result == Blackjack::GAME_IS_PUSH
      message += " #{@name} now has $#{@chips}."
    end

    message
  end
end
