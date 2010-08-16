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

      after_save :handle_exif_data

      key "#{name}_exif_extracted_at", Float
      key "#{name}_exif_data", JointExif::ExifData
      
      
      self.exif_attachment_names << name

    end
  end

  module InstanceMethods

    private
    
      def exif_data_for_image(name)
        readable  = self.class.find!(self.id).send(name)
        callable  = jpeg?(name) ? EXIFR::JPEG : EXIFR::TIFF
        # This used to be self.send(name)
        # but does not work with reload
        exif      = callable.new(StringIO.new(readable.read))                     
        ExifData.new(exif.to_hash)        
      end

      def handle_exif_data
        self.exif_attachment_names.each do |name|         
          if !send("#{name}?")
            # File has been removed
            clear_exif_data(name)                        
          else                         
            # debugger
            next unless extract_exif_data?(name)
            next unless (jpeg?(name) or tiff?(name))   
            data_key  = "#{name}_exif_data".to_sym
            time_key  = "#{name}_exif_extracted_at".to_sym
            set( data_key => exif_data_for_image(name) , time_key => Time.now.to_f )
          end          
        end
        # TODO: how can I avoid this?         
        reload 
      end
      
      def clear_exif_data(name)
        set("#{name}_exif_extracted_at".to_sym => nil, "#{name}_exif_data".to_sym => nil )
      end

      def jpeg?(name)
        send("#{name}_type") =~ /(jpeg|jpg)/i
      end

      def tiff?(name)
        send("#{name}_type") =~ /tiff/i
      end

      def extract_exif_data?(name)
        # send("#{name}_exif_extracted_at").nil? 
        true
      end

  end



  class JointMissing < Exception ; end
  class AttachmentMissing < Exception ; end

end
