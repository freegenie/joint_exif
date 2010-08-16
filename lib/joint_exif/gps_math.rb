module JointExif
  
  class GpsMath 
    
    attr_reader :latitude, :longitude
    
    def initialize(lat, lat_ref, long, long_ref)
      
        @lat = lat 
        @long = long
        @lat_h,  @lat_m,  @lat_s    = lat 
        @long_h, @long_m, @long_s   = long        
        @lat_ref  = lat_ref
        @long_ref = long_ref
        
        validate_input
        
       _latitude  = @lat_h.to_f  + (@lat_m.to_f / 60) + (@lat_s.to_f / 3600)       
       _longitude = @long_h.to_f + (@long_m.to_f / 60) + (@long_s.to_f / 3600) 
       
       _longitude = _longitude * -1 if long_ref == "W"   # (W is -, E is +)
       _latitude  = _latitude  * -1 if lat_ref == "S"      # (N is +, S is -)
       
       # debugger 
              
       @latitude = _latitude
       @longitude = _longitude
       
    end
    
    def validate_input      
      (@lat + @long).each {|item| raise "Coordinates must be Rational" unless item.is_a?(Rational) } 
    end
    
  end
  
end