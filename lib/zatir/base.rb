#  Copyright (c) 2007-2012 Vassilis Rizopoulos. All rights reserved.
require 'logger'

module Zatir
  ##
  # Error intended to be thrown by initialize methods when a required parameter
  # is missing from the initialization hash
  #
  # Currently this is only being used by ShellCommand if the hash lacks a +:cmd+
  # key.
  class ParameterException < RuntimeError
  end

  ##
  # Log formatter class with a different format than Ruby's default
  # Logger::Formatter class
  class LoggerFormatter < Logger::Formatter
    ##
    # The format string of LoggerFormatter, e.g.
    #
    #    $ Zatir::LoggerFormatter.new
    #    $  test_obj.call(Logger::DEBUG, Time.now, 'test_prog', 'Bla bla')
    #    => [20210210 00:50:28]     0: Bla bla\n
    FORMAT = "[%s] %5s: %s\n".freeze

    ##
    # Initialize a new LoggerFormatter instance
    def initialize
      super
      @datetime_format = '%Y%m%d %H:%M:%S'
    end

    ##
    # Build a new log message according to the modified format
    #
    # * +severity+ - a severity value (e.g. from Logger::Severity)
    # * +time+ - a timestamp which shall be part of the log message
    # * +program+ - unused
    # * +msg+ - the message which shall be formatted
    def call(severity, time, _progname, msg)
      format(FORMAT, format_datetime(time), severity, msg2str(msg))
    end
  end

  #Just making Logger usage easier
  #
  #This is for use on top level scripts.
  #
  #It creates a logger just as we want it.
  #
  #mode can be
  # :mute to set the level to FATAL
  # :silent to set the level to WARN
  # :debug to set the level to DEBUG. Debug is set also if $DEBUG is true.
  #The default logger level is INFO
  def self.setup_logger(filename=nil,mode=nil)
    if filename
      logger=Logger.new(filename) 
    else
      logger=Logger.new(STDOUT)
    end
    logger.level=Logger::INFO
    logger.level=mode if [Logger::INFO,Logger::FATAL,Logger::WARN,Logger::DEBUG].member?(mode)
    logger.level=Logger::FATAL if mode==:mute
    logger.level=Logger::WARN if mode==:silent
    logger.level=Logger::DEBUG if mode==:debug || $DEBUG
    logger.formatter=LoggerFormatter.new
    #logger.datetime_format="%Y%m%d %H:%M:%S"
    return logger
  end
end
