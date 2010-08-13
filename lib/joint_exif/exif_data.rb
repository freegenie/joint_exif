module JointExif

  class ExifData

    def initialize(value={})
      rationals = []
      value.symbolize_keys!
      # remove data types we don't want/cannot to save
      value.delete_if do |key, value|
        ![Fixnum, Float, String, Rational].include?(value.class)
      end

      value.each_pair do |key, value|
        rationals << key  if value.is_a?(Rational)
      end

      @value = {}
      @value = {:exif => value, :rationals => rationals }
    end

    def to_hash
      @value
    end

    def rationals
      @value[:rationals] || []
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
          exif[key].to_r
        else
          exif[key]
        end
      end

      def self.from_mongo(value)
        return nil if value.nil?                
        return value if value.is_a?(JointExif::ExifData)

        raise "Unexpected data type", value.class.to_s unless value.is_a?(BSON::OrderedHash)
        
        value.symbolize_keys!
        value[:rationals] ||= []
        value[:exif]      ||= {}
        
        value[:exif].symbolize_keys!
        
        value[:exif].each_pair do |k,v|
          v = value[:rationals].include?(k) ? v.to_r : v
          value[:exif].update(k => v)
        end        
        ExifData.new(value[:exif])
      end

      def self.to_mongo(value)
        return nil if value.nil?
        return value if value.is_a?(BSON::OrderedHash)
        to_be_saved = {}        
        value.exif.each_pair do |k,v|
          v = value.rationals.include?(k) ? v.to_s : v
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