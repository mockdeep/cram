# frozen_string_literal: true

require "fileutils"
require "yaml"
require_relative "../lib/cram"

# Removes duplicate cards from a dictionary deck based on the front text
module ResetDictionary
  def self.call
    deck = load_deck

    deck.cards.each do |card|
      card.view_count = 0
      card.success_count = 0
      card.active = false
      card.wrong_answer = nil
    end

    deck.touch
  end

  def self.load_deck
    deck = Cram::Actions::SelectDeck.call
    puts "saving a backup of #{deck.filepath} to #{deck.filepath}.bak"
    FileUtils.cp(deck.filepath, "#{deck.filepath}.bak")
    deck
  end
end

ResetDictionary.call
