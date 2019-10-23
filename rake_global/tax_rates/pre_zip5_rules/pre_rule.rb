# frozen_string_literal: true

class PreRule
  def applicable?(zip5, extended_zips) do
    raise NotImplementedError 'rule needs an applicable? method'
  end

  def apply(zip5, extended_zips) do
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
