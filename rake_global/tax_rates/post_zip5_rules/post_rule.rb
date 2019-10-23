# frozen_string_literal: true

class PostRule
  def applicable?(zip5) do
    raise NotImplementedError 'rule needs an applicable? method'
  end

  def apply(zip5) do
    raise NotImplementedError 'rule needs an apply method'
  end

  def descendants
    descendants = []
    ObjectSpace.each_object(singleton_class) do |k|
    next if k.singleton_class?
      descendants.unshift k unless k == self
    end
    descendants
  end
end
