class Cram::Models::Deck
  attr_accessor :cards, :filepath, :target_success_ratio

  def initialize(filepath:)
    @filepath = filepath
    YAML.safe_load_file(filepath, permitted_classes: [Symbol], symbolize_names: true) => { cards:, deck: }

    self.cards = cards.map.with_index do |card_data, index|
      Cram::Models::Card.new(**card_data, sequence: index + 1)
    end

    @target_success_ratio = deck.fetch(:target_success_ratio)
  end

  def name
    File.basename(filepath, '.yml').titleize
  end

  def practice_cards
    active_cards.select do |card|
      card.success_ratio < target_success_ratio ||
        card.review_threshold < active_cards.count
    end
  end

  def active_cards
    cards.select(&:active?)
  end

  def pending_cards
    cards.reject(&:active?)
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
