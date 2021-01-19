# frozen_string_literal: true

#  Copyright (c) 2007-2012 Vassilis Rizopoulos. All rights reserved.
require 'logger'

##
# This module contains the entire functionality of Patir.
#
# Some useful helpers are included as methods too.
module Patir
  ##
  # Exception which is thrown by ShellCommand if the Hash used for
  # initialization misses the required +cmd+ key
  class ParameterException < RuntimeError
  end

  ##
  # Extend the default log message formatter to define an own format
  class PatirLoggerFormatter < Logger::Formatter
    ##
    # The format of the created log messages
    FORMAT = "[%s] %5s: %s\n"

    ##
    # Create a new instance defining the internally held log format
    def initialize
      super
      @datetime_format = '%Y%m%d %H:%M:%S'
    end

    ##
    # Create a formatted log message from the passed data
    def call(severity, time, _progname, msg)
      format(FORMAT, format_datetime(time), severity, msg2str(msg))
    end
  end

  ##
  # Set up a default logger for usage by top-level scripts and library users
  #
  # This creates a default logger fit for the usage with and around Patir.
  #
  # +mode+ can be
  # * +:mute+ to set the level to +FATAL+
  # * +:silent+ to set the level to +WARN+
  # * +:debug+ to set the level to +DEBUG+. +debug+ is set also if $DEBUG is
  #   +true+
  #
  # The default log level is +INFO+.
  def self.setup_logger(filename = nil, mode = nil)
    logger = if filename
               Logger.new(filename)
             else
               Logger.new($stdout)
             end
    logger.level = Logger::INFO
    logger.level = mode if [Logger::INFO, Logger::FATAL, Logger::WARN, Logger::DEBUG].member?(mode)
    logger.level = Logger::FATAL if mode == :mute
    logger.level = Logger::WARN if mode == :silent
    logger.level = Logger::DEBUG if mode == :debug || $DEBUG
    logger.formatter = PatirLoggerFormatter.new
    logger
  end

  ##
  # Version information of Patir
  module Version
    ##
    # The major version of Patir
    MAJOR = 0
    ##
    # The minor version of Patir
    MINOR = 9
    ##
    # The tiny version of Patir
    TINY = 0
    ##
    # The full version of Patir as a String
    STRING = [MAJOR, MINOR, TINY].join('.')
  end
end
