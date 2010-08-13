module JointExif
    
  class ExifData
    
    def initialize(value)
      raise "not an exif jpeg or tiff input" unless (value.is_a?(EXIF::JPEG) or value.is_a?(EXIF::TIFF))
    end
  
    def self.from_mongo(value)
      value
    end
  
    def self.to_mongo(value)
      
      raise 
      value
      
      # Cannot save rational fields, change them to string
      value.each_pair do |key, value|             
        if value.is_a?(Rational)
          value[key] = value.to_s
        end
      end
      
      value.delete_if do |key, value| 
        ![Fixnum, Float, String].include?(value.class)
      end
      
      value 
      
    end
  
  end
  
end