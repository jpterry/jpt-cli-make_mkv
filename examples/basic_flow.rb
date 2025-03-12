require "shellwords"
require "jpt/cli/make_mkv/runner"

# Find the best title
# TODO: Implement this
# TODO: Consider episodic content, extras, etc.
def find_best_title(disc_info)
  mpls_titles = disc_info.titles.select { |t| t.attributes["Source file name"].end_with?("mpls") }

  mpls_titles.sort_by! { |t| t.attributes["Bytesize"].to_i }

  # Return the largest mpls title
  mpls_titles.last
end

# Backup all disks that are visible
def backup_all_disks
  drive_info = JPT::CLI::MakeMkv::Runner.drive_info(noscan: false)
  return unless drive_info&.drives&.any?

  good_visibility = drive_info.drives.select { |d| d[:visible] != "1" }
  return if good_visibility.empty?
  ready = good_visibility

  Async do |task|
    # Each drive we start a task to backup that disk.
    tasks = ready.map do |drive|
      task.async { backup_disk(disk_id: drive[:index], found_drive: drive) }
    end
    tasks.map(&:wait)
  end.wait
end

# Backup a single disk
# Stores a disc backup in a default location
# Then extracts the largest mpls title to a new location
def backup_disk(disk_id: 0, found_drive: nil)
  Console.info("Backing up Disc with ID: #{disk_id}")
  disc_id = disk_id.to_i
  disc_info = JPT::CLI::MakeMkv::Runner.disc_info(disc_id: disc_id, noscan: true)

  Console.info("Disc Info Retrieved:")
  Console.info(disc_info, :attributes)

  # Our own backup path
  backup_location = JPT::CLI::MakeMkv::Runner.default_backup_path(found_drive[:disc_name])

  if File.directory?(backup_location)
    Console.info("Backup location already exists: #{backup_location}")
    # For now we skip
    Console.info("Skipping backup for #{found_drive.inspect}")
  else
    Console.info("Backing up Disc: #{found_drive.inspect} to #{backup_location}")
    Console.info("Unmounting #{found_drive[:device_name]}")

    `diskutil unmount #{found_drive[:device_name]}`

    JPT::CLI::MakeMkv::Runner.backup!(disc_id: disc_id, backup_path: backup_location)
  end

  Console.info("Backup Complete")
  # `diskutil eject #{found_drive[:device_name]}`
  # Extract the largest mpls title
  best_title = find_best_title(disc_info)

  destination_base = "/Volumes/BEBOP/MovieBackups/"
  puts disc_info.name.inspect
  destination = File.join(destination_base, disc_info.name)
  FileUtils.mkdir_p(destination)
  JPT::CLI::MakeMkv::Runner.mkv!(source: backup_location, destination_folder: destination, title_id: best_title.attributes[:id])
  Console.info("MKV Extraction Complete")
end

backup_all_disks
