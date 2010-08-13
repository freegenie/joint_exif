module JointExif
  
  class GpsMath 
    
    attr_accessor :latitude, :longitude
    
    def initialize(lat, lat_ref, long, long_ref)

       latitude  = lat[0].to_f  + (lat[1].to_f / 60) + (lat[2].to_f / 3600)       
       longitude = long[0].to_f + (long[1].to_f / 60) + (long[2].to_f / 3600) 
       
       longitude = longitude * -1 if long_ref == "W"   # (W is -, E is +)
       latitude  = latitude  * -1 if lat_ref == "S"      # (N is +, S is -)
       
       @latitude = latitude
       @longitude = longitude
    end
    
  end
  
end