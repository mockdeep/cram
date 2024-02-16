class Cram::Models::Card
  attr_accessor :front, :back, :category, :view_count, :success_count, :active

  def initialize(front:, back:, category:, view_count:, success_count:, active:)
    @front = front
    @back = back
    @category = category
    @success_count = success_count
    @view_count = view_count
    @active = active
  end

  def active?
    active
  end

  def success_ratio
    return 0 if view_count.zero?

    success_count.to_f / view_count
  end

  def review_threshold
    (2**(success_count * success_ratio)).round
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
    }
  end
end
