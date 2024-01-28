#
# Be sure to run `pod lib lint HZIAPKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HZIAPKit'
  s.version          = '0.0.0'
  s.summary          = 'HZIAPKit'
  s.homepage         = 'xxxxxx'
  # s.screenshots     = 'https://github.com/keshiim/Swift_learn_CoreGraphics/blob/master/screenshot/draw.gif', 'https://github.com/keshiim/Swift_learn_CoreGraphics/blob/master/screenshot/text.gif', 'https://github.com/keshiim/Swift_learn_CoreGraphics/blob/master/screenshot/text2.gif', 'https://github.com/keshiim/Swift_learn_CoreGraphics/blob/master/screenshot/clip.gif'
  # s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.license      = "MIT"
  s.author           = { 'hx' => 'hzy' }  
  
  s.source_files = '**/*.{m,h}'
  s.source       = { :git => "", :tag => "#{s.version}" }

  s.ios.deployment_target = '13.0'

end
