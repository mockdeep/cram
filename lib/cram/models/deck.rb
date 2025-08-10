class Cram::Models::Deck
  attr_accessor :cards, :active_cards, :pending_cards, :practice_cards, :filepath, :target_success_ratio

  def initialize(filepath:)
    self.filepath = filepath
    YAML.safe_load_file(filepath, permitted_classes: [Symbol], symbolize_names: true) => { cards:, deck: }

    self.cards = cards.map.with_index do |card_data, index|
      Cram::Models::Card.new(**card_data, sequence: index + 1)
    end

    self.target_success_ratio = deck.fetch(:target_success_ratio)
    touch
  end

  def name
    File.basename(filepath, '.yml').titleize
  end

  def active_count
    active_cards.count
  end

  def pending_count
    pending_cards.count
  end

  def practice_count
    practice_cards.count
  end

  def touch
    self.active_cards, self.pending_cards = cards.partition(&:active?)
    self.practice_cards =
      active_cards.select do |card|
        card.success_ratio < target_success_ratio ||
          card.review_threshold < active_cards.count
      end
    File.write(filepath, to_yaml)
  end

  def to_yaml
    YAML.safe_dump({
      cards: cards.map(&:to_h),
      deck: {
        target_success_ratio: target_success_ratio,
      },
    }, permitted_classes: [Symbol], stringify_names: true)
  end
end
