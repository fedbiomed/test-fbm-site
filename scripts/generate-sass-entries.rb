#!/usr/bin/env ruby
require 'fileutils'

def create_entry_file(source_dir, dest_dir, type)
  Dir.glob("_sass/#{type}/*.scss").each do |file|
    basename = File.basename(file, '.scss')
    entry_content = "---\n---\n@import \"#{type}/#{basename}\";"
    
    File.write("#{dest_dir}/#{basename}.scss", entry_content)
    puts "Created entry file for #{basename}"
  end
end

# Create directories if they don't exist
FileUtils.mkdir_p('assets/css/colors')
FileUtils.mkdir_p('assets/css/fonts')

# Generate entry files for colors and fonts
create_entry_file('_sass/colors', 'assets/css/colors', 'colors')
create_entry_file('_sass/fonts', 'assets/css/fonts', 'fonts')
