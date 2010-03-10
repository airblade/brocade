require 'barby'
require 'barby/outputter/png_outputter'

# A way of managing barcodes based closely on Thoughtbot's Paperclip.
# It consists of two parts: barcode creation and file management.
# Currently the file management is DIY but it might be better to delegate to Paperclip.
module Brocade

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def has_barcode
      send :include, InstanceMethods

      after_create  :create_barcode
      before_update :update_barcode
      after_destroy :destroy_barcode
    end
  end

  module InstanceMethods
    # Returns the name of the method (as a symbol) to call to get the
    # data to be barcoded.
    #
    # Override this in your model as appropriate.
    def barcodable
      :code
    end

    def symbology
      :code128
    end

    def create_barcode
      barcode = Barby::Code128B.new send(barcodable)
      path = barcode_path
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, 'wb') do |f|
        f.write barcode.to_png
      end
      FileUtils.chmod 0644, path
    end

    def update_barcode
      create_barcode if changed.include? barcodable
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
        end
      rescue Errno::EEXIST, Errno::ENOTEMPTY, Errno::ENOENT, Errno::EINVAL, Errno::ENOTDIR
        # Stop trying to remove parent directories
      rescue SystemCallError => e
        #log("There was an unexpected error while deleting directories: #{e.class}")
        # Ignore it
      end
    end

    def barcode_url
      "/system/barcodes/#{klass}/#{id}/#{symbology}.png"
    end

    def barcode_path
      "#{RAILS_ROOT}/public/system/barcodes/#{klass}/#{id}/#{symbology}.png"
    end

    def klass
      self.class.to_s.underscore.pluralize
    end
  end

end

if Object.const_defined? 'ActiveRecord'
  ActiveRecord::Base.send :include, Brocade
end
