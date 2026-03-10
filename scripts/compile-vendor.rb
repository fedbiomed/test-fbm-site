#!/usr/bin/env ruby
require 'fileutils'

# Paths configuration
PATHS = {
  vendor_js: [
    #  # Bootstrap JS
    Dir.glob('assets/js/vendor/*.js') # All other vendor JS files
  ].flatten,
  vendor_css: Dir.glob('assets/css/vendor/*.css'), # Vendor CSS files
  output: {
    js: 'assets/js',
    css: 'assets/css'
  }
}

def compile_js
  puts "\nCompiling JavaScript files:"
  
  # Create banner with timestamp
  banner = "/* Compiled vendor scripts - #{Time.now.strftime('%Y-%m-%d %H:%M:%S')} */\n\n"
  
  # Read and concatenate JS files with separators
  combined_js = banner + PATHS[:vendor_js].map { |file| 
    puts "- Processing: #{file}"
    content = File.read(file)
    "\n\n/* ==================== #{File.basename(file)} ==================== */\n#{content}"
  }.join("\n")
  
  # Write output
  output_file = "#{PATHS[:output][:js]}/plugins.js"
  File.write(output_file, combined_js)
  puts "✓ Successfully created: #{output_file}"
rescue => e
  puts "× Error processing JavaScript: #{e.message}"
  raise
end

def compile_css
  puts "\nCompiling CSS files:"
  
  begin
    # Read and concatenate CSS files
    combined_css = PATHS[:vendor_css].map { |file|
      puts "- Processing: #{file}"
      File.read(file)
    }.join("\n")
    
    # Write concatenated CSS
    output_file = "#{PATHS[:output][:css]}/plugins.css"
    File.write(output_file, combined_css)
    puts "✓ Successfully created: #{output_file}"
  rescue => e
    puts "× Error processing CSS: #{e.message}"
    raise
  end
end

begin
  puts "=== Starting Vendor Files Compilation ==="
  
  # Ensure output directories exist
  FileUtils.mkdir_p(PATHS[:output][:js])
  FileUtils.mkdir_p(PATHS[:output][:css])
  
  compile_js
  compile_css
  
  puts "\n✓ Vendor compilation completed successfully!"
rescue => e
  puts "\n× Compilation failed: #{e.message}"
  puts e.backtrace
  exit 1
end
