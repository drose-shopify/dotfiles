# === Editor ===
Pry.editor = "nvim"
Pry.config.editor = 'nvim'

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

  command "verify_tax_rates" do |file_path|
    TaxUtils.verify_rates(file_path)
  end
end

Pry.config.commands.import default_command_set

# === CONVENIENCE METHODS ===
# Stolen from https://gist.github.com/807492

Dir[File.expand_path('~/dotfiles/pry_modules/*.rb')].each do |file|
  require file
end

Debundle.debundle!

### END debundle.rb ###

# == PLUGINS ==
begin
    require 'pry-macro'
rescue LoadError => err
    puts 'gem install pry-macro # <-- highly recommended'
end

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
