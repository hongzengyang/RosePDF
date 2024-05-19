# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
platform :ios, '13.0'
install! 'cocoapods', :disable_input_output_paths => true
use_modular_headers!

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end


def pods_jobs
  pod 'XYIAPKit',             :path => './3rd_paths/XYIAPKit'
  pod 'HZFoundationKit',      :path => './3rd_paths/HZFoundationKit'
  pod 'HZUIKit',              :path => './3rd_paths/HZUIKit'
  pod 'HZAssetsPicker',       :path => './3rd_paths/HZAssetsPicker'
  pod 'HZDetectKit',          :path => './3rd_paths/HZDetectKit'
  pod 'WCDB',                 :path => './3rd_paths/WCDB'

  pod 'GPUImage',             '0.1.7'
  pod 'YYModel',              '1.0.4'
  pod 'YYCategories',         '1.0.4'
  pod 'SDWebImage',           '5.19.1'
  pod 'ReactiveObjC',         '3.1.1'
  pod 'Masonry',              '1.1.0'
  pod 'SVProgressHUD',        '2.3.1'
  pod 'LookinServer',         :configurations => ['Debug']
  pod 'FirebaseAnalytics',    '10.24.0'
  pod 'Firebase/AnalyticsWithoutAdIdSupport','10.24.0'
  pod 'FirebaseCrashlytics',  '10.24.0'


end

target 'PDFConverter' do
  pods_jobs
end
