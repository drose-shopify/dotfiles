# frozen_string_literal: true

class Object
  unless Object.method_defined?(:copy_json)
    def copy_json
      str = JSON.pretty_generate(self)
      IO.popen('pbcopy', 'w') { |f| f << str }
      nil
    end
  end
end
