# frozen_string_literal: true

require 'open-uri'

# Class GamesController
# Metodos new e score
class GamesController < ApplicationController
  def new
    @grid_options = rand(5..10).times.map { ('A'..'Z').to_a.sample }
    @start_time = Time.now
  end

  def score
    options     = params[:options].split('')
    start_time  = Time.parse(params[:start_time])
    end_time    = Time.now
    @word       = params[:word].upcase
    @score      = 0
    @message    = full_answer(options, start_time, end_time)
  end

  def full_answer(options, start_time, end_time)
    if check_word?(@word) && included?(@word, options)
      success(start_time, end_time)
    elsif check_word?(@word) && !included?(@word, options)
      error('notInGrid')
    else
      error('notEnglishWord')
    end
  end

  def success(start_time, end_time)
    @score = @word.size / (end_time - start_time)
    @message = "Congratulations! #{@word.upcase} is a valid English word! Your score: #{@score}"
  end

  def error(type)
    @message = if type == 'notInGrid'
                 "Sorry but #{@word.upcase} can't be built out of #{params[:options]}"
               else
                 "Sorry but #{@word.upcase} does not seem to be a valid English word..."
               end
  end

  # The method returns true if it's an english word
  def check_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word.downcase}")
    word_info = JSON.parse(response.read)
    word_info['found']
  end

  # The method returns true if the block never returns false or nil
  def included?(guess, grid)
    guess.split('').all? { |letter| grid.include?(letter) }
  end
end
