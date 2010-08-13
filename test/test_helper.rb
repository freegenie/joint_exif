require 'ap'
require 'rubygems'
require 'mongo_mapper'
require 'joint'
require 'shoulda'

$LOAD_PATH.unshift( File.expand_path(File.dirname(__FILE__), '../lib' ))

require File.dirname(__FILE__) + '/models'

MongoMapper.database = 'joint_exif_test'

class Test::Unit::TestCase 
  
  def open_file(name)
    @openfiles ||= []
    file = File.open(File.join( File.dirname(__FILE__), 'data', name), 'r')
    @openfiles << file
    file
  end
  
  def setup 
    @openfiles = []    
  end
  
end