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

    ::Bundler::RubygemsIntegration.class_eval do
      def backport_segment_generation
      end
    end

    # Redefine kernel methods that bundler overwrites
    ::Kernel.module_eval do
      remove_method :gem_original_require if 'method' == defined? gem_original_require
      unless defined?(gem_original_require)
        alias gem_original_require require
        private :gem_original_require
      end
      remove_method :gem if 'method' == defined? gem
      def gem(gem_name, *requirements) # :doc:
        skip_list = (ENV['GEM_SKIP'] || "").split(/:/)
        raise Gem::LoadError, "skipping #{gem_name}" if skip_list.include? gem_name
        spec = Gem::Dependency.new(gem_name, *requirements).to_spec
        spec.activate if spec
      end
      def require(path)
        RUBYGEMS_ACTIVATION_MONITOR.enter

        path = path.to_path if path.respond_to? :to_path

        if spec = Gem.find_unresolved_default_spec(path)
          Gem.remove_unresolved_default_spec(spec)
          begin
            gem(spec.name)
            #Kernel.send(:gem, spec.name)
          rescue Exception
            RUBYGEMS_ACTIVATION_MONITOR.exit
            raise
          end
        end

        # If there are no unresolved deps, then we can use just try
        # normal require handle loading a gem from the rescue below.

        if Gem::Specification.unresolved_deps.empty?
          RUBYGEMS_ACTIVATION_MONITOR.exit
          return gem_original_require(path)
        end

        # If +path+ is for a gem that has already been loaded, don't
        # bother trying to find it in an unresolved gem, just go straight
        # to normal require.
        #--
        # TODO request access to the C implementation of this to speed up RubyGems

        if Gem::Specification.find_active_stub_by_path(path)
          RUBYGEMS_ACTIVATION_MONITOR.exit
          return gem_original_require(path)
        end

        # Attempt to find +path+ in any unresolved gems...

        found_specs = Gem::Specification.find_in_unresolved path

        # If there are no directly unresolved gems, then try and find +path+
        # in any gems that are available via the currently unresolved gems.
        # For example, given:
        #
        #   a => b => c => d
        #
        # If a and b are currently active with c being unresolved and d.rb is
        # requested, then find_in_unresolved_tree will find d.rb in d because
        # it's a dependency of c.
        #
        if found_specs.empty?
          found_specs = Gem::Specification.find_in_unresolved_tree path

          found_specs.each do |found_spec|
            found_spec.activate
          end

        # We found +path+ directly in an unresolved gem. Now we figure out, of
        # the possible found specs, which one we should activate.
        else

          # Check that all the found specs are just different
          # versions of the same gem
          names = found_specs.map(&:name).uniq

          if names.size > 1
            RUBYGEMS_ACTIVATION_MONITOR.exit
            raise Gem::LoadError, "#{path} found in multiple gems: #{names.join ', '}"
          end

          # Ok, now find a gem that has no conflicts, starting
          # at the highest version.
          valid = found_specs.find { |s| !s.has_conflicts? }

          unless valid
            le = Gem::LoadError.new "unable to find a version of '#{names.first}' to activate"
            le.name = names.first
            RUBYGEMS_ACTIVATION_MONITOR.exit
            raise le
          end

          valid.activate
        end

        RUBYGEMS_ACTIVATION_MONITOR.exit
        return gem_original_require(path)
      rescue LoadError => load_error
        RUBYGEMS_ACTIVATION_MONITOR.enter

        begin
          if load_error.message.start_with?("Could not find") or
              (load_error.message.end_with?(path) and Gem.try_activate(path))
            require_again = true
          end
        ensure
          RUBYGEMS_ACTIVATION_MONITOR.exit
        end

        return gem_original_require(path) if require_again

        raise load_error
      end
    end
  rescue
    warn "DEBUNDLE.RB FAILED"
    raise
  end
end