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
      test_card(deck:, card:)
    end
  end

  def self.next_card(deck, last_card:)
    practice_cards = deck.practice_cards.without(last_card)

    if practice_cards.length >= Cram::MIN_PRACTICE_CARDS
      return practice_cards.sample
    end

    card = deck.pending_cards.first

    if card
      card.active = true
      return card
    end

    deck.pratice_cards.sample
  end

  def self.display_info(deck:, card:)
    puts gray("Active cards: #{deck.active_count}, Practice cards: #{deck.practice_count}, Pending cards: #{deck.pending_count}")
    puts gray("Card success ratio: #{card.success_ratio.round(3)}, Target: #{deck.target_success_ratio.round(3)}")
    puts gray("Card view count: #{card.view_count}, Card review threshold: #{card.review_threshold}")
  end

  def self.test_card(deck:, card:)
    puts
    puts cyan(card.front)
    puts

    similar_cards = select_similar_cards(deck, card)
    similar_cards.each_with_index do |similar_card, index|
      puts "#{index + 1}. #{similar_card.back}"
    end

    answer = get_answer(max: similar_cards.length)

    selected_card = similar_cards[answer - 1]
    if selected_card == card
      card.success_count += 1
      puts green("✔ Correct!")
    else
      card.wrong_answer = selected_card.back
      puts "#{red("✗ Incorrect!")} The answer is: #{yellow(card.back)}"
    end
    card.touch
    deck.touch
    puts "Success ratio is now: #{card.success_ratio.round(3)}"
    puts "Jitter is now: #{card.jitter}"
    puts "Review threshold is now: #{card.review_threshold}"
    $stdin.getch
  end

  def self.get_answer(max:)
    print "Answer: "
    answer = $stdin.getch
    if answer == "q" || answer == "\u0004"
      puts "Exiting"
      exit
    end

    index = Integer(answer)

    if index < 1 || index > max
      raise ArgumentError, "Invalid answer"
    end

    puts answer

    index
  rescue ArgumentError
    print "\r"
    retry
  end

  def self.select_similar_cards(deck, card)
    similar_cards = deck.cards.without(card).select do |practice_card|
      practice_card.category == card.category && practice_card.back != card.back
    end

    if card.wrong_answer
      wrong_card = similar_cards.find do |similar_card|
        similar_card.back == card.wrong_answer
      end

      if wrong_card
        (similar_cards.without(wrong_card).sample(3) + [wrong_card] + [card]).shuffle
      else
        card.wrong_answer = nil
        (similar_cards.sample(4) + [card]).shuffle
      end
    else
      (similar_cards.sample(4) + [card]).shuffle
    end
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
