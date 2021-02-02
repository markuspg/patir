# Copyright (c) 2007-2012 Vassilis Rizopoulos. All rights reserved.
# Copyright (c) 2021 Markus Prasser. All rights reserved.

# frozen_string_literal: true

require 'test_helper'

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
        assert_equal(0, ::Patir::Version::MAJOR)
        assert_equal(9, ::Patir::Version::MINOR)
        assert_equal(0, ::Patir::Version::TINY)
        assert_equal('0.9.0', ::Patir::Version::STRING)
      end
    end
  end
end
