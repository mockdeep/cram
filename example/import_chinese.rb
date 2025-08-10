require 'fileutils'
require 'yaml'
require_relative '../lib/cram'

module ImportChinese
  TONES = {
    "a" => ["ā", "á", "ǎ", "à", "a"],
    "e" => ["ē", "é", "ě", "è", "e"],
    "ê" => ["ê̄", "ế", "ê̌", "ề", "ê"],
    "i" => ["ī", "í", "ǐ", "ì", "i"],
    "o" => ["ō", "ó", "ǒ", "ò", "o"],
    "u" => ["ū", "ú", "ǔ", "ù", "u"],
    "ü" => ["ǖ", "ǘ", "ǚ", "ǜ", "ü"],
    "m" => ["m̄", "ḿ", "m̌", "m̀", "m"],
  }

  class WordCollection
    attr_accessor :simplified

    def initialize
      self.simplified = {}
    end

    def <<(word)
      simplified[word.simplified] ||= word
      @traditional = nil
    end

    def traditional
      @traditional ||= simplified.values.index_by(&:traditional)
    end
  end

  class Word
    attr_accessor :simplified, :traditional, :pinyin, :meaning

    def initialize(simplified:, traditional:, pinyin:)
      self.simplified = simplified
      self.traditional = traditional
      self.pinyin = pinyin
    end
  end

  def self.call
    word_collection = load_cedict
    characters = JSON.parse(File.read("tmp/hanzi.json"))
    card_data = format_words(word_collection, characters)
    Cram::Actions::Import.call(card_data:, filename: "chinese_hanzi.yml")
  end

  def self.format_words(word_collection, characters)
    characters.map do |character|
      word = word_collection.simplified[character["character"]]
      word ||= word_collection.traditional.fetch(character["character"])
      word.meaning = character["meaning"]

      front = word.simplified
      front += " (#{word.traditional})" if word.traditional != word.simplified
      back = "(#{word.pinyin}) #{word.meaning}"

      { front:, back:, category: nil }
    end
  end

  def self.load_cedict
    lines = File.read("tmp/cedict_ts.u8").split("\n")
    lines.reject! { |line| line.start_with?("#") }
    word_collection = WordCollection.new

    lines.each { |line| word_collection << parse_cedict_line(line) }

    word_collection
  end

  def self.parse_cedict_line(line)
    traditional, simplified, rest = line.split(" ", 3)
    pinyin = rest.match(/\[(.*?)\]/)[1]
    pinyin = accent_pinyin(pinyin)
    translation = rest.match(/\/(.*)\//)[1]

    Word.new(traditional:, simplified:, pinyin:)
  end

  def self.accent_pinyin(pinyin)
    pinyin.split.map { |syllable| accent_syllable(syllable) }.join(" ")
  end

  def self.accent_syllable(syllable)
    return syllable unless syllable =~ /\d$/
    tone_number = Integer(syllable.slice!(-1)) - 1
    syllable = syllable.downcase
    vowels = syllable.scan(/[aeêiouü]/i).join
    case vowels
    when /a/
      syllable.sub("a", TONES["a"][tone_number])
    when /e/
      syllable.sub("e", TONES["e"][tone_number])
    when "ou", "o", "uo", "io"
      syllable.sub("o", TONES["o"][tone_number])
    when "iu", "u"
      syllable.sub("u", TONES["u"][tone_number])
    when "ui", "i"
      syllable.sub("i", TONES["i"][tone_number])
    else
      case syllable
      when "hm"
        "h#{TONES["m"][tone_number]}"
      when "hng"
        "h#{TONES["e"][tone_number]}ng"
      when "m"
        "#{TONES["m"][tone_number]}"
      when "r"
        "#{TONES["e"][tone_number]}r"
      when "xx"
        "xx"
      else
        raise "unaccounted for accent #{syllable.inspect} with tone #{tone_number}"
      end
    end
  end
end

ImportChinese.call
