require File.dirname(__FILE__) + '/helper'

class TestExifData < Test::Unit::TestCase
    
  context 'with a clean exif-like hash' do 
    
    setup do       
      @h = {:a_key => 'ok' } 
      @exif = JointExif::ExifData.new(@h) 
    end
    
    should 'accept an hash on init' do         
      assert_equal @h.count, @exif.exif.count
    end
    
  end

end