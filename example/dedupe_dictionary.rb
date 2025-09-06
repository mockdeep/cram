# frozen_string_literal: true

require "fileutils"
require "yaml"
require_relative "../lib/cram"

# Removes duplicate cards from a dictionary deck based on the front text
module DedupeDictionary
  def self.call
    deck = load_deck

    puts "found duplicates:"
    deck.cards.map(&:front).tally.each do |front, count|
      puts "#{count} x #{front}" if count > 1
    end

    deck.cards = deck.cards.uniq(&:front)
    deck.touch
  end

  def self.load_deck
    deck = Cram::Actions::SelectDeck.call
    puts "saving a backup of #{deck.filepath} to #{deck.filepath}.bak"
    FileUtils.cp(deck.filepath, "#{deck.filepath}.bak")
    deck
  end
end

DedupeDictionary.call
