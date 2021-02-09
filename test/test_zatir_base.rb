$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require "minitest/autorun"
require 'zatir/base.rb'

class TestBase<Minitest::Test
  TEMP_LOG="temp.log"
  def teardown
    #clean up 
    File.delete(TEMP_LOG) if File.exist?(TEMP_LOG)
  end
  
  #This is not actually testing anything meaningfull but can be expanded when we learn more about 
  #the logger
  def test_setup_logger
    logger=Zatir.setup_logger
    refute_nil(logger)
    logger=Zatir.setup_logger(nil,:silent)
    refute_nil(logger)
    logger=Zatir.setup_logger("temp.log",:silent)
    refute_nil(logger)
    assert(File.exist?(TEMP_LOG), "Log file not created")
    logger.close
  end
  
end
