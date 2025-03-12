# frozen_string_literal: true

require "csv"

module JPT
  module CLI
    module MakeMkv
      module StringHelpers
        def line_split_type_and_body(line)
          type, body = line.split(":", 2)
          [type, body]
        end

        def line_type(line)
          line_split_type_and_body(line).first
        end

        def body_parse_as_csv(body)
          CSV.parse_line(body.strip, strip: true, liberal_parsing: {backslash_quote: true})
        end
      end
    end
  end
end
