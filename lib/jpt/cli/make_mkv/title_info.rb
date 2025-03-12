require "jpt/cli/make_mkv/info_data"
require "jpt/cli/make_mkv/stream_info"

module JPT
  module CLI
    module MakeMkv
      class TitleInfo < InfoData
        def initialize(disk_info:, **)
          @disk_info = disk_info
          @streams = {}
          super(**)
        end

        def streams
          @streams.values
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

        def set_tinfo(key, code, value)
          attr_key = key_name(key)
          if attr_key
            @attributes[attr_key] = clean_value(value)
          end
        end

        def get_stream(id)
          @streams[id] ||= StreamInfo.new(title_info: self, id: id)
        end

        def set_sinfo(stream_id, key, code, value)
          get_stream(stream_id).set_sinfo(key, code, value)
        end
      end
    end
  end
end
