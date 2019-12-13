# frozen_string_literal: true

module Benchmark
  class << self
    def avg(times: 10, &block)
      measure = Benchmark.measure do
        1.upto(times) do
          block.call
        end
      end

      measure / times.to_f
    end
  end
end
