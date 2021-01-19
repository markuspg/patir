# frozen_string_literal: true

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'patir/base'

module Patir
  ##
  # Module for the verification of the functionality of Patir
  module Test
    ##
    # Check Patir::Version
    class Version < Minitest::Test
      ##
      # Verify that the version data is correctly set
      def test_version_data
        assert_equal(0, Patir::Version::MAJOR)
        assert_equal(9, Patir::Version::MINOR)
        assert_equal(0, Patir::Version::TINY)
        assert_equal('0.9.0', Patir::Version::STRING)
      end
    end
  end
end
