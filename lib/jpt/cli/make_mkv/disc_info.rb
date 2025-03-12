require "json"

require "jpt/cli/make_mkv/info_data"
require "jpt/cli/make_mkv/title_info"

module JPT
  module CLI
    module MakeMkv
      class DiscInfo < InfoData
        attr_reader :tcount

        INFO_MSGS = ["CINFO", "TINFO", "SINFO"].to_set

        def initialize
          super
          @titles = {}
        end

        def titles
          @titles.values
        end

        def name
          attributes["Name"]
        end

        def streams
          titles.map { |title| title.streams }.flatten
        end

        def video_streams
          streams.select { |s| s.attributes["Type"] == "Video" }
        end

        def audio_streams
          streams.select { |s| s.attributes["Type"] == "Audio" }
        end

        def subtitle_streams
          streams.select { |s| s.attributes["Type"] == "Subtitles" }
        end

        def parse_info_line(line)
          type, body = line_split_type_and_body(line)
          case type
          when "TCOUNT"
            @tcount = body.to_i
          when *INFO_MSGS
            set_info(type, body)
          else
            Console.warn(self, "Unhandled Message type: #{type}")
          end
        end

        def set_info(type, body)
          case type
          when "CINFO"
            set_cinfo(body)
          when "TINFO"
            set_tinfo(body)
          when "SINFO"
            set_sinfo(body)
          else
            # Nothing
          end
        end

        def set_cinfo(body)
          key, _, value = body.split(",", 3)

          attr_key = key_name(key)
          @attributes[attr_key] = clean_value(value)
        end

        def get_title(id)
          @titles[id] ||= TitleInfo.new(disk_info: self, id: id)
        end

        def set_tinfo(body)
          title_id, key, code, value = body.split(",", 4)

          get_title(title_id).set_tinfo(key, code, value)
        end

        def set_sinfo(body)
          title_id, stream_id, key, code, value = body.split(",", 5)

          get_title(title_id).set_sinfo(stream_id, key, code, value)
        end
      end
    end
  end
end
