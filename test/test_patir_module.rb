# frozen_string_literal: true

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'minitest/autorun'
require 'patir/base'

module Patir::Test
  ##
  # Check the functionality of the Patir module
  class Module < Minitest::Test
    ##
    # A temporary log file for testing
    TEMP_LOG = 'temp.log'

    ##
    # Clean-up steps after each of the Patir test cases
    def teardown
      File.delete(TEMP_LOG) if File.exist?(TEMP_LOG)
    end

    # This is not actually testing anything meaningfull but can be expanded when we learn more about
    # the logger
    def test_setup_logger
      logger = Patir.setup_logger
      refute_nil(logger)
      logger = Patir.setup_logger(nil, :silent)
      refute_nil(logger)
      logger = Patir.setup_logger('temp.log', :silent)
      refute_nil(logger)
      assert(File.exist?(TEMP_LOG), 'Log file not created')
      logger.close
    end
  end
end
