require "jpt/cli/make_mkv/info_data"

module JPT
  module CLI
    module MakeMkv
      class StreamInfo < InfoData
        attr_reader :title_info

        def initialize(title_info:, **)
          @title_info = title_info
          super(**)
        end

        def set_sinfo(key, code, value)
          attr_key = key_name(key)
          value = clean_value(value)
          if attr_key && value != ""
            @attributes[attr_key] = value
          end
        end
      end
    end
  end
end
