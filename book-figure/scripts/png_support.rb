#!/usr/bin/env ruby

require "fileutils"
require "zlib"

module BookFigure
  class PngImage
    SIGNATURE = "\x89PNG\r\n\x1A\n".b

    attr_reader :width, :height, :pixels

    def initialize(width, height, pixels)
      @width = width
      @height = height
      @pixels = pixels.b
      expected = width * height * 4
      raise ArgumentError, "expected #{expected} RGBA bytes, got #{@pixels.bytesize}" unless @pixels.bytesize == expected
    end

    def self.read(path)
      source = File.binread(path)
      raise ArgumentError, "#{path} invalid PNG signature" unless source.start_with?(SIGNATURE)

      offset = SIGNATURE.bytesize
      header = nil
      compressed = +"".b

      while offset < source.bytesize
        length = source.byteslice(offset, 4).unpack1("N")
        type = source.byteslice(offset + 4, 4)
        data = source.byteslice(offset + 8, length)
        offset += 12 + length

        case type
        when "IHDR"
          header = data.unpack("NNCCCCC")
        when "IDAT"
          compressed << data
        when "IEND"
          break
        end
      end

      raise ArgumentError, "#{path} missing IHDR" unless header
      width, height, bit_depth, color_type, compression, filter_method, interlace = header
      channels = { 2 => 3, 6 => 4 }.fetch(color_type, nil)
      unless bit_depth == 8 && channels && compression.zero? &&
          filter_method.zero? && interlace.zero?
        raise ArgumentError, "#{path} must be 8-bit RGB or RGBA non-interlaced PNG"
      end

      pixels = decode_scanlines(
        Zlib::Inflate.inflate(compressed), width, height, channels
      )
      pixels = expand_rgb_to_rgba(pixels) if color_type == 2
      new(width, height, pixels)
    end

    def self.blank(width:, height:, rgba:)
      new(width, height, rgba.pack("C4") * (width * height))
    end

    def crop(x:, y:, width:, height:)
      raise ArgumentError, "crop width and height must be positive" unless width.positive? && height.positive?
      unless x >= 0 && y >= 0 && x + width <= @width && y + height <= @height
        raise ArgumentError, "crop lies outside image bounds"
      end

      row_bytes = width * 4
      cropped = +"".b
      height.times do |row|
        offset = ((y + row) * @width + x) * 4
        cropped << @pixels.byteslice(offset, row_bytes)
      end
      self.class.new(width, height, cropped)
    end

    def resize_fit(max_width:, max_height:)
      scale = [max_width.to_f / @width, max_height.to_f / @height, 1.0].min
      target_width = [(@width * scale).round, 1].max
      target_height = [(@height * scale).round, 1].max
      return self if target_width == @width && target_height == @height

      resized = String.new(capacity: target_width * target_height * 4, encoding: Encoding::BINARY)
      target_height.times do |target_y|
        source_y = [(target_y * @height / target_height.to_f).floor, @height - 1].min
        target_width.times do |target_x|
          source_x = [(target_x * @width / target_width.to_f).floor, @width - 1].min
          offset = (source_y * @width + source_x) * 4
          resized << @pixels.byteslice(offset, 4)
        end
      end
      self.class.new(target_width, target_height, resized)
    end

    def paste(image, x:, y:)
      unless x >= 0 && y >= 0 && x + image.width <= @width && y + image.height <= @height
        raise ArgumentError, "paste lies outside image bounds"
      end

      image.height.times do |row|
        destination = ((y + row) * @width + x) * 4
        source = row * image.width * 4
        @pixels[destination, image.width * 4] = image.pixels.byteslice(source, image.width * 4)
      end
      self
    end

    def write(path)
      FileUtils.mkdir_p(File.dirname(path))
      scanlines = +"".b
      stride = @width * 4
      @height.times do |row|
        scanlines << "\x00"
        scanlines << @pixels.byteslice(row * stride, stride)
      end

      ihdr = [@width, @height, 8, 6, 0, 0, 0].pack("NNCCCCC")
      png = +"".b
      png << SIGNATURE
      png << chunk("IHDR", ihdr)
      png << chunk("IDAT", Zlib::Deflate.deflate(scanlines, Zlib::BEST_COMPRESSION))
      png << chunk("IEND", "".b)
      File.binwrite(path, png)
      path
    end

    private

    def chunk(type, data)
      payload = type.b + data
      [data.bytesize].pack("N") + payload + [Zlib.crc32(payload)].pack("N")
    end

    class << self
      private

      def decode_scanlines(raw, width, height, channels)
        stride = width * channels
        expected = height * (stride + 1)
        raise ArgumentError, "inflated PNG data has unexpected size" unless raw.bytesize == expected

        output = Array.new(height) { Array.new(stride, 0) }
        height.times do |row_index|
          row_offset = row_index * (stride + 1)
          filter = raw.getbyte(row_offset)
          encoded = raw.byteslice(row_offset + 1, stride).bytes
          previous = row_index.zero? ? Array.new(stride, 0) : output[row_index - 1]
          output[row_index] = unfilter(encoded, previous, filter, channels)
        end
        output.flatten.pack("C*")
      end

      def expand_rgb_to_rgba(rgb)
        rgba = String.new(capacity: rgb.bytesize / 3 * 4, encoding: Encoding::BINARY)
        rgb.bytes.each_slice(3) { |red, green, blue| rgba << red << green << blue << 255 }
        rgba
      end

      def unfilter(encoded, previous, filter, bytes_per_pixel)
        reconstructed = Array.new(encoded.length, 0)
        encoded.each_index do |index|
          left = index >= bytes_per_pixel ? reconstructed[index - bytes_per_pixel] : 0
          up = previous[index]
          upper_left = index >= bytes_per_pixel ? previous[index - bytes_per_pixel] : 0
          predictor = case filter
                      when 0 then 0
                      when 1 then left
                      when 2 then up
                      when 3 then ((left + up) / 2).floor
                      when 4 then paeth(left, up, upper_left)
                      else raise ArgumentError, "unsupported PNG filter #{filter}"
                      end
          reconstructed[index] = (encoded[index] + predictor) & 0xff
        end
        reconstructed
      end

      def paeth(left, up, upper_left)
        estimate = left + up - upper_left
        distance_left = (estimate - left).abs
        distance_up = (estimate - up).abs
        distance_upper_left = (estimate - upper_left).abs
        return left if distance_left <= distance_up && distance_left <= distance_upper_left
        return up if distance_up <= distance_upper_left

        upper_left
      end

    end
  end
end
