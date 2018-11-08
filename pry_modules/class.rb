# frozen_string_literal: true
class Class
unless Class.method_defined?(:subclasses)
  def subclasses
    ObjectSpace.each_object(singleton_class).select do |k|
      k != self
    end
  end
end

unless Class.method_defined?(:descendants)
  def descendants(generations=-1)
    descendants = []
    subclasses.each do |k|
      descendants << k
      if generations != 1
        descendants.concat(k.descendants(generations - 1))
      end
    end
    descendants
  end
end
end