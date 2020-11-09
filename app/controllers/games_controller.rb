require 'open-uri'
require 'json'

# include ActionView::Helpers::SanitizeHelper

class GamesController < ApplicationController
  def new
    @grid = make_grid(10)
    @score = get_score() || 0
    # raise
  end

  def score
    unsafe_word = params[:word]
    unsafe_grid = params[:grid]
    answer = strip_tags(unsafe_word).upcase
    grid = strip_tags(unsafe_grid).upcase.chars
    result = decide(answer, grid)
    @message = result[:message]
    @score = get_score() || 0
    @score += result[:score]
    save_score()
  end

  private

  def save_score
    session[:score] = @score
  end

  def get_score
    session[:score]
  end

  def make_grid(size)
    Array('A'..'Z').sample(size)
  end

  def decide(word, grid)
    score = 0
    if !built_from_grid?(word, grid)
      message = "Sorry, but #{word} can't be built out of #{grid.join(', ')}."
    elsif !english_word?(word)
      message = "Sorry, but #{word} doesn't seem to be an existing English word."
    else
      message = "Congratulations, well done!"
      score = 1
    end
    {message: message, score: score}
  end
  
  def built_from_grid?(word, grid)
    letters = word.chars
    return letters.all? { |char| letters.count(char) <= grid.count(char) }
  end

  def english_word?(word)
    word = word.downcase
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    response = JSON.parse(open(url).read)
    return response["found"]
  end
end
