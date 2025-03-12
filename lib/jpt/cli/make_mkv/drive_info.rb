require "csv"

require_relative "string_helpers"

module JPT
  module CLI
    module MakeMkv
      class DriveInfo
        include StringHelpers
        attr_reader :drives

        def initialize
          @drives = []
        end

        def parse_drv_line(line)
          _, body = line_split_type_and_body(line)
          body_parsed = body_parse_as_csv(body)
          index, visible, enabled, flags, drive_name, disc_name, device_name, *junk = body_parsed

          return if visible == "256"

          @drives << {
            index: index,
            visible: visible,
            enabled: enabled,
            flags: flags,
            drive_name: drive_name,
            disc_name: disc_name,
            device_name: device_name,
            junk: junk
          }.compact
        end
      end
    end
  end
end
