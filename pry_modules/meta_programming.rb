class Meta
  def self.redefine_method(klass, method, unbound_method = nil, &block)
    visibility = method_visibility(klass, method)
    begin
      if (instance_method = klass.instance_method(method)) && method != :initialize
        # doing this to ensure we also get private methods
        klass.send(:remove_method, method)
      end
    rescue NameError
      # method isn't defined
      nil
    end
    @replaced_methods[[method, klass]] = instance_method
    if unbound_method
      klass.send(:define_method, method, unbound_method)
      klass.send(visibility, method)
    elsif block
      klass.send(:define_method, method, &block)
      klass.send(visibility, method)
    end
  end
end