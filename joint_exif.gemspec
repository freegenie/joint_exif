# encoding: UTF-8
require File.expand_path('../lib/joint_exif/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "joint_exif"
  s.summary     = %Q{Exif data for Joint plugin.}
  s.description = %Q{Exif data for Joint plugin.}
  s.email       = "freegenie@gmail.com"
  # s.homepage    = "http://github.com/freegenie/joint_exif"
  s.require_path = 'lib'
  s.authors     = ["Fabrizio Regini"]
  s.version     = JointExif::Version
  s.files       = Dir.glob("{lib,test}/**/*") + %w[LICENSE README.rdoc]
  s.test_files  = %w(test/test_exif_data.rb test/test_joint_exif.rb)

  s.add_dependency 'exifr', '1.0.2'
  s.add_dependency 'joint', '>= 0.3.2'
  s.add_dependency 'wand', '>= 0.2.1'
  s.add_dependency 'mime-types'
  s.add_dependency 'mongo_mapper', '>= 0.7.4'

  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'mocha'
  # s.add_development_dependency 'jnunemaker-matchy'
end