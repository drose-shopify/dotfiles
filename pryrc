# === Editor ===
Pry.editor = "vim"

# == Pry-Nav ==
Pry.commands.alias_command 'c', 'continue' rescue nil
Pry.commands.alias_command 's', 'step' rescue nil
Pry.commands.alias_command 'n', 'next' rescue nil

# === Listing Config ===
Pry.config.ls.heading_color = :magenta
Pry.config.ls.public_method_color = :green
Pry.config.ls.protected_method_color = :yellow
Pry.config.ls.private_method_color = :bright_black

# === Custom Commands ===
default_command_set = Pry::CommandSet.new do
  command "copy", "Copy argument to the clip-board" do |str|
     IO.popen('pbcopy', 'w') { |f| f << str.to_s }
  end

  command "clear" do
    system 'clear'
    if ENV['RAILS_ENV']
      output.puts "Rails Environment: " + ENV['RAILS_ENV']
    end
  end

  command "sql", "Send sql over AR." do |query|
    if ENV['RAILS_ENV'] || defined?(Rails)
      pp ActiveRecord::Base.connection.select_all(query)
    else
      pp "No rails env defined"
    end
  end
  command "caller_method" do |depth|
    depth = depth.to_i || 1
    if /^(.+?):(\d+)(?::in `(.*)')?/ =~ caller(depth+1).first
      file   = Regexp.last_match[1]
      line   = Regexp.last_match[2].to_i
      method = Regexp.last_match[3]
      output.puts [file, line, method]
    end
  end
end

Pry.config.commands.import default_command_set

# === CONVENIENCE METHODS ===
# Stolen from https://gist.github.com/807492
#load '~/dotfiles/pry_modules/pry_utils.rb'
#load '~/dotfiles/pry_modules/array.rb'
#load '~/dotfiles/pry_modules/hash.rb'
Dir[File.expand_path('~/dotfiles/pry_modules/*.rb')].each do |file| 
  require file 
end

### START debundle.rb ###

# MIT License
# Copyright (c) Conrad Irwin <conrad.irwin@gmail.com>
# Copyright (c) Jan Lelis <mail@janlelis.de>

module Debundle
  VERSION = '1.1.0'

  def self.debundle!
    return unless defined?(Bundler)
    return unless Gem.post_reset_hooks.reject!{ |hook|
      hook.source_location.first =~ %r{/bundler/}
    }
    if defined? Bundler::EnvironmentPreserver
      ENV.replace(Bundler::EnvironmentPreserver.new(ENV, %w(GEM_PATH)).backup)
    end
    Gem.clear_paths

    load 'rubygems/core_ext/kernel_require.rb'
    load 'rubygems/core_ext/kernel_gem.rb'
  rescue
    warn "DEBUNDLE.RB FAILED"
    raise
  end
end

Debundle.debundle!

### END debundle.rb ###

# == PLUGINS ==

require 'pry-rails' if defined? Rails

# awesome_print gem: great syntax colorized printing
# look at ~/.aprc for more settings
begin
    require 'awesome_print'
    # enables awesome_print for all pry output, and enabled paging
    Pry.config.print = proc {|output, value| Pry::Helpers::BaseHelpers.stagger_output("=> #{value.ai}", output)}

  # If you want awesome_print without automatic pagination, use the line below
  # Pry.config.print = proc { |output, value| output.puts value.ai }
    AwesomePrint.pry!
rescue LoadError => err
  puts "gem install awesome_print  # <-- highly recommended"
end


begin
    require 'hirb'
rescue LoadError
    puts 'gem install hirb-unicode # <-- highly recommended'
end

if defined? Hirb
# Dirty hack to support in-session Hirb.disable/enable
  Hirb::View.instance_eval do
    def enable_output_method
      @output_method = true
      Pry.config.print = proc do |output, value|
        Hirb::View.view_or_page_output(value) || output.puts(value.ai)
      end
    end

    def disable_output_method
      Pry.config.print = proc { |output, value| output.puts(value.ai) }
      @output_method = nil
    end
  end
end

#begin
#  require 'faker'
#rescue LoadError
#  puts 'gem install faker'
#end
