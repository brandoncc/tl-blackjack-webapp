require 'rubygems'
require 'sinatra'

set :sessions, true

# Plan of action:
# 1. Ask player name ('/')
# 2. Get player bet ('/bet')
# 3. Start game ('/game')
# 4. Show cards ('/game')
# 5. Deal cards ('/game')
# 6. Player turn ('/game')
#   a. Ask for user action until blackjack/bust/21/stay ('/game')
#   b. If blackjack/bust, end game, awarding/taking winnings/losses ('/game')
#   c. Notify player of game result ('/result')
# 7. Dealer turn ('/game')
#   a. Check for blackjack ('/game')
#   b. If blackjack, end game and take lost credits from player ('/game')
#   c. If not, make dealer hit until score > 17 or score < 21 ('/game')
# 8. Compare scores ('/game')
#   a. If player score > dealer score, award winnings ('/game')
#   b. If dealer score > player score, lose bet ('/game')
#   c. If player score == dealer score, bet stays on the table ('/game')
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
    redirect to('/game')
  end
end


