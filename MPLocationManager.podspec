#
# Be sure to run `pod lib lint MPLocationManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MPLocationManager'
  s.version          = '1.2.2'
  s.summary          = 'Simple library to get location updates and all relavent things.'

  s.homepage         = 'https://github.com/mohakparmar/MPLocationManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mohakparmar' => 'mohak@infoware.ws' }
  s.source           = { :git => 'https://github.com/mohakparmar/MPLocationManager.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'MPLocationManager/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MPLocationManager' => ['MPLocationManager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'CoreLocation'
  # s.dependency 'AFNetworking', '~> 2.3'
end
