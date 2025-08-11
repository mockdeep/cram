require "fileutils"
require "sqlite3"
require_relative "../lib/cram"

module ImportSpanish
  class WordCollection
    attr_accessor :words

    def initialize
      self.words = {}
    end

    def <<(word)
      @words[word.original_spanish.downcase] ||= word
    end

    def to_a
      @words.values
    end
  end

  class Word
    PARTS_OF_SPEECH = {
      "A" => "adjective",
      "C" => "etcetera", # conjunction
      "D" => "pronoun", # demonstrative
      "F" => "foreign word",
      "H" => "etcetera", # interrogative
      "I" => "etcetera", # interjection
      "L" => "pronoun",
      "M" => "etcetera", # numeric
      "N" => "noun",
      "P" => "preposition",
      "Q" => "adjective",
      "R" => "adverb",
      "T" => "etcetera", # article
      "U" => "unknown",
      "V" => "verb",
      "W" => "etcetera", # determiner
      "X" => "pronoun", # possessive
      "Y" => "punctuation",
    }.freeze

    IGNORED_PARTS_OF_SPEECH = ["punctuation", "unknown", "foreign word"]

    attr_accessor :original_spanish, :normalized_spanish, :english, :spanish, :part_of_speech

    def initialize(original_spanish:, normalized_spanish:, part_abbreviation:)
      self.original_spanish = original_spanish
      self.normalized_spanish = normalized_spanish
      self.part_of_speech = PARTS_OF_SPEECH.fetch(part_abbreviation)
    end

    def representations
      [
        original_spanish,
        original_spanish.downcase,
        normalized_spanish,
        normalized_spanish.downcase,
      ].uniq
    end

    def ignored?
      IGNORED_PARTS_OF_SPEECH.include?(part_of_speech) ||
        original_spanish.match?(/^\d*$/)
    end
  end

  def self.call
    word_collection = load_crea_data
    add_wikdict_translations(word_collection)
    card_data = format_words(word_collection)
    Cram::Actions::Import.call(card_data:, filename: "spanish_vocab.yml")
  end

  def self.format_words(word_collection)
    word_collection.to_a.select(&:english).map do |word|
      front = word.spanish
      back = word.english
      category = word.part_of_speech

      { front:, back:, category: }
    end
  end

  def self.add_wikdict_translations(word_collection)
    # https://download.wikdict.com/dictionaries/sqlite/
    db = SQLite3::Database.new("tmp/es-en.sqlite3")

    word_collection.to_a.each do |word|
      # SELECT * FROM simple_translation WHERE written_rep = "ser";
      #
      word.representations.each do |representation|
        results = db.execute("SELECT trans_list FROM simple_translation WHERE written_rep = ?", representation)

        if results.any?
          english = results.flatten.first.split(" | ").join("; ")
          word.english = english
          word.spanish = representation
          break
        end
      end

      if word.english.nil?
        puts "No translation found for: #{word.original_spanish}"
      end
    end
  end

  def self.load_crea_data
    # https://www.rae.es/crea-anotado/assets/rae/files/crea/5000_elementos.txt
    frequency_data = File.read("tmp/5000_elementos.txt").split("\n")
    frequency_data.shift # Remove the header line
    frequency_data.shift # Remove the second header line

    word_collection = WordCollection.new

    frequency_data.each do |line|
      original_spanish, normalized_spanish, part_abbreviation = line.split("\t")
      word = Word.new(original_spanish:, normalized_spanish:, part_abbreviation:)

      next if word.ignored?

      word_collection << word
    end

    word_collection
  end
end

ImportSpanish.call
