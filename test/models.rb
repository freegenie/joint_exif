

class Photo  
  include MongoMapper::Document 
  plugin Joint
  plugin JointExif  
  key :title, String 
  attachment :image
  exif_for :image
end

