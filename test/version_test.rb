# frozen_string_literal: true

# Copyright (c) 2021 Markus Prasser. All rights reserved.

require 'test_helper'

require 'zatir/version'

module Zatir
  ##
  # Module for the verification of the functionality of Zatir
  module Test
    ##
    # Verify the functionality of the Zatir::Version module
    class Version < Minitest::Test
      ##
      # Verify that the version numbers are set correctly
      def test_version_numbers
        assert_equal(0, Zatir::Version::MAJOR)
        assert_equal(99, Zatir::Version::MINOR)
        assert_equal(0, Zatir::Version::PATCH)
        assert_equal('0.99.0', Zatir::Version::STRING)
      end
    end
  end
end
