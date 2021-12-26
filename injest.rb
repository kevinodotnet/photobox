#!/usr/bin/env ruby

require 'optparse'
require 'pry'
require 'exiftool'
require 'digest/md5'



class Photobox
    def options
        @options ||= begin
            options = {
                src: '/mnt/disk3/Dropbox',
                dst: '/mnt/disk3/photobox',
                no_changes: false,
                prefix: nil,
                no_date_prefix: false,
                no_md5: false,
            }
            o = OptionParser.new
            o.on('--src srcDir') { |val| options[:src] = val }
            o.on('--dst destDir') { |val| options[:dst] = val }
            o.on('--no_changes') { |val| options[:no_changes] = true }
            o.on('--prefix prefix') { |val| options[:prefix] = val }
            o.on('--no_date_prefix') { |val| options[:no_date_prefix] = true }
            o.on('--no_md5') { |val| options[:no_md5] = true }
            o.parse!(o.order!(ARGV) {})
            options
        end
    end

    def injest
        src = options[:src]
        Dir.glob("#{src}/**/*", File::FNM_DOTMATCH) do |file|
            next if File.directory?(file)
            next unless picture?(file)
            injestPicture(file)
        end
    end

    def picture?(file)
        return true if /\.gif/i.match?(file)
        return true if /\.jpg/i.match?(file)
        return true if /\.jpeg/i.match?(file)
        return true if /\.tiff/i.match?(file)
        return true if /\.tif/i.match?(file)
        return true if /\.aif/i.match?(file)
        return true if /\.avi/i.match?(file)
        return true if /\.png/i.match?(file)
        return true if /\.mov/i.match?(file)
        return true if /\.mp4/i.match?(file)
        return true if /\.mpeg/i.match?(file)
        return true if /\.mpg/i.match?(file)
        return true if /\.bmp/i.match?(file)
        return true if /\.m4v/i.match?(file)
        return true if /\.3gp/i.match?(file)
        return true if /\.flv/i.match?(file)
        return true if /\.psd/i.match?(file)
        #return true if /\.pdf/i.match?(file)
        false
    end

    def injestPicture(file)
        # # e = Exiftool.new(file).to_hash
        # created = Time.now # e[:file_modify_date].to_time
        created = File.mtime(file)

        md5 = options[:no_md5] ? nil : Digest::MD5.hexdigest(File.read(file))
        
        dst_dir = [options[:dst]]
        dst_dir << options[:prefix] 
        dst_dir << [created.year, zero_pad_ten(created.month)] unless options[:no_date_prefix]
        dst_dir = dst_dir.flatten.compact.join(File::SEPARATOR)

        dst_name = [
            created.year,
            zero_pad_ten(created.month),
            zero_pad_ten(created.day),
            '-',
            zero_pad_ten(created.hour),
            zero_pad_ten(created.min),
            zero_pad_ten(created.sec),
            '-'
        ]
        unless options[:no_md5]
            dst_name << md5
            dst_name << '-'
        end
        dst_name << ['r', rand(1000..9999),'-']
        dst_name << File.basename(file).gsub(' ','')
        dst_name = dst_name.flatten.compact.join

        dst_file = [dst_dir, File::SEPARATOR, dst_name].join

        # puts "  #{file}"
        puts "#{dst_file}"
        return if options[:no_changes]

        FileUtils.mkdir_p(dst_dir, mode: 0770)
        FileUtils.mv(file, dst_file)
    end

    private

    def zero_pad_ten(val)
        val = val.to_i
        if val < 10
            "0#{val}"
        else
            val
        end
    end
end

photobox = Photobox.new
photobox.injest
