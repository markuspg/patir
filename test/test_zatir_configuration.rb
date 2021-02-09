$:.unshift File.join(File.dirname(__FILE__),"..","lib")
require "minitest/autorun"

require 'zatir/configuration'
module Zatir
  class TestConfigurator<Minitest::Test
    def setup
      @prev_dir=Dir.pwd
      Dir.chdir(File.dirname(__FILE__))
    end
    def teardown
      Dir.chdir(@prev_dir)
    end
    def test_configuration
      c=Zatir::Configurator.new("samples/empty.cfg")
      assert_equal(c.configuration,c)
      
      c=Zatir::Configurator.new("samples/chain.cfg")
      assert_equal(c.configuration,c)
    end
    def test_raise_configuration
      assert_raises(Zatir::ConfigurationException) { Zatir::Configurator.new("samples/failed.cfg")}
      assert_raises(Zatir::ConfigurationException) { Zatir::Configurator.new("samples/failed_unknown.cfg")}
      assert_raises(Zatir::ConfigurationException) { Zatir::Configurator.new("samples/syntax.cfg")}
      assert_raises(Zatir::ConfigurationException) { Zatir::Configurator.new("samples/config_fail.cfg")}
    end
  end
end
