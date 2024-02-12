class Cram::Models::Deck
  attr_accessor :cards, :filepath, :target_success_ratio, :target_view_ratio

  def initialize(filepath:)
    @filepath = filepath
    YAML.safe_load_file(filepath, permitted_classes: [Symbol], symbolize_names: true) => { cards:, deck: }

    self.cards = cards.map do |card_data|
      Cram::Models::Card.new(**card_data)
    end

    @target_success_ratio = deck.fetch(:target_success_ratio)
    @target_view_ratio = deck.fetch(:target_view_ratio)
  end

  def name
    File.basename(filepath, '.yml').titleize
  end

  def active_cards
    cards.select(&:active?)
  end

  def pending_cards
    cards.reject(&:active?)
  end

  def view_ratio(card)
    return 0 if cards.none?(&:active?)

    (card.view_count.to_f / active_cards.count).round(2)
  end

  def to_yaml
    YAML.safe_dump({
      cards: cards.map(&:to_h),
      deck: {
        target_success_ratio: target_success_ratio,
        target_view_ratio: target_view_ratio,
      },
    }, permitted_classes: [Symbol], stringify_names: true)
  end
end
