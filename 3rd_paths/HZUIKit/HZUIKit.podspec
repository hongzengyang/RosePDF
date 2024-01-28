#
# Be sure to run `pod lib lint HZUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HZUIKit'
  s.version          = '0.0.0'
  s.summary          = 'HZUIKit'
  s.homepage         = 'xxxxxx'
  # s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.license      = "MIT"
  s.author           = { 'h' => 'hzy' }  
  
  s.source_files = '**/*.{m,h}'
  s.source       = { :git => "", :tag => "#{s.version}" }

  s.ios.deployment_target = '13.0'

end
