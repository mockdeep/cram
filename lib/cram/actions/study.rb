module Cram::Actions::Study

  def self.call(deck)
    card = nil
    loop do
      card = next_card(deck, last_card: card)

      if card.nil?
        deck.target_success_ratio += 0.05
        deck.target_view_ratio += 0.1

        if deck.target_success_ratio > Cram::MAX_TARGET_SUCCESS_RATIO
          puts "You've completed the deck!"
          break
        end
        next
      end

      system('clear')
      display_info(deck:, card:)
      test_card(card)
      write_deck(deck)
    end
  end

  def self.next_card(deck, last_card:)
    active_cards = deck.active_cards.without(last_card)
    practice_cards = active_cards.select do |card|
      card.success_ratio < deck.target_success_ratio ||
        deck.view_ratio(card) < deck.target_view_ratio
    end

    if practice_cards.length >= Cram::MIN_PRACTICE_CARDS
      return practice_cards.sample
    end

    card = deck.pending_cards.first

    card.active = true if card
    card
  end

  def self.display_info(deck:, card:)
    puts gray("Active cards: #{deck.active_cards.count}, Pending cards: #{deck.pending_cards.count}")
    puts gray("Card view ratio: #{deck.view_ratio(card)}, Target: #{deck.target_view_ratio}")
    puts gray("Card success ratio: #{card.success_ratio}, Target: #{deck.target_success_ratio}")
  end

  def self.test_card(card)
    card.view_count += 1
    puts
    puts cyan(card.front)
    puts
    print "Answer: "
    answer = gets

    if answer.nil?
      puts "Exiting"
      exit
    elsif answer.chomp == card.back
      puts green("Correct!")
      card.success_count += 1
    else
      puts "#{red("Incorrect!")} The answer is: #{yellow(card.back)}"
    end
    gets
  end

  def self.write_deck(deck)
    File.write(deck.filepath, deck.to_yaml)
  end

  def self.gray(string)
    "\e[94m#{string}\e[0m"
  end

  def self.cyan(string)
    "\e[36m#{string}\e[0m"
  end

  def self.green(string)
    "\e[32m#{string}\e[0m"
  end

  def self.red(string)
    "\e[31m#{string}\e[0m"
  end

  def self.yellow(string)
    "\e[33m#{string}\e[0m"
  end
end
