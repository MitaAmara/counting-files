require 'digest'

class CalculateFileContent
    def initialize(directory)
        @directory = directory
        @content_count = Hash.new(0)
        @file_content = {}
    end

    def scan_directory
        Dir.glob(File.join(@directory, '**', '*')).each do |file|
            next unless File.file?(file)
            
            file_hash = calculate_hash(file)
            @content_count[file_hash] += 1
            @file_content[file_hash] ||= file
        end
    end

    def calculate_hash(file)
        sha256 = Digest::SHA256.new
        File.open(file, 'rb') do |f|
            buffer = ''
            while f.read(1024 * 1024, buffer)
                sha256.update(buffer)
            end
        end
        sha256.hexdigest
    end

    def search_content
        max_content, max_count = @content_count.max_by { |_, count| count }
        sample_file = @file_content[max_content]

        content_preview = File.read(sample_file, 100)
        [content_preview, max_count]
    end

    def display_result
        content_preview, max_count = search_content
        puts "#{content_preview} #{max_count}"
    end

    def run
        scan_directory
        display_result
    end
end

if ARGV.empty?
    puts "Input directory path! => ruby calculate_file_content.rb <directory_path>"
    exit 1
end

directory_path = ARGV[0]
unless Dir.exist?(directory_path)
    puts "Error! Directory '#{directory_path}' does not exist."
    exit 1
end

counter = CalculateFileContent.new(directory_path)
counter.run