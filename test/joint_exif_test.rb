require File.dirname(__FILE__) + '/test_helper'

class JointExifTest < Test::Unit::TestCase
  
  def setup 
    MongoMapper.database.collections.each {|c| c.remove }
  end
  
  def teardown
    unless @openfiles.nil? 
      @openfiles.each do |f|
      f.close 
      end
    end
  end
    
  should 'raise an exception if Joint is not loaded' do 
    assert_raise JointExif::JointMissing do 
      class PhotoWithoutJoint
        include MongoMapper::Document
        plugin JointExif
      end
    end
  end
  
  should 'raise attachment not found if attachment definition is missing' do 
    assert_raise JointExif::AttachmentMissing do 
      class PhotoWithoutAttachment
        include MongoMapper::Document
        plugin Joint
        plugin JointExif
        exif_for :image
      end      
    end
  end
  
  should 'save a photo with an image file' do    
    photo = Photo.new(:image => open_file('withEXIF.jpg'))
    assert photo.save
  end
  
  should "know if is a jpeg" do 
    photo = Photo.create(:image => open_file('withEXIF.jpg'))    
    # assert photo.jpeg?('image')
  end
  
  should 'save a photo with an image JPG file and save exif data' do 
    photo = Photo.create(:image => open_file('withEXIF.jpg'))
    photo.reload
    # assert photo.image_exif_data.count > 0
    # assert photo.image_exif_data[:focal_plane_x_resolution] != nil 
  end
  
  
  
end