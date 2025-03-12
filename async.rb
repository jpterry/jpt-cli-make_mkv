require "open3"
require "io/nonblock"

require "async"
require "async/process"

require "jpt/cli/make_mkv"

def command_line(backup_path)
  [
    "/Applications/MakeMKV.app/Contents/MacOS/makemkvcon",
    "-r",
    "info",
    "file:#{backup_path}"
  ].join(" ")
end

def run_and_process(backup)
  Async do |task|
    disk_info = JPT::CLI::MakeMkv::DiscInfo.new

    input, output = ::IO.pipe
    runner = Async do
      Async::Process.spawn(command_line(backup), out: output)
    ensure
      output.close
    end

    Sync do
      input.each_line do |line|
        disk_info.parse_info_line(line)
      end
    ensure
      runner.wait
      input.close
      # Simple logging of the parsed data at the end of the task
      puts disk_info.attributes["Name"]
      pp disk_info.titles.map { |t| t.attributes["Source file name"] }
      pp disk_info.video_streams.map { |s| s.attributes }
      pp disk_info.audio_streams.map { |s| s.attributes }
    end
  end
end

def check_all
  Sync do |task|
    tasks = [
      "/Volumes/Media-backups/Disc_Backups/BD/BTTF_BONUS/BDMV",
      "/Volumes/Media-backups/Disc_Backups/BD/FIREFLYUS_D1/BDMV",
      "/Volumes/Media-backups/Disc_Backups/BD/FIREFLYUS_D2/BDMV",
      "/Volumes/Media-backups/Disc_Backups/BD_UHD/BARBIE/BDMV",
      "/Volumes/Media-backups/Disc_Backups/BD_UHD/DUNE/BDMV"
    ].map { |backup| task.async { run_and_process(backup) } }

    tasks.each(&:wait)
  end
end

check_all
