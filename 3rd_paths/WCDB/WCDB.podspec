

Pod::Spec.new do |s|

  s.name         = "WCDB"
  s.version      = "0.0.1"
  s.summary      = "A short description of WCDB."

  s.description  = "description"

  s.homepage     = "http://EXAMPLE/WCDB"
  

  s.license      = "MIT"
  

  s.author             = { "hzy" => "hzy.com" }
  
  s.platform     = :ios, "13.0"

  
  s.source       = { :git => "", :tag => "#{s.version}" }

  s.public_header_files = "**/*.h"

  vendored_frameworks = '*.framework'

  s.vendored_frameworks = vendored_frameworks

  s.prefix_header_contents = <<-EOS

EOS


end
