# Responsible for the logic of the game
class Game
  def initialize
    @word_master = WordMaster.new
    @word_guesser = WordGuesser.new
    @wrong_letters = Array.new(6) { ' ' }
    @guess = Array.new(@word_master.word_length) { '_' }
  end

  def run
    print_board
  end

  private

  def print_board
    puts <<~HEREDOC
       =================================
      ||                               ||
      || Lifes: #{@word_guesser.lifes.join(' ')}            ||
      || Wrong Letters: #{@wrong_letters.join(' ')}    ||
      ||                               ||
      || Word: #{@guess.join(' ').ljust(23)} ||
      ||                               ||
       =================================
    HEREDOC
  end
end

# The computer who chooses the word
class WordMaster
  def initialize
    @word = pick_random_word
  end

  def word_length
    @word.length
  end

  private

  def pick_random_word
    chosen_word = nil
    begin
      File.foreach('dictionary.txt').each_with_index do |word, number|
        chosen_word = word if (rand < (1.0 / (number + 1))) && (6..13).include?(word.length)
      end
      chosen_word.chomp
    rescue NoMethodError
      pick_random_word
    end
  end
end

# The player who tries to guess the correct letters
class WordGuesser
  attr_accessor :lifes

  def initialize
    @lifes = ['♥', '♥', '♥', '♥', '♥', '♥']
  end
end

Game.new.run
