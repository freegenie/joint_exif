module JointExif

  class ExifData

    # TODO: add further know rational arrays here
    RationalSep = '/'
    GpsArrays = [:gps_latitude, :gps_longitude, :gps_time_stamp]

    attr_reader :gps

    def initialize(value={})
      @value = {}
      rationals = GpsArrays.dup

      value.symbolize_keys!

      # remove data types we don't want/cannot to save
      value.delete_if do |k, v|
        ![Fixnum, Float, String, Rational, Array].include?(v.class)
      end

      value.delete_if do |k, v|
        v.is_a?(Array) and !GpsArrays.include?(k.to_sym)
      end

      value.each_pair do |k, v|
        rationals << k if v.is_a?(Rational)
      end

      if value[:gps_latitude] && value[:gps_latitude_ref] && \
          value[:gps_longitude] && value[:gps_longitude_ref]

        @gps = JointExif::GpsMath.new(
          self.class.force_rational(value[:gps_latitude]) ,
            value[:gps_latitude_ref],
          self.class.force_rational(value[:gps_longitude]) ,
            value[:gps_longitude_ref]
        )

      end

      @value = {:exif => value, :rationals => rationals }
    end


    def to_hash
      @value
    end

    def rationals
      (@value[:rationals] || GpsArrays).map(&:to_sym)
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

      def self.force_rational(array_value)
        out = array_value.map do |value|        
          value.is_a?(Rational) ? value : string_to_rational(value.to_s)
        end
        out
      end
      
      def self.string_to_rational(value)
        raise "Must be a string" unless value.is_a?(String)
        Rational(*value.split(RationalSep).map(&:to_i))
      end
      
      # checks the value has to be converted back to rational
      def convert(key)
        if rationals.include?(key)
          if GpsArrays.include?(key)
            exif[key].map {|n| string_to_rational(n) }
          else
            string_to_rational(exif[key])
          end
        else
          exif[key]
        end
      end

      def self.from_mongo(value)
        return nil if value.nil?
        return value if value.is_a?(JointExif::ExifData)

        raise "Unexpected data type", value.class.to_s unless value.is_a?(BSON::OrderedHash)

        out = HashWithIndifferentAccess.new(value)

        out[:rationals] ||= GpsArrays.dup
        out[:exif]      ||= {}
        out[:exif].symbolize_keys!

        out[:exif].each_pair do |k,v|
          k = k.to_sym 
          if out[:rationals].include?(k)
            if GpsArrays.include?(k)              
              v = v.map {|n| string_to_rational(n) }
            else
              v = string_to_rational(v)
            end
          end
          out[:exif].update(k => v)
        end
        ExifData.new(out[:exif])
      end

      def self.to_mongo(value)        
        return nil if value.nil?
        return value if value.is_a?(BSON::OrderedHash)
        to_be_saved = {}
        
        value.exif.each do |k,v|
          k = k.to_sym
          if value.rationals.include?(k)            
            if GpsArrays.include?(k)
              v = v.map(&:to_s)
            else
              v = v.to_s
            end
          end
          to_be_saved.update(k => v)
        end

        HashWithIndifferentAccess.new({:exif => to_be_saved, :rationals => value.rationals })
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