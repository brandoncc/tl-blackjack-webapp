require 'rubygems'
require 'sinatra'

set :sessions, true

# Plan of action:
# 1. Ask player name ('/')
# 2. Get player bet ('/bet')
# 3. Start game ('/play')
# 4. Show cards ('/play')
# 5. Deal cards ('/play')
# 6. Player turn ('/play')
#   a. Ask for user action until blackjack/bust/21/stay ('/play')
#   b. If blackjack/bust, end game, awarding/taking winnings/losses ('/play')
#   c. Notify player of game result ('/result')
# 7. Dealer turn ('/play')
#   a. Check for blackjack ('/play')
#   b. If blackjack, end game and take lost credits from player ('/play')
#   c. If not, make dealer hit until score > 17 or score < 21 ('/play')
# 8. Compare scores ('/play')
#   a. If player score > dealer score, award winnings ('/play')
#   b. If dealer score > player score, lose bet ('/play')
#   c. If player score == dealer score, bet stays on the table ('/play')
# 9. Show game result ('/result'), with play again button


get '/' do
  session[:player_name] = nil
  erb :greet
end

post '/' do
  if params.has_key?('name') && params[:name].strip.length > 0
    session[:player_name] = params[:name].strip
    session[:chips] = 250
    redirect to('/bet')
  else
    redirect to('/')
  end
end

get '/bet' do
  redirect to('/') if session[:player_name].nil?
  erb :bet
end

post '/bet' do
  if params.has_key?('bet') && params[:bet].to_i > 0
    session[:player_bet] = params[:bet]
    redirect to('/play')
  end
end


