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

      # after_save :handle_exif_data

      key "#{name}_exif_extracted_at", Time
      key "#{name}_exif_data", JointExif::ExifData
      key "#{name}_exif_token", String
      
      self.exif_attachment_names << name

    end
  end

  module InstanceMethods

    private

      def handle_exif_data
        self.exif_attachment_names.each do |name|         
          if send(name).nil? 
            clear_exif_data(name)
          else 
            # if send("#{name}?")
            next unless extract_exif_data?(name)
            next unless (jpeg?(name) or tiff?(name))   
                                 
            readable  = self.class.find!(self.id).send(name)
            
            # next if send("#{name}_exif_token") == readable.client_md5 
            
            callable  = jpeg?(name) ? EXIFR::JPEG : EXIFR::TIFF
            data_key  = "#{name}_exif_data".to_sym
            time_key  = "#{name}_exif_extracted_at".to_sym
            token_key = "#{name}_exif_token".to_sym          
            # This used to be self.send(name)
            # but does not work with reload
            exif      = callable.new(StringIO.new(readable.read))                     
            exif_data = ExifData.new(exif.to_hash)

            set( data_key => exif_data , time_key => Time.now )

          # else 
          #   clear_exif_data(name)
          end          
        end
        # TODO: how can I avoid this?         
        # reload 
      end
      
      def clear_exif_data(name)
        set("#{name}_exif_extracted_at".to_sym => nil, "#{name}_exif_data".to_sym => nil, "#{name}_exif_token".to_sym => nil )
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
