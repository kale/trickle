require "trickle/version"
require "ostruct"
require "optparse"

module Trickle
  class Trickle
    def initialize(*args)
      @args = args

      @config = OpenStruct.new
      @config.mode = :now
      @config.input = []
      @config.verbose = false
      @config.no_run = false
      @config.random = false
    end

    def run
      if parsed_options? && arguments_valid?

        @config.input.shuffle! if @config.random

        case @config.mode
        when :within
          run_schedule(@config.within)
        when :rate
          run_every(@config.rate)
        when :now
          run_all
        end
      else
        abort @opts.to_s
      end
    end

    def run_all
      @config.input.each do |line|
        run_and_or_display(line)
      end
    end

    def run_schedule(within)
      @threads = []
      mutex = Mutex.new

      @config.input.each do |line|
        @threads << Thread.new do
            sleep(rand(60*within))
          mutex.synchronize do
            run_and_or_display(line)
          end
        end
      end

      # wait for all threads to finish before exiting
      @threads.each(&:join)
    end

    def run_every(rate)
      @config.input.each do |line|
        run_and_or_display(line)
        sleep(60.0/rate)
      end
    end

    protected

    def verbose(line)
      print "#{Time.now} - '#{line.strip}': "
    end

    def run_and_or_display(line)
      verbose(line) if @config.verbose

      if @config.no_run
        puts "#{line}"
      else
        puts `#{line}`
      end
    end

    def parsed_options?
      @opts = OptionParser.new
      @opts.banner = 'Usage: trickle [options] file ...'
      @opts.on('--within x', 'Run all commands randomly within x minutes') {|within| @config.mode = :within; @config.within = within.to_i}
      @opts.on('--rate x', 'Run all commands at the rate of x commands per minute') {|rate| @config.mode = :rate; @config.rate = rate.to_i}
      @opts.on('--now', 'Run all commands now (default)') {@config.mode = :now}
      @opts.on('--verbose', 'Output command that is being ran') {@config.verbose = true}
      @opts.on('--no-run', 'Only display commands, do not execute them') {@config.no_run = true}
      @opts.on('--random', 'Run through commands in random order') {@config.random = true}
      @opts.parse!(@args) rescue return false

      if $stdin.tty?
        @args.each {|file| @config.input += IO.readlines(file)}
      else
        $stdin.each_line {|line| @config.input << line}
      end

      true
    end

    def arguments_valid?
      true if @config.input.any?
    end
  end
end
