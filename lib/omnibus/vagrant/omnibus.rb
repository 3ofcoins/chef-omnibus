require 'omnibus/vagrant/omnibus_build'

module Omnibus
module Vagrant
class Omnibus < ::Vagrant::Command::Base

  def initialize(argv, env)
    super

    @main_args, @sub_command, @sub_args = split_main_and_subcommand(argv)

    @subcommands = ::Vagrant::Registry.new
    @subcommands.register(:build) { OmnibusBuild }
  end

  def execute
    if @main_args.include?("-h") || @main_args.include?("--help")
      # Print the help for all the omni commands.
      return help
    end

    # If we reached this far then we must have a subcommand. If not,
    # then we also just print the help and exit.
    command_class = @subcommands.get(@sub_command.to_sym) if @sub_command
    return help if !command_class || !@sub_command
    @logger.debug("Invoking command class: #{command_class} #{@sub_args.inspect}")

    # Initialize and execute the command class
    command_class.new(@sub_args, @env).execute
  end

  def help
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: vagrant omnibus <command> [<args>]"
      opts.separator ""
      opts.separator "Available subcommands:"

      # Add the available subcommands as separators in order to print them
      # out as well.
      keys = []
      @subcommands.each { |key, value| keys << key.to_s }

      keys.sort.each do |key|
        opts.separator "     #{key}"
      end

      opts.separator ""
      opts.separator "For help on any individual command run `vagrant omnibus COMMAND -h`"
    end

    @env.ui.info(opts.help, :prefix => false)
  end

end # Omnibus
end # Vagrant
end # Omnibus

Vagrant.commands.register(:omnibus) { Omnibus::Vagrant::Omnibus }
