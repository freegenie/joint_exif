require File.dirname(__FILE__) + '/helper'

class TestJointExif < Test::Unit::TestCase
  
  def setup 
    MongoMapper.database.collections.each {|c| c.remove }
  end
  
  # def teardown
  #   unless @openfiles.nil? 
  #     @openfiles.each do |f|
  #     f.close 
  #     end
  #   end
  # end
    
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
  
  # should 'save a photo with an image file' do    
  #     photo = Photo.new(:image => open_file('bikes.jpg'))
  #     assert photo.save
  #   end

  context 'given an image with exif data inside' do 
    
    setup do 
      @photo = Photo.create(:image => open_file('bikes.jpg') )
    end
    
    should 'save exif data for the attachment' do 
      assert @photo.image_exif_data.count > 0
      assert @photo.image_exif_data.exif[:focal_plane_x_resolution] != nil 
    end
  
    should 'save the extraction time' do 
      assert @photo.image_exif_extracted_at.is_a?(Time)
    end
  
    should 'not extract exif on after_save if already there' do 
      t = @photo.image_exif_extracted_at
      @photo.save
      assert_equal t, @photo.image_exif_extracted_at
    end
  
    should 'save again and keep exif data' do 
      @photo.save      
      assert @photo.image_exif_data.count > 0       
    end
  
    should 'load exif data when laoding from mongo' do 
      photo = Photo.first
      assert photo.image_exif_data.count > 0             
    end
  
    should 'load from the database and convert Rational numbers' do 
      photo = Photo.first
      assert photo.image_exif_data.exif[:f_number].is_a?(Rational)      
    end

    should 'extract exif data again if exif_extracted_at is nil' do       
      # @photo.reload      
      # @photo.image_exif_extracted_at = nil           
      # @photo.save  
      
      photo = Photo.first 
      photo.image_exif_extracted_at = nil 
      photo.save
      assert photo.image_exif_extracted_at.is_a?(Time)
    end
    
  end
  
  
  
end