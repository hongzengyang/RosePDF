
Pod::Spec.new do |s|
  s.name             = 'HZDetectKit'
  s.version          = '0.0.0'
  s.summary          = 'HZDetectKit'
  s.homepage         = 'xxxxxx'
  # s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.license      = "MIT"
  s.author           = { 'h' => 'hzy' }  
  

  s.source_files  = "**/*.{h,m,mm,c,cpp,hpp}"
  s.source       = { :git => "", :tag => "#{s.version}" }

  s.ios.deployment_target = '13.0'
  
  s.dependency 'OpenCV2','4.3.0'

end
