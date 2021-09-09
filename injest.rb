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
                dst: '/mnt/disk3/photobox'
            }
            o = OptionParser.new
            o.on('--src srcDir') { |val| options[:src] = val }
            o.on('--dst destDir') { |val| options[:dst] = val }
            o.parse!(o.order!(ARGV) {})
            options
        end
    end

    def injest
        src = options[:src]
        Dir.glob("#{src}/**/*") do |file|
            next if File.directory?(file)
            next unless picture?(file)
            puts file
            injestPicture(file)
        end
    end

    def picture?(file)
        return true if /\.jpg/i.match?(file)
        return true if /\.png/i.match?(file)
        false
    end

    def injestPicture(file)
        e = Exiftool.new(file).to_hash
        created = e[:file_modify_date].to_time

        md5 = Digest::MD5.hexdigest(File.read(file))
        
        dst_dir = [
            options[:dst], 
            File::SEPARATOR,
            created.year, 
            File::SEPARATOR,
            zero_pad_ten(created.month), 
        ].join
        dst_name = [
            created.year,
            zero_pad_ten(created.month),
            zero_pad_ten(created.day),
            '-',
            zero_pad_ten(created.hour),
            zero_pad_ten(created.min),
            zero_pad_ten(created.sec),
            '-',
            md5,
            '-',
            File.basename(file).gsub(' ','')
        ].join

        FileUtils.mkdir_p(dst_dir, mode: 0770)
        dst_file = [dst_dir, File::SEPARATOR, dst_name].join

        FileUtils.cp(file, dst_file, preserve: true)
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
