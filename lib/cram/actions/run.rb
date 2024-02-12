module Cram::Actions::Run
  def self.call
    deck = Cram::Actions::SelectDeck.call

    Cram::Actions::Study.call(deck)
  end
end
