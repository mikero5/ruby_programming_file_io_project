# 
# Hangman
# 
# 
# Empty Gallows:
#    ------+
#    |     |
#          |
#          | 
#          |
#          |
#          |
#       -------
# 
# 
# 
# Complete Gallows:
#    ------+
#    |     |
#    O     |
#   \|/    |   (body: 2 pipes)
#    |     |   (this body pipe added with the one above)
#   / \    |
#          |
#       -------
# 
# pseudocode:
# 1. get user desire to start new game or load saved game.
# 2. if load game selected, show list, get selection, and set game state.
#    else select word with length between 5 & 12 characters.
# 3. while not_done
#    3a. get user input (one guess == guess, word-length input == attempt to solve, *s* == save game)
#    3b. process input while attempts remaining > 0
#        - if guess, show all positions the char occupies in target word, or decrement attempts remaining
#        - if solve, declare win, or decrement attempts remaining
#

require "yaml"
require "date"

class State
  attr_reader   :word
  attr_accessor :turns
  attr_accessor   :guess
  
  def initialize(word)
    @turns = 12
    @word = word
    @guess = []
    (1..@word.length).each {
      @guess.push('_')
    }
  end

  def to_s
    "In State:\n   #{@word}, #{@turns}, #{@guess}\n"
  end
end


class Hangman
  attr_reader :word
  attr_reader :state
  
  def initialize
    @dictionary = File.read('./5desk.txt').split("\n")
    @dictionary.filter! {|el|
      el.length >= 5 && el.length <= 12
    }
    @word = @dictionary[rand(0..@dictionary.length)]
    @state = State.new(@word)
    @date = Time.now
    puts @state
  end

  def save_game
    filename = "hangman_" + @date.strftime('%d_%b_%Y:%H_%M') + ".gam"
    file = File.open(filename, 'w')
    serialized_object = YAML::dump(@state)
    file.puts serialized_object
    file.close
    puts "Game saved (#{filename})"
  end

  def load_game
    index = 0
    file_list = Dir.glob("*.gam")
    game_list = Dir.glob("*.gam").map {|file|
      index += 1
      file = "#{index.to_s[0..2]}.  #{file}"
    }

    game_list.each {|entry|
      puts entry
    }
    print "Enter number of game to load: "
    game_number = STDIN.gets.to_i - 1
    puts ""
    puts "selected game file: #{file_list[game_number]}"
    filename = file_list[game_number]
    file =  File.open(filename, 'r')
    serialized_object = file.read
    @state = YAML::load(serialized_object)
  end

  def turn
    valid = false
    guess = ""
    @state.guess.map {|el|
      guess += el + " "
    }
    while !valid
      puts "Current status: #{guess},  Turns remaining: #{@state.turns}"
      puts ""
      print "Enter a letter, guess the word, or enter '*S*' to save: "
      input = STDIN.gets.chomp.downcase
      if input == "*s*"
        save_game
        return false
      elsif input.length == 1
        valid = true
      elsif input.length == @state.word.length
        if input == @state.word
          puts input.split('').inspect
          @state.guess = input.split('')
          return true
        end
        valid = true
      else
        puts "Invalid input, please enter a single letter, or a word guess with the correct number of letters, try again..."
      end
    end
    
    word_array = @state.word.split('')
    word_array.each_with_index {|c, index|
      if c == input
        @state.guess[index] = input
      end
    }
    @state.turns -= 1
    return true
  end

  def check_win
    retval = false
    test_string = @state.guess.join('')
    if test_string == @state.word
      retval = true
    end
    retval
  end
  
  def play
    puts ""
    puts "*** Hangman ***"
    puts ""
    new_or_load = ""
    while new_or_load != "N" && new_or_load != "L"
      print "[N]ew game or [Load] saved game? [N/L]: "
      new_or_load = STDIN.gets.chomp.upcase
      if new_or_load != "N" && new_or_load != "L"
        puts "Invalid input (" + new_or_load + "), please enter 'N' or 'L', try again..."
      end
    end

    if new_or_load == 'N'
      while @state.turns > 0
        if check_win
          puts ""
          puts "You Win!"
          puts ""
          return
        end
        if !turn
          return
        end
      end
    else
      while @state.turns > 0
        load_game
        if check_win
          puts ""
          puts "You Win!"
          puts ""
          return
        end
        if !turn
          return
        end
      end
    end
    puts ""
    puts "You Lose!"
    puts "The word was: #{@state.word}"
    puts ""
  end
  
end



game = Hangman.new
game.play
