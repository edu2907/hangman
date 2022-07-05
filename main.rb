# frozen_string_literal: true

require 'yaml'
# Responsible for the logic of the game
class Game
  attr_reader :wrong_letters, :guess

  def initialize(secret_word, lifes, wrong_letters, guess)
    @word_master = WordMaster.new(secret_word)
    @word_guesser = WordGuesser.new(self, lifes)
    @wrong_letters = wrong_letters
    @guess = guess.nil? ? Array.new(@word_master.word_length) { '_' } : guess
  end

  def run
    loop_rounds
    print_win_msg
  end

  def save_game
    save_obj = create_save_obj
    save_str = YAML.dump(save_obj)
    store_in_file(save_str)
    end_execution
  end

  private

  def loop_rounds
    until game_ended?
      print_board
      guessed_letter = @word_guesser.guess_letter
      if @word_master.correct_letter?(guessed_letter)
        insert_ltr_in_guess(guessed_letter)
      else
        @wrong_letters.push(guessed_letter)
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

  def create_save_obj
    {
      word: @word_master.word,
      lifes: @word_guesser.lifes,
      wrong_letters: @wrong_letters,
      guess: @guess
    }
  end

  def store_in_file(yaml)
    Dir.mkdir('.saves') unless Dir.exist?('.saves')
    file_number = Dir.glob('.saves/*').length + 1

    File.open(".saves/savegame#{file_number}.yaml", 'w+') { |file| file.write yaml }
  end

  def end_execution
    print 'Do you wanna close the game? (yes: type \'y\'/no: type ENTER): '
    option = gets.chomp
    exit if option == 'y'
  end
end

# The computer who chooses the word
class WordMaster
  attr_reader :word

  def initialize(previous_word = nil)
    @word = pick_word(previous_word)
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

  def pick_word(word)
    return word unless word.nil?

    pick_random_word
  end

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

  def initialize(game, lifes)
    @lifes = lifes
    @game = game
  end

  def guess_letter
    letter = type_letter
    return check_letter(letter) unless letter == '!save'

    @game.save_game
    guess_letter
  end

  private

  def type_letter
    print 'Type the correct letter: '
    gets.chomp.downcase
  end

  def check_letter(ltr)
    if ltr_already_typed?(ltr)
      puts 'You already typed that letter!'
      type_letter
    elsif valid_letter?(ltr)
      ltr
    else
      puts 'Invalid letter! Be sure to type only ONE letter between a-z.'
      type_letter
    end
  end

  def valid_letter?(ltr)
    ltr.length == 1 && ltr.match?(/[a-z]/)
  end

  def ltr_already_typed?(ltr)
    typed_ltrs = @game.wrong_letters + @game.guess.reject { |g_ltr| g_ltr == '_' }
    typed_ltrs.include?(ltr)
  end
end

# Loads a saved file or creates a new game
class SaveHandler
  def start_game
    option = select_option
    start_with_selected_option(option)
  end

  def select_option
    puts "Hello player! Choose 'n' to start a new game or 's' to load a save game"
    gets.chomp
  end

  private

  def start_with_selected_option(option)
    case option
    when 'n'
      puts 'Creating a new game...'
      Game.new(nil, Array.new(6) { '♥' }, [], nil).run
    when 's'
      puts 'Loading save files...'
      load_game
    else
      puts 'Invalid option! Try again'
      start_game
    end
  end

  def load_game
    filename = choose_files
    save = load_file(filename)
    Game.new(save[:word], save[:lifes], save[:wrong_letters], save[:guess]).run
  end

  def choose_files
    files_list = Dir.glob('.saves/*')
    return files_list[0] if files_list.length == 1

    files_list.each_with_index { |filename, i| puts "#{i + 1} - #{filename}" }
    puts 'Choose one of the files by their number'
    file_i = gets.chomp.to_i - 1
    return files_list[file_i] unless files_list[file_i].nil?

    puts 'Invalid file number! Try again'
    choose_files
  end

  def load_file(filename)
    YAML.load File.open(filename, 'r').readlines.join
  end
end

puts <<~HEREDOC
 _    _
| |  | |
| |__| | __ _ _ __   __ _ _ __ ___   __ _ _ __
|  __  |/ _` | '_ \\ / _` | '_ ` _ \\ / _` | '_ \\
| |  | | (_| | | | | (_| | | | | | | (_| | | | |
|_|  |_|\\__,_|_| |_|\\__, |_| |_| |_|\\__,_|_| |_|
                     __/ |
                    |___/
HEREDOC

if !Dir.exist?('.saves') || Dir.glob('.saves/*').empty?
  Game.new(nil, Array.new(6) { '♥' }, [], nil).run
else
  SaveHandler.new.start_game
end
