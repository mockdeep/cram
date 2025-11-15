module Cram::Actions::SelectDeck
  def self.call
    decks = Dir.glob(File.join(decks_dir, '*.yml')).map do |filepath|
      Cram::Models::Deck.new(filepath:)
    end

    puts "Select a deck:"
    decks.each_with_index do |deck, index|
      puts "#{index + 1}. #{deck.name}"
    end

    print "Deck number: "
    deck_number = Integer($stdin.getch)

    decks[deck_number - 1]
  end

  def self.decks_dir
    File.join(Dir.home, '.cram/decks')
  end
end
