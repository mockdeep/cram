class Cram::Models::Card
  attr_accessor :front, :back, :category, :view_count, :success_count, :active, :jitter, :sequence, :wrong_answer, :review_threshold

  def initialize(front:, back:, category:, view_count:, success_count:, active:, jitter:, wrong_answer: nil, sequence: 0)
    @front = front
    @back = back
    @category = category
    @success_count = success_count
    @view_count = view_count
    @active = active
    @jitter = jitter
    @sequence = sequence
    @wrong_answer = wrong_answer
    self.review_threshold = calculated_review_threshold
  end

  def active?
    active
  end

  def touch
    self.view_count += 1
    self.jitter = rand(Cram::JITTER_RANGE).round(2)
    self.review_threshold = calculated_review_threshold
  end

  def calculated_review_threshold
    (2**(success_count * success_ratio * jitter)).round + sequence
  end

  def success_ratio
    return 0 if view_count.zero?

    success_count.to_f / view_count
  end

  def debug
    "success_ratio: #{success_ratio}"
  end

  def to_h
    {
      front:,
      back:,
      category:,
      view_count:,
      success_count:,
      active:,
      jitter:,
      wrong_answer:,
    }
  end
end
