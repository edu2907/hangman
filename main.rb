# Responsible for the logic of the game
class Game
  def initialize
    @word_master = WordMaster.new
    @word_guesser = WordGuesser.new
    @wrong_letters = []
    @guess = Array.new(@word_master.word_length) { '_' }
  end

  def run
    loop_rounds
    print_win_msg
  end

  private

  def loop_rounds
    until game_ended?
      print_board
      guess_letter = @word_guesser.type_letter
      if @word_master.correct_letter?(guess_letter)
        insert_ltr_in_guess(guess_letter)
      else
        @wrong_letters.push(guess_letter)
        @word_guesser.lifes.pop
      end
    end
  end

  def print_board
    puts <<~HEREDOC
       =================================
      ||                               ||
      || Lifes: #{@word_guesser.lifes.join(' ').ljust(11)}            ||
      || Wrong Letters: #{@wrong_letters.join(' ').ljust(11)}    ||
      ||                               ||
      || Word: #{@guess.join(' ').ljust(23)} ||
      ||                               ||
       =================================
    HEREDOC
  end

  def insert_ltr_in_guess(ltr)
    index_list = @word_master.get_ltr_index(ltr)
    index_list.each { |i| @guess[i] = ltr }
  end

  def game_ended?
    master_win? || guesser_win?
  end

  def guesser_win?
    !@guess.include?('_')
  end

  def master_win?
    @word_guesser.lifes.length.zero?
  end

  def print_win_msg
    print_board
    if guesser_win?
      puts 'You guessed right! You win!'
    else
      puts "Too bad, you didn't guess the correct word!"
      @word_master.reveal_secret_word
    end
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

  def correct_letter?(ltr)
    @word.include?(ltr)
  end

  def get_ltr_index(ltr)
    @word.split('').map.with_index { |w_ltr, i| i if w_ltr == ltr }.compact
  end

  def reveal_secret_word
    puts "The secret word was: #{@word}"
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

  def type_letter
    print 'Type the correct letter: '
    letter = gets.chomp.downcase
    if valid_letter?(letter)
      letter
    else
      puts 'Invalid letter! Be sure to type only ONE letter between a-z.'
      type_letter
    end
  end

  private

  def valid_letter?(ltr)
    ltr.length == 1 && ltr.match?(/[a-z]/)
  end
end

Game.new.run
