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
 
  class ZatirLoggerFormatter<Logger::Formatter
    Format="[%s] %5s: %s\n"
    def initialize
      @datetime_format="%Y%m%d %H:%M:%S"
    end
    
    def call severity, time, progname, msg
      Format % [format_datetime(time), severity,
        msg2str(msg)]
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
    logger.formatter=ZatirLoggerFormatter.new
    #logger.datetime_format="%Y%m%d %H:%M:%S"
    return logger
  end
end
