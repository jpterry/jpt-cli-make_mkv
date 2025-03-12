# frozen_string_literal: true

require "fileutils"
require "shellwords"
require "async"
require "async/process"

require "jpt/cli/make_mkv/parser"

module JPT
  module CLI
    module MakeMkv
      class Runner
        def self.makemkvcon_path
          @makemkvcon_path ||= ENV["MAKEMKVCON_PATH"] || "/Applications/MakeMKV.app/Contents/MacOS/makemkvcon"
        end

        def self.drive_info(noscan: true)
          run_with_parser!("info", "disc:999", noscan:).drive_info
        end

        def self.disc_info(disc_id: 0, noscan: true)
          run_with_parser!("info", "disc:#{disc_id}", noscan:).disc_info
        end

        def self.backup!(disc_id: 0, backup_path: nil, &blk)
          if backup_path.nil?
            disc_name = drive_info(noscan: false).drives[disc_id][:disc_name]
            backup_path = default_backup_path(disc_name)
            Console.info("No backup path provided, using: #{backup_path}.")
          end

          run_with_parser!("backup", "disc:#{disc_id}", backup_path, &blk)
        end

        # This is my default backup path.
        # TODO: Make this more configurable.
        def self.default_backups_base_path
          ENV["MAKEMKV_BACKUPS_PATH"] || "/Volumes/BEBOP/MovieBackups/backup/"
        end

        def self.default_backup_path(disk_name)
          File.join(default_backups_base_path, disk_name)
        end

        def self.mkv!(source:, destination_folder:, title_id: "all")
          dest_fullpath = File.expand_path(destination_folder)
          File.directory?(dest_fullpath) || raise("Destination folder must be a directory")
          run_with_parser!("mkv", source, title_id.to_s, dest_fullpath)
        end

        def self.file_info(file_path:)
          full_path = File.expand_path(file_path)
          Parser.run_and_parse!("info", "file:#{full_path}").disc_info
        end

        def self.command_line(*args, noscan: true)
          if noscan
            args.unshift("--noscan")
          end
          [
            makemkvcon_path,
            "--robot",
            "--messages=-stdout",
            "--progress=-stdout",
            "--decrypt",
            *args
          ].map { |a| Shellwords.escape(a) }.join(" ")
        end

        def self.run_with_parser!(command, *args, noscan: true)
          parser = Parser.new(command: command)
          Sync do
            run_async!(command, *args, noscan:) do |line|
              parser.parse_line(line)
              yield parser if block_given?
            end
          end
          parser
        end

        def self.async_spawn_makemkvcon!(command, *args, out:, noscan:)
          full_command = command_line(command, *args, noscan:)
          Console.info(self, "Spawning: #{full_command}")
          Async::Process.spawn(full_command, out:)
        end

        def self.run_async!(command, *args, noscan: true)
          input, output = ::IO.pipe
          runner = Async do
            async_spawn_makemkvcon!(command, *args, out: output, noscan:)
          ensure
            output.close
          end

          Sync do
            input.each_line do |line|
              yield line if block_given?
            end
          ensure
            runner.wait
            input.close
          end
        end
      end
    end
  end
end
