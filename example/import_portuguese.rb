require 'fileutils'
require 'yaml'

module ImportPortuguese
  def self.call
    lines = File.read('tmp/portuguese_data').split("\n")

    items = lines.map { |line| parse_line(line) }

    FileUtils.mkdir_p(decks_dir)

    file_path = File.join(decks_dir, "portuguese_vocab.yml")
    if File.exist?(file_path)
      print "File already exists. Overwrite? (y/n) "
      unless gets.chomp == 'y'
        puts "Aborting"
        return
      end
    end

    File.write(File.join(decks_dir, "portuguese_vocab.yml"), items.to_yaml)

    puts "Successfully imported #{items.count} items"
  end

  def self.decks_dir
    File.join(Dir.home, '.cram/decks')
  end

  def self.parse_line(line)
    portuguese_word, rest = line.split('[')
    portuguese_word = portuguese_word.strip
    part_of_speech, rest = rest.split('] (')

    english_word = rest.split(')').first

    { portuguese_word:, part_of_speech:, english_word: }
  end
end

ImportPortuguese.call
