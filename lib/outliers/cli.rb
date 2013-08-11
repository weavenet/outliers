require 'optparse'

require 'outliers/cli/evaluate'
require 'outliers/cli/process'
require 'outliers/cli/providers'
require 'outliers/cli/resources'

module Outliers
  module CLI

    def self.start
      cmd = ARGV.shift

      case cmd
      when 'evaluate'
        begin
          CLI::Evaluate.new.evaluate
        rescue OptionParser::MissingArgument => e
          puts e.message
          exit 1
        end
      when 'providers'
        begin
          CLI::Providers.new.providers
        rescue OptionParser::MissingArgument => e
          puts e.message
          exit 1
        end
      when 'process'
        begin
          CLI::Process.new.process
        rescue OptionParser::MissingArgument => e
          puts e.message
          exit 1
        end
      when 'resources'
        begin
          CLI::Resources.new.resources
        rescue OptionParser::MissingArgument => e
          puts e.message
          exit 1
        end
      when '-v'
        puts OUTLIERS::VERSION
      else
        puts "Unknown command: '#{cmd}'."
        puts ''
        usage
        exit 1
      end
    end

    def self.usage
      puts 'Usage: outliers command'
      puts ''
      puts 'Append -h for help on specific subcommand.'
      puts ''

      puts 'Commands:'
      commands.each do |cmd|
        $stdout.printf "    %-#{length_of_longest_command}s      %s\n",
                       cmd.command_name,
                       cmd.command_summary
      end
    end

    def self.commands
      return @commands if @commands
      klasses   = Outliers::CLI.constants
      @commands = klasses.map { |klass| Outliers::CLI.const_get(klass).new }
    end

    def self.length_of_longest_command
      commands.map { |c| c.command_name.length }.max
    end

  end
end
