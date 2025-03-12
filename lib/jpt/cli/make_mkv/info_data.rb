# frozen_string_literal: true

require "json"
require_relative "string_helpers"

module JPT
  module CLI
    module MakeMkv
      class InfoData
        INFO_KEY_NAMES = {
          "1" => "Type",
          "2" => "Name",
          "3" => "Language code",
          "4" => "Language name",
          "5" => "Codec id",
          "6" => "Codec short",
          "7" => "Codec long",
          "8" => "Chapters count",
          "9" => "Duration",
          "10" => "Size",
          "11" => "Bytesize",
          "12" => "Stream type extension",
          "13" => "Bitrate",
          "14" => "Channels count",
          "15" => "Angle info",
          "16" => "Source file name",
          "17" => "Sample rate",
          "18" => "Sample size",
          "19" => "Resolution",
          "20" => "Aspect ratio",
          "21" => "Frame rate",
          "22" => "Stream flags",
          "24" => "Original title id",
          "25" => "Segment count",
          "26" => "Segment map",
          "27" => "File name",
          "28" => "Metadata language code",
          "29" => "Metadata language name",
          # These we set to nil are "UI" element data
          "30" => nil, # iaTreeInfo
          "31" => nil, # iaPanelTitle
          "32" => "Volume name",
          "33" => nil, # iaOrderWeight

          "34" => "Output format",
          "35" => "Output format description",
          "38" => "MKV flags",
          "39" => "MKV flags text",
          "40" => "Channel layout",
          "42" => "Output converstion type",
          "49" => "Comment"
        }.freeze

        include StringHelpers
        attr_reader :attributes
        def initialize(**attrs)
          @attributes = attrs.dup
        end

        def clean_value(value)
          # This is a hack to parse quoted strings
          JSON[value]
        end

        def key_name(key)
          if INFO_KEY_NAMES.key?(key)
            INFO_KEY_NAMES[key]
          else
            Console.warn "Unknown key: #{key.inspect} in #{self}"
            key
          end
        end
      end
    end
  end
end
