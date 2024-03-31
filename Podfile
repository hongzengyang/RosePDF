# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
platform :ios, '13.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
    end
  end
end


def common_pods
  pod 'XYIAPKit',             :path => './3rd_paths/XYIAPKit'
  pod 'HZFoundationKit',      :path => './3rd_paths/HZFoundationKit'
  pod 'HZUIKit',              :path => './3rd_paths/HZUIKit'
  pod 'HZAssetsPicker',       :path => './3rd_paths/HZAssetsPicker'
  pod 'WCDB',                 :path => './3rd_paths/WCDB'
  
  pod 'GPUImage'
  pod 'YYModel',              '1.0.4'
  pod 'SDWebImage',           '5.15.7'
  pod 'ReactiveObjC',         '3.1.1'
  pod 'Masonry'
  pod 'SVProgressHUD',        '2.3.1'
  pod 'LookinServer',         :configurations => ['Debug']
  #  pod 'SDWebImageWebPCoder',  '0.11.0'
  #  pod 'YYCache',              '1.0.4'
  #  pod 'AFNetworking',         '4.0'
  #  pod 'MBProgressHUD',        '1.1.0'
  #  pod 'Bugly',                '2.5.93'
end

target 'RosePDF' do
  common_pods
end
