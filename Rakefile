require 'logger'
require 'image_processing/vips'  # or 'image_processing/mini_magick'
require 'fileutils'
require 'sassc'  # Changed from 'sass' to 'sassc'

$logger = Logger.new(STDOUT)  # Changed to global variable with $
$logger.level = Logger::INFO

def compile_sass_copy
  $logger.info "Creating CSS copies..."
  begin
    input_file = '_sass/style.scss'
    output_dir = 'assets/css'
    
    $logger.info "Input file: #{input_file}"
    $logger.info "Output directory: #{output_dir}"
    
    unless File.exist?(input_file)
      $logger.error "Input file not found: #{input_file}"
      return
    end
    
    # Ensure output directory exists
    FileUtils.mkdir_p(output_dir)
    
    # Read the content of style.scss
    sass_content = File.read(input_file)
    $logger.info "Read #{sass_content.length} bytes from input file"
    
    # Create unminified copy
    result = SassC::Engine.new(sass_content, {
      syntax: :scss,
      style: :expanded,
      load_paths: ['_sass', 'node_modules']
    }).render
    
    output_file = File.join(output_dir, 'style.css')
    File.write(output_file, result)
    $logger.info "Created unminified file: #{output_file}"
    
    # Create minified copy
    result_min = SassC::Engine.new(sass_content, {
      syntax: :scss,
      style: :compressed,
      load_paths: ['_sass', 'node_modules']
    }).render
    
    output_file_min = File.join(output_dir, 'style.min.css')
    File.write(output_file_min, result_min)
    $logger.info "Created minified file: #{output_file_min}"
    
    $logger.info "✓ Successfully created CSS copies"
  rescue => e
    $logger.error "Error creating CSS copies: #{e.message}"
    $logger.error e.backtrace.join("\n")
  end
end

desc "Compile vendor files and generate Sass entries"
task :prepare do
  begin
    $logger.info "Running generate-sass-entries.rb..."  # Use global variable with $
    ruby "scripts/generate-sass-entries.rb"
    
    $logger.info "Running compile-vendor.rb..."  # Use global variable with $
    ruby "scripts/compile-vendor.rb"
    
    # Add CSS copy creation
    compile_sass_copy
  rescue => e
    $logger.error "Error during preparation: #{e.message}"  # Use global variable with $
    raise
  end
end

desc "Build the site"
task :build => [:prepare] do
  begin
    $logger.info "Building site for production..."  # Use global variable with $
    sh "JEKYLL_ENV=production bundle exec jekyll build" do |ok, res|
      unless ok
        $logger.error "Jekyll build failed with status: #{res.exitstatus}"  # Use global variable with $
        raise "Build failed"
      end
    end
  rescue => e
    $logger.error "Build error: #{e.message}"  # Use global variable with $
    raise
  end
end

desc "Serve the site"
task :serve => [:prepare] do
  begin
    $logger.info "Starting development server..."  # Use global variable with $
    sh "bundle exec jekyll serve --livereload --livereload-min-delay 5 --quiet" do |ok, res|
      unless ok
        $logger.error "Jekyll serve failed with status: #{res.exitstatus}"  # Use globalvariable with $
        raise "Serve failed"
      end
    end
  rescue => e
    $logger.error "Serve error: #{e.message}"  # Use global variable with $
    raise
  end
end

task :default => [:serve]

desc "Convert JPG and PNG images to WebP format"
task :convert_to_webp do
  begin
    $logger.info "Starting image conversion to WebP..."  # Use global variable with $

    # Configure paths - adjust these according to your project structure
    image_paths = [
      'assets/img/**/*.{jpg,jpeg,png}',
      'assets/images/**/*.{jpg,jpeg,png}',
      'src/assets/img/**/*.{jpg,jpeg,png}'
    ]

    total_converted = 0
    failed_conversions = []

    image_paths.each do |path_pattern|
      Dir.glob(path_pattern, File::FNM_CASEFOLD).each do |image_path|
        begin
          # Skip if WebP version already exists
          webp_path = image_path.sub(/\.(jpg|jpeg|png)$/i, '.webp')
          next if File.exist?(webp_path)

          # Create directory if it doesn't exist
          FileUtils.mkdir_p(File.dirname(webp_path))

          # Convert image
          $logger.info "Converting: #{image_path}"  # Use global variable with $
          processed = ImageProcessing::Vips
            .source(image_path)
            .convert("webp")
            .call(destination: webp_path)

          if File.exist?(webp_path)
            original_size = File.size(image_path)
            webp_size = File.size(webp_path)
            savings = ((original_size - webp_size).to_f / original_size * 100).round(2)
            
            $logger.info "✓ Converted: #{image_path}"  # Use global variable with $
            $logger.info "  Size reduction: #{savings}% (#{original_size} -> #{webp_size} bytes)"
            
            total_converted += 1
          else
            failed_conversions << image_path
          end
        rescue => e
          failed_conversions << image_path
          $logger.error "Error converting #{image_path}: #{e.message}"  # Use global variable with $
        end
      end
    end

    $logger.info "\nConversion Summary:"  # Use global variable with $
    $logger.info "Successfully converted: #{total_converted} images"
    
    if failed_conversions.any?
      $logger.error "Failed conversions (#{failed_conversions.size}):"  # Use global variable with $
      failed_conversions.each { |path| $logger.error "- #{path}" }  # Use global variable with $
    end

  rescue => e
    $logger.error "Conversion process failed: #{e.message}"  # Use global variable with $
    $logger.error e.backtrace.join("\n")  # Use global variable with $
    raise
  end
end

# Optional task to remove original images after conversion
desc "Remove original JPG/PNG files after WebP conversion"
task :remove_originals do
  begin
    $logger.info "Removing original image files..."  # Use global variable with $
    
    image_paths = [
      'assets/img/**/*.{jpg,jpeg,png}',
      'assets/images/**/*.{jpg,jpeg,png}',
      'src/assets/img/**/*.{jpg,jpeg,png}'
    ]

    total_removed = 0
    
    image_paths.each do |path_pattern|
      Dir.glob(path_pattern, File::FNM_CASEFOLD).each do |image_path|
        webp_path = image_path.sub(/\.(jpg|jpeg|png)$/i, '.webp')
        
        if File.exist?(webp_path)
          File.delete(image_path)
          $logger.info "Removed: #{image_path}"  # Use global variable with $
          total_removed += 1
        end
      end
    end

    $logger.info "Successfully removed #{total_removed} original images"  # Use global variable with $
  rescue => e
    $logger.error "Error removing original files: #{e.message}"  # Use global variable with $
    raise
  end
end

# Combined task to convert and optionally remove originals
# To only convert images to WebP (keeping originals):
#bundle exec rake convert_to_webp

# To convert images and remove originals:
#bundle exec rake optimize_images[true]
desc "Convert images to WebP and optionally remove originals"
task :optimize_images, [:remove_originals] => [:convert_to_webp] do |t, args|
  if args.remove_originals == 'true'
    Rake::Task["remove_originals"].invoke
  end
end
