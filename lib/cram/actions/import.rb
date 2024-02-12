module Cram::Actions::Import
  DECK_DEFAULTS = {
    target_success_ratio: Cram::DEFAULT_TARGET_SUCCESS_RATIO,
    target_view_ratio: Cram::DEFAULT_TARGET_VIEW_RATIO,
  }.freeze

  CARD_DEFAULTS = {
    success_count: 0,
    view_count: 0,
    active: false,
  }.freeze

  def self.call(card_data:, filename:)
    FileUtils.mkdir_p(Cram.decks_dir)

    file_path = File.join(Cram.decks_dir, filename)
    if File.exist?(file_path)
      print "File already exists. Overwrite? (y/n) "
      unless gets.chomp == 'y'
        puts "Aborting"
        return
      end
    end

    yaml = YAML.safe_dump({
      cards: generate_cards(card_data),
      deck: DECK_DEFAULTS,
    }, permitted_classes: [Symbol], stringify_names: true)
    File.write(File.join(Cram.decks_dir, "portuguese_vocab.yml"), yaml)

    puts "Successfully imported #{card_data.count} cards"
  end

  def self.generate_cards(card_data)
    card_data.map do |card_datum|
      Cram::Models::Card.new(**CARD_DEFAULTS, **card_datum).to_h
    end
  end
end
