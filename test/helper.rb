# $LOAD_PATH.unshift( File.expand_path( File.dirname(__FILE__) + '/../lib' ) )

# require 'ap'
require 'rubygems'
require 'mongo_mapper'
require 'joint'
require 'shoulda'

# require 'joint_exif'
# require 'mocha'
# require 'ruby-debug'

# require File.dirname(__FILE__) + '/models'

MongoMapper.database = 'joint_exif_test'

# 
# class Test::Unit::TestCase 
#     # 
#     # def open_file(name)
#     #   @openfiles ||= []
#     #   file = File.open(File.join( File.dirname(__FILE__), 'data', name), 'r')
#     #   @openfiles << file
#     #   file
#     # end
#     # 
#     # def setup 
#     #   @openfiles = []    
#     # end
#     # 
#     # def teardown
#     #   unless @openfiles.nil? 
#     #     @openfiles.each do |f|
#     #       f.close 
#     #     end
#     #   end
#     # end
#   
# end