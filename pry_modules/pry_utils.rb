# frozen_string_literal: true
class PryUtils
  def self.hash_differences(a:, b:, name: nil)
    a.each_pair do |key, value|
      key_name = if name.nil?
        key
      else
        "#{name}.#{key}"
      end
      unless b.key?(key)
        p "#{key_name} does not exist in second hash"
        next
      end
      unless b[key].class == value.class
        p "#{key_name} have different types, expected #{value.class} but got #{b[key].class}"
        next
      end
      if value.is_a?(Hash)
        PryUtils.hash_differences(a: value, b: b[key], name: key_name)
        next
      elsif value.is_a?(Array)
        PryUtils.array_differences(a: value, b: b[key], name: key_name)
        next
      end
      unless value == b[key]
        p "#{key_name} not equal: expected #{value} but got #{b[key]}"
      end
    end
  end

  def self.array_differences(a:, b:, name: nil)
    unless a.length == b.length
      p "#{name} - array lengths are different #{a.length} != #{b.length}"
    end
    a.each_index do |i|
      element_name = if name.nil?
        "[#{i}]"
      else
        "#{name}[#{i}]"
      end
      a_element = a[i]
      b_element = b[i]
      unless a_element.class == b_element.class
        p "#{element_name} have different types got #{b_element.class} and expected #{a_element.class}"
        next
      end
      if a_element.is_a?(Hash)
        PryUtils.hash_differences(a: a_element, b: b_element, name: element_name)
        next
      elsif a_element.is_a?(Array)
        PryUtils.array_differences(a: a_element, b: b_element, name: element_name)
        next
      end
      unless a_element == b_element
        p "#{element_name} not equal: expected #{a_element} but got #{b_element}"
      end
    end
  end

  def self.pbcopy(input)
    str = input.to_s
    IO.popen('pbcopy', 'w') { |f| f << str }
    str
  end

  def self.pbcopy_json(input)
    str = JSON.pretty_generate(input).undump
    IO.popen('pbcopy', 'w') { |f| f << str }
    str
  end

  def self.pbpaste
    `pbpaste`
  end
end
