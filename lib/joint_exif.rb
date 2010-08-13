# encoding: UTF-8
require 'exifr'
require 'joint_exif/exif_data'
require 'joint_exif/gps_math'
require 'mongo'

module JointExif

  def self.configure(model)
    
    unless model.included_modules.include?(Joint::InstanceMethods)
      raise JointMissing.new('Need to plug Joint before ExifJoint')
    end

    model.class_inheritable_accessor :exif_attachment_names
    model.exif_attachment_names = Set.new

  end

  module ClassMethods

    def exif_for(name, options = {})
      options.symbolize_keys!
      name = name.to_sym

      unless self.attachment_names.include?(name)
        raise AttachmentMissing.new("#{name} must be a joint attachment.") \
      end

      after_save :extract_exif_data

      key "#{name}_exif_extracted_at", Time
      key "#{name}_exif_data", JointExif::ExifData

      self.exif_attachment_names << name

    end
  end

  module InstanceMethods

    private

      def extract_exif_data
        
        self.exif_attachment_names.each do |name|
          
          next unless extract_exif_data?(name)
          next unless (jpeg?(name) or tiff?(name))
          next unless send("#{name}?")

          callable  = jpeg?(name) ? EXIFR::JPEG : EXIFR::TIFF
          data_key  = "#{name}_exif_data".to_sym
          time_key  = "#{name}_exif_extracted_at".to_sym
          
          # This used to be self.send(name)
          # but does not work with reload
          readable  = self.class.find!(self.id).send(name)
            
          exif      = callable.new(StringIO.new(readable.read))                     
          exif_data = ExifData.new(exif.to_hash)
          set( data_key => exif_data , time_key => Time.now )
          # TODO: how can I avoid this? 
          reload 
        end
      end

      def jpeg?(name)
        send("#{name}_type") =~ /(jpeg|jpg)/i
      end

      def tiff?(name)
        send("#{name}_type") =~ /tiff/i
      end

      def extract_exif_data?(name)
        send("#{name}_exif_extracted_at").nil?
      end

  end



  class JointMissing < Exception ; end
  class AttachmentMissing < Exception ; end

end
