module Cram::Actions::Study

  def self.call(deck)
    card = nil
    loop do
      card = next_card(deck, last_card: card)

      if card.nil?
        deck.target_success_ratio += Cram::TARGET_SUCCESS_RATIO_INCREMENT

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
    practice_cards = deck.practice_cards.without(last_card)

    if practice_cards.length >= Cram::MIN_PRACTICE_CARDS
      return practice_cards.sample
    end

    card = deck.pending_cards.first

    card.active = true if card
    card
  end

  def self.display_info(deck:, card:)
    puts gray("Active cards: #{deck.active_cards.count}, Practice cards: #{deck.practice_cards.count}, Pending cards: #{deck.pending_cards.count}")
    puts gray("Card success ratio: #{card.success_ratio.round(3)}, Target: #{deck.target_success_ratio.round(3)}")
    puts gray("Card view count: #{card.view_count}, Card review threshold: #{card.review_threshold}")
  end

  def self.test_card(card)
    card.touch
    puts
    puts cyan(card.front)
    puts
    print "Answer: "
    answer = gets

    if answer.nil?
      puts "Exiting"
      exit
    elsif answer.chomp == card.back
      card.success_count += 1
      puts green("✔ Correct!")
    else
      puts "#{red("✗ Incorrect!")} The answer is: #{yellow(card.back)}"
    end
    puts "Success ratio is now: #{card.success_ratio.round(3)}"
    puts "Jitter is now: #{card.jitter}"
    puts "Review threshold is now: #{card.review_threshold}"
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
