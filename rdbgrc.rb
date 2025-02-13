def helpme
  usage=<<~END
    Available custom functions:
    - where_is(klass, method = nil)
    - Where.is_proc(proc)
    - Where.is_method(klass, method_name)
    - Where.is_instance_method(klass, method_name)
    - Where.are_methods(klass, method_name)
    - Where.are_instance_methods(klass, method_name)
    - Where.is_class(klass)
    - Where.is_class_primarily(klass)
    - Where.edit(path, line_number=1)
      opens the specified path with your default editor (ENV['EDITOR'])
  END
  puts usage
  if (work_loaded?() rescue false)
    puts helpme_work

  end
end

module Where
  class <<self
    attr_accessor :editor

    def is_proc(proc)
      source_location(proc)
    end

    def is_method(klass, method_name)
      source_location(klass.method(method_name))
    end

    def is_instance_method(klass, method_name)
      source_location(klass.instance_method(method_name))
    end

    def are_methods(klass, method_name)
      are_via_extractor(:method, klass, method_name)
    end

    def are_instance_methods(klass, method_name)
      are_via_extractor(:method, klass, method_name)
    end

    def is_class(klass)
      methods = defined_methods(klass)
      file_groups = methods.group_by{|sl| sl[0]}
      file_counts = file_groups.map do |file, sls|
        lines = sls.map{|sl| sl[1]}
        count = lines.size
        line = lines.min
        {file: file, count: count, line: line}
      end
      file_counts.sort_by!{|fc| fc[:count]}
      source_locations = file_counts.map{|fc| [fc[:file], fc[:line]]}
      source_locations
    end

    # Raises ArgumentError if klass does not have any Ruby methods defined in it.
    def is_class_primarily(klass)
      source_locations = is_class(klass)
      if source_locations.empty?
        methods = defined_methods(klass)
        raise ArgumentError, (methods.empty? ?
          "#{klass} has no methods" :
          "#{klass} only has built-in methods (#{methods.size} in total)"
        )
      end
      source_locations[0]
    end

    def edit(file, line_number=1)
      `nvim #{file} +#{line_number}`
    end

    def defined_methods(klass)
      methods = klass.methods(false).map{|m| klass.method(m)} +
        klass.instance_methods(false).map{|m| klass.instance_method(m)}
      methods.map!(&:source_location)
      methods.compact!
      methods
    end

  private

    def source_location(method)
      method.source_location || (
        method.to_s =~ /: (.*)>/
        $1
      )
    end

    def are_via_extractor(extractor, klass, method_name)
      methods = klass.ancestors.map do |ancestor|
        method = ancestor.send(extractor, method_name)
        if method.owner == ancestor
          source_location(method)
        else
          nil
        end
      end
      methods.compact!
      methods
    end

  end

  VimEditor = lambda do |file, line|
    `nvim +#{line} "#{file}"`
  end

  NoEditor = lambda do |file, line|
  end

  @editor = VimEditor
end

def edit_where(klass_and_method)
  edit(where_is(klass_and_method).first)
end

def where_is(klass_and_method)
  klass_name, class_method = klass_and_method.split('#')
  _, instance_method = klass_and_method.split('.')

  klass = Object.const_get(klass_name)

  method = if class_method
    klass.method(class_method)
  elsif instance_method
    klass.instance_method(instance_method)
  else
    Where.defined_methods(klass).first
  end

  method.source_location
end
