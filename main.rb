# Responsible for the logic of the game
class Game
  def initialize
    @word_master = WordMaster.new
    @word_guesser = WordGuesser.new
  end
end

# The computer who chooses the word
class WordMaster
  def initialize
    @word = pick_random_word
  end

  private

  def pick_random_word
    chosen_word = nil
    File.foreach('dictionary.txt').each_with_index do |word, number|
      chosen_word = word if rand < (1.0 / (number + 1))
    end
    chosen_word.chomp
  end
end

# The player who tries to guess the correct letters
class WordGuesser
end

Game.new
