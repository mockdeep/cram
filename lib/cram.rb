# frozen_string_literal: true

require "active_support/all"

module Cram
  DEFAULT_TARGET_SUCCESS_RATIO = 0.60
  DEFAULT_TARGET_VIEW_RATIO = 0.01
  MAX_TARGET_SUCCESS_RATIO = 0.99
  MIN_PRACTICE_CARDS = 5
  TARGET_SUCCESS_RATIO_INCREMENT = 0.05
  TARGET_VIEW_RATIO_INCREMENT = 0.01

  class Error < StandardError; end

  def self.decks_dir
    File.join(Dir.home, '.cram/decks')
  end
end

require_relative "cram/actions"
require_relative "cram/models"
require_relative "cram/version"
