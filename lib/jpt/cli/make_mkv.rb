# frozen_string_literal: true

require "console"
require_relative "make_mkv/version"

module JPT
  module CLI
    module MakeMkv
      class Error < StandardError; end
      # Your code goes here...
    end
  end
end

require_relative "make_mkv/parser"
require_relative "make_mkv/runner"
