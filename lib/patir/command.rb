# Copyright (c) 2007-2020 Vassilis Rizopoulos. All rights reserved.

require 'English'
require 'observer'
require 'fileutils'
require 'systemu'
require 'patir/base'

module Patir
  ##
  # A module defining the interface for a Command object
  #
  # This modul more or less serves the purpose of documenting the interface or
  # contract expected by a class that executes commands and returns their output
  # and exit status.
  #
  # It contains also a bit of functionality that facilitates grouping multiple
  # commands into command sequences
  #
  # The various methods initialize member variables with meaningful values where
  # needed.
  #
  # Using the contract means implementing the Command#run method. This method
  # should then set the +error+, +exec_time+, +output+ and +status+ values
  # according to the implementated command's execution result.
  #
  # RubyCommand and ShellCommand can be taken as practical examples.
  #
  # It is a good idea to rescue all exceptions. +error+ can then be set to
  # return the exception message.
  module Command
    ##
    # A backtrace of the command
    attr_writer :backtrace
    ##
    # Error output of the command
    attr_writer :error
    ##
    # The execution time (duration) of the command
    attr_writer :exec_time
    ##
    # The alias or name of the command
    attr_writer :name
    ##
    # Regular output of the command
    attr_writer :output
    ##
    # The status of the command
    attr_writer :status
    ##
    # The number of the command (could be used for groups of commands)
    attr_accessor :number
    ##
    # Strategy concerning the command (seems to be used to define exit
    # strategies)
    attr_accessor :strategy

    ##
    # Return a backtrace of the command if applicable
    def backtrace
      # Initialize a nil value to something meaningful
      @backtrace ||= ''
      @backtrace
    end

    ##
    # Return the error output of the command
    def error
      # Initialize a nil value to something meaningful
      @error ||= ''
      @error
    end

    ##
    # Return the execution time (duration) of the command
    def exec_time
      # Initialize a nil value to something meaningful
      @exec_time ||= 0
      @exec_time
    end

    ##
    # Return +false+ if the command has not been run, alias for #run?
    def executed?
      return false if status == :not_executed

      true
    end

    ##
    # Return the command's alias or name
    def name
      # Initialize a nil value to something meaningful
      @name ||= ''
      @name
    end

    ##
    # Return the output of the command
    def output
      # Initialize a nil value to something meaningful
      @output ||= ''
      @output
    end

    ##
    # Clear the backtrace, execution time, the outputs and the status of the
    # command
    #
    # This should be called if the execution of a task and its results shall be
    # forgotten.
    def reset
      @backtrace = ''
      @error = ''
      @exec_time = 0
      @output = ''
      @status = :not_executed
    end

    ##
    # Execute the command and returns its status
    #
    # Classes including Command should override this method
    def run(_context = nil)
      @status = :success
      status
    end

    ##
    # Return +true+ if the command has been executed
    def run?
      executed?
    end

    ##
    # Return the status of the Command instance
    #
    # Valid stati are
    # * +:not_executed+ when the command was not run
    # * +:success+ when the command has finished succesfully
    # * +:error+ when the command has an error
    # * +:warning+ when the command finished without errors but there where
    #   warnings
    def status
      # Initialize a nil value to something meaningful
      @status ||= :not_executed
      @status
    end

    ##
    # Return +true+ if the command has finished succesfully
    def success?
      return true if status == :success

      false
    end
  end

  ##
  # This class wraps the Command interface around https://github.com/ahoward/systemu
  #
  # It allows for execution of any shell command on any platform.
  class ShellCommand
    include Command

    ##
    # Initialize a new ShellCommand instance
    #
    # Accepted keys of the Hash passed for initialization are:
    # * +:cmd+ - the shell command to execute (required - ParameterException
    #   will be raised if missing)
    # * +:name+ - assign a name to the command (default is an empty String
    #   instance)
    # * +:timeout+ - if the command runs longer than timeout (given in seconds),
    #   it will be interrupted and an error will be set
    # * +:working_directory+ - specify the working directory (default is '.')
    def initialize(params)
      # A ShellCommand instance without a given commandline is useless
      raise ParameterException, 'No :cmd given' unless params[:cmd]

      @command = params[:cmd]
      @error = ''
      @name = params[:name]
      @output = ''
      @status = :not_executed
      @timeout = params[:timeout]
      @working_directory = params[:working_directory] || '.'
    end

    ##
    # Execute the given shell command and return the status
    def run(_context = nil)
      start_time = Time.now
      begin
        # Create the working directory if it does not exist yet
        FileUtils.mkdir_p(@working_directory, verbose: false)
        # Create the actual command, run it, grab stderr and stdout and set
        # output,error, status and execution time
        if @timeout
          exited = nil
          exit_status = 0
          status, @output, err = systemu(@command, cwd: @working_directory) do |cid|
            sleep @timeout
            @error << "Command timed out after #{@timeout}s"
            exited = true
            exit_status = 23
            begin
              Process.kill 9, cid
            rescue => e
              @error << "Failure to kill timeout child process #{cid}:" \
                        " #{e.message}"
            end
          end
          @error << "\n#{err}" unless err.empty?
        else
          status, @output, @error = systemu(@command, cwd: @working_directory)
          exit_status = status.exitstatus
        end
        begin
          exited ||= status.exited?
        rescue NotImplementedError
          # Oh look, it's JRuby
          exited = true
        end
        # Extract the status and set it
        if exited
          @status = if exit_status.zero?
                      :success
                    else
                      :error
                    end
        else
          @status = :warning
        end
      rescue
        # If it blows in systemu it will be nil
        @error << "\n#{$ERROR_INFO.message}"
        @error << "\n#{$ERROR_INFO.backtrace}" if $DEBUG
        @status = :error
      end
      # Calculate the execution time
      @exec_time = Time.now - start_time
      @status
    end

    def to_s # :nodoc:
      "#{@name}: #{@command} in #{@working_directory}"
    end
  end

  #CommandSequenceStatus represents the status of a CommandSequence, including the status of all the steps for this sequence.
  #
  #In order to extract the status from steps, classes should quack to the rythm of Command. CommandSequenceStatus does this, so you can nest Stati
  #
  #The status of an action sequence is :not_executed, :running, :success, :warning or :error and represents the overall status
  # :not_executed is set when all steps are :not_executed
  # :running is set while the sequence is running.
  #Upon completion or interruption one of :success, :error or :warning will be set.
  # :success is set when all steps are succesfull.
  # :warning is set when at least one step generates warnings and there are no failures.
  # :error is set when after execution at least one step has the :error status
  class CommandSequenceStatus
    attr_accessor :start_time,:stop_time,:sequence_runner,:sequence_name,:status,:step_states,:sequence_id,:strategy
    #You can pass an array of Commands to initialize CommandSequenceStatus
    def initialize sequence_name,steps=nil
      @sequence_name=sequence_name
      @sequence_runner=""
      @sequence_id=nil
      @step_states||=Hash.new
      #not run yet
      @status=:not_executed
      #translate the array of steps as we need it in number=>state form
      steps.each{|step| self.step=step } if steps
      @start_time=Time.now
    end
    def running?
      return true if :running==@status
      return false
    end
    #true is returned when all steps were succesfull.
    def success?
      return true if :success==@status
      return false
    end

    #A sequence is considered completed when:
    #
    #a step has errors and the :fail_on_error strategy is used
    #
    #a step has warnings and the :fail_on_warning strategy is used
    #
    #in all other cases if none of the steps has a :not_executed or :running status
    def completed?
      #this saves us iterating once+1 when no execution took place
      return false if !self.executed?
      @step_states.each do |state|
        return true if state[1][:status]==:error && state[1][:strategy]==:fail_on_error
        return true if state[1][:status]==:warning && state[1][:strategy]==:fail_on_warning
      end
      @step_states.each{|state| return false if state[1][:status]==:not_executed || state[1][:status]==:running }
      return true
    end
    #A nil means there is no step with that number
    def step_state number
      s=@step_states[number] if @step_states[number]
      return s
    end
    #Adds a step to the state. The step state is inferred from the Command instance __step__
    def step=step
      @step_states[step.number]={:name=>step.name,
        :status=>step.status,
        :output=>step.output,
        :duration=>step.exec_time,
        :error=>step.error,
        :strategy=>step.strategy
      }
      #this way we don't have to compare all the step states we always get the worst last stable state
      #:not_executed<:success<:warning<:success
      unless @status==:running
        @previous_status=@status 
        case step.status
        when :running
          @status=:running
        when :warning
          @status=:warning unless @status==:error
          @status=:error if @previous_status==:error
        when :error
          @status=:error
        when :success
          @status=:success unless @status==:error || @status==:warning
          @status=:warning if @previous_status==:warning
          @status=:error if @previous_status==:error
        when :not_executed
          @status=@previous_status
        end
      end#unless running
    end
    #produces a brief text summary for this status
    def summary
      sum=""
      sum<<"#{@sequence_id}:" if @sequence_id
      sum<<"#{@sequence_name}. " unless @sequence_name.empty?
      sum<<"Status - #{@status}" 
      if !@step_states.empty? && @status!=:not_executed
        sum<<". States #{@step_states.size}\nStep status summary:"
        sorter=Hash.new
        @step_states.each do |number,state|
          #sort them by number
          sorter[number]="\n\t#{number}:'#{state[:name]}' - #{state[:status]}"
        end
        1.upto(sorter.size) {|i| sum << sorter[i] if sorter[i]}
      end 
      return sum
    end
    def to_s
      "'#{sequence_id}':'#{@sequence_name}' on '#{@sequence_runner}' started at #{@start_time}.#{@step_states.size} steps"
    end
    def exec_time
      return @stop_time-@start_time if @stop_time
      return 0
    end
    def name
      return @sequence_name
    end  
    def number
      return @sequence_id
    end
    def output
      return self.summary
    end
    def error
      return ""
    end
    def executed?
      return true unless @status==:not_executed
      return false
    end
  end

  ##
  # Class allowing to wrap Ruby blocks and treat them like a command
  #
  # A block provided to RubyCommand#new can be executed using RubyCommand#run
  #
  # The block receives the instance of RubyCommand so the output and error
  # output can be set within the block.
  #
  # If the block runs to the end the command is considered successful.
  #
  # If an exception is raised in the block this will set the command status to
  # +:error+. The exception message will be appended to the +error+ member of
  # the command instance.
  #
  # == Examples
  #
  # An example (using the excellent HighLine lib) of a CLI prompt as a
  # RubyCommand:
  #
  #     RubyCommand.new('prompt') do |cmd|
  #       cmd.error = ''
  #       cmd.output = ''
  #       unless HighLine.agree("#{step.text}?")
  #         cmd.error = 'Why not?'
  #         raise 'You did not agree'
  #       end
  #     end
  class RubyCommand
    include Patir::Command

    ##
    # This holds the block being passed to the initialization method
    attr_reader :cmd
    ##
    # The context of an execution (is reset to +nil+ when execution is finished)
    attr_reader :context
    ##
    # The working directory within the block is being executed
    attr_reader :working_directory

    ##
    # Create a RubyCommand instance with a particular +name+, an optional
    # +working_directory+ and a +block+ that will be executed by it
    def initialize(name, working_directory = nil, &block)
      @name = name
      @working_directory = working_directory || '.'
      raise 'You need to provide a block' unless block_given?

      @cmd = block
    end

    ##
    # Run the block passed on initialization
    def run(context = nil)
      @backtrace = ''
      @context = context
      @error = ''
      @output = ''
      begin
        t1 = Time.now
        Dir.chdir(@working_directory) do
          @cmd.call(self)
          @status = :success
        end
      rescue StandardError
        @error << "\n#{$ERROR_INFO.message}"
        @backtrace = $ERROR_POSITION
        @status = :error
      ensure
        @exec_time = Time.now - t1
      end
      @context = nil
      @status
    end
  end
end
