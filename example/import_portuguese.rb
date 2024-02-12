require 'fileutils'
require 'yaml'
require_relative "../lib/cram"

module ImportPortuguese
  def self.call
    lines = File.read('tmp/portuguese_data').split("\n")

    card_data = lines.map { |line| parse_line(line) }

    Cram::Actions::Import.call(card_data:, filename: "portuguese_vocab.yml")
  end

  def self.parse_line(line)
    portuguese_word, rest = line.split('[')
    portuguese_word = portuguese_word.strip
    part_of_speech, rest = rest.split('] (')

    english_word = rest.split(')').first

    {
      front: portuguese_word,
      back: english_word,
      category: part_of_speech,
    }
  end
end

ImportPortuguese.call
