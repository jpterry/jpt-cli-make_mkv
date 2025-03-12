# frozen_string_literal: true

require "jpt/cli/make_mkv/disc_info"
require "jpt/cli/make_mkv/drive_info"
require "jpt/cli/make_mkv/progress_info"
require "jpt/cli/make_mkv/string_helpers"

module JPT
  module CLI
    module MakeMkv
      class Parser
        include StringHelpers
        attr_reader :disc_info, :drive_info, :progress_info

        def self.parse_file!(path, command: :info)
          full_path = File.expand_path(path)
          parser = new(command: command)
          File.foreach(full_path, chomp: true) do |line|
            parser.parse_line(line)
          end
          parser
        end

        def initialize(command: nil)
          @command = command
        end

        def parse_line(line)
          @last_line = line
          type = line_type(line)
          Console.debug {
            "Handling line: #{line.inspect}"
          }
          case type
          when "MSG"
            handle_msg(line)
          when "DRV"
            handle_drv(line)
          when "PRGC", "PRGV", "PRGT"
            handle_progress(line)
          when "CINFO", "TINFO", "SINFO", "TCOUNT"
            handle_disc_info(line)
          else
            warn "Parser: Unhandled line type: #{line}"
          end
        end

        def result
          {
            drive_info: @drive_info,
            progress_info: @progress,
            disc_info: @disc_info
          }
        end

        private

        def handle_progress(line)
          @progress_info ||= ProgressInfo.new
          @progress_info.parse_progress_line(line)
        end

        def handle_disc_info(line)
          @disc_info ||= DiscInfo.new
          @disc_info&.parse_info_line(line)
        end

        def handle_msg(line)
          @msg_buffer ||= []
          _, body = line_split_type_and_body(line)
          parsed = body_parse_as_csv(body)

          _, _, _, message, _, *_ = parsed

          @msg_buffer << message
          Console.info(message)
          message
        end

        def handle_drv(line)
          @drive_info ||= DriveInfo.new
          @drive_info.parse_drv_line(line)
        end
      end
    end
  end
end
