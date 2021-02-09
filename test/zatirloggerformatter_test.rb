# Copyright (c) 2021 Markus Prasser. All rights reserved.

# frozen_string_literal: true

require 'test_helper'

module Zatir::Test
  ##
  # Verify the functionality of the Zatir::ZatirLoggerFormatter class
  class ZatirLoggerFormatter < Minitest::Test
    ##
    # Verify that new instances are initialized correctly
    def test_initialize
      test_obj = Zatir::ZatirLoggerFormatter.new

      assert_equal('%Y%m%d %H:%M:%S', test_obj.datetime_format)
    end

    ##
    # Verify that messages are being formatted correctly
    def test_formatting
      test_obj = Zatir::ZatirLoggerFormatter.new

      assert_match(/^\[\d{8} \d{2}:\d{2}:\d{2}\] {5}\d: [^\n]*\n$/,
                   test_obj.call(Logger::DEBUG, Time.now,
                                 'test_prog', 'Bla bla'))
    end
  end
end
