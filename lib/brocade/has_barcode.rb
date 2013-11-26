require 'active_support/core_ext'
require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

# A way of managing barcodes based closely on Thoughtbot's Paperclip.
# It consists of two parts: barcode creation and file management.
# Currently the file management is DIY but it might be better to delegate to Paperclip.
module Brocade

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def has_barcode(options = {})
      cattr_accessor :options
      self.options = options

      # Lazily load.
      send :include, InstanceMethods

      after_create  :create_barcode
      before_update :update_barcode
      after_destroy :destroy_barcode
    end
  end

  # Wrap the methods below in a module so we can include them
  # only in the ActiveRecord models which declare `has_brocade`.
  module InstanceMethods
    # Returns the name of the method (as a symbol) to call to get the
    # data to be barcoded.
    #
    # Override this in your model as appropriate.
    def barcodable
      :code
    end

    # Returns a Code128 barcode instance.
    #
    # opts:
    # :subset - specify the Code128 subset to use ('A', 'B', or 'C').
    def barcode(opts = {})
      data = format_for_subset_c_if_applicable send(barcodable)
      if (subset = opts[:subset])
        case subset
        when 'A'; Barby::Code128A.new data
        when 'B'; Barby::Code128B.new data
        when 'C'; Barby::Code128C.new data
        end
      else
        most_efficient_barcode_for data
      end
    end

    # Writes a barcode PNG image.
    #
    # opts:
    # :subset - specify the Code128 subset to use ('A', 'B', or 'C').
    # remaining options passed through to PNGOutputter.
    def create_barcode(opts = {})
      path = barcode_path
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, 'wb') do |f|
        f.write barcode(opts).to_png(self.class.options.merge(opts))
      end
      FileUtils.chmod(0666 &~ File.umask, path)
    end

    def update_barcode(opts = {})
      create_barcode(opts) if changed.include? barcodable
    end

    def destroy_barcode
      path = barcode_path
      begin
        FileUtils.rm path if File.exist? path
      rescue Errno::ENOENT => e
        # Ignore file-not-found; let everything else pass.
      end
      begin
        while true
          path = File.dirname path
          FileUtils.rmdir path
          break if File.exists?(path)  # Ruby 1.9.2 does not raise if the removal failed.
        end
      rescue Errno::EEXIST, Errno::ENOTEMPTY, Errno::ENOENT, Errno::EINVAL, Errno::ENOTDIR, Errno::EACCES
        # Stop trying to remove parent directories
      rescue SystemCallError => e
        # Ignore it
      end
    end

    def barcode_url
      "/system/barcodes/#{klass}/#{partitioned_id}/#{symbology}.png"
    end

    def barcode_path
      "#{::Rails.root}/public/system/barcodes/#{klass}/#{partitioned_id}/#{symbology}.png"
    end

    private

    def klass
      self.class.to_s.underscore.pluralize
    end

    # Returns the id in a split path form.
    # E.g. Returns 001/234 for an id of 1234.
    def partitioned_id
      # 1,000,000 records is enough for now.
      ("%06d" % id).scan(/\d{3}/).join('/')
    end

    def most_efficient_barcode_for(data)
      Barby::Code128C.new data
    rescue ArgumentError
      begin
        Barby::Code128B.new data
      rescue ArgumentError
        Barby::Code128A.new data
      end
    end

    def symbology
      :code128
    end

    def format_for_subset_c_if_applicable(data)
      stringified_data = "#{data}"
      return data unless stringified_data =~ /^\d+$/
      return data if stringified_data.length.even?
      "0#{stringified_data}"
    end
  end

end

if Object.const_defined? 'ActiveRecord'
  ActiveRecord::Base.send :include, Brocade
end
