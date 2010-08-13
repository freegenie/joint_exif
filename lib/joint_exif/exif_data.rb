module JointExif

  class ExifData
    
    # TODO: add further know rational arrays here 
    GpsArrays = [:gps_latitude, :gps_longitude, :gps_time_stamp]
    
    attr_reader :gps

    def initialize(value={})
      rationals = GpsArrays.dup
      
      value.symbolize_keys!
      
      # remove data types we don't want/cannot to save
      value.delete_if do |k, v|
        ![Fixnum, Float, String, Rational, Array].include?(v.class)
      end
      
      value.delete_if do |k, v|
        v.is_a?(Array) and !GpsArrays.include?(k)
      end

      value.each_pair do |k, v|
        rationals << k if v.is_a?(Rational)
      end
      
      if value[:gps_latitude] && value[:gps_latitude_ref] && \
          value[:gps_longitude] && value[:gps_longitude_ref]
        
        @gps = JointExif::GpsMath.new(
          value[:gps_latitude], 
          value[:gps_latitude_ref], 
          value[:gps_longitude], 
          value[:gps_longitude_ref])
          
      end
      
      @value = {}
      @value = {:exif => value, :rationals => rationals }
    end

    def to_hash
      @value
    end

    def rationals
      @value[:rationals] || GpsArrays
    end

    def rationals=(value)
      @value[:rationals] = value
    end

    def exif=(value)
      @value[:exif] = value
    end

    def exif
      @value[:exif] || {}
    end

    
    private

      # checks the value has to be converted back to rational
      def convert(key)
        if rationals.include?(key)
          if GpsArrays.include?(key)
            exif[key].map {|n| n.to_r }
          else 
            exif[key].to_r
          end
        else
          exif[key]
        end
      end

      def self.from_mongo(value)
        return nil if value.nil?                
        return value if value.is_a?(JointExif::ExifData)

        raise "Unexpected data type", value.class.to_s unless value.is_a?(BSON::OrderedHash)
        
        value.symbolize_keys!
        value[:rationals] ||= GpsArrays.dup
        value[:exif]      ||= {}
        
        value[:exif].symbolize_keys!
        
        value[:exif].each_pair do |k,v|
          if value[:rationals].include?(k)
            if GpsArrays.include?(k)
              v = v.map {|n| n.to_r}
            else 
              v = v.to_r
            end            
          end          
          value[:exif].update(k => v)
        end        
        ExifData.new(value[:exif])
      end

      def self.to_mongo(value)
        return nil if value.nil?
        return value if value.is_a?(BSON::OrderedHash)
        to_be_saved = {}        
        value.exif.each_pair do |k,v|
          if value.rationals.include?(k)
            if GpsArrays.include?(k)
              v = v.map {|n| n.to_s }
            else 
              v = v.to_s
            end
          end
          to_be_saved.update(k => v)
        end
        {:exif => to_be_saved, :rationals => value.rationals }
      end

      def method_missing(method, *args, &block)
        if exif.include?(method)
          convert(exif[method])
        elsif method == :count
          exif.count
        else
          super(method, *args, &block)
        end
      end

  end

end