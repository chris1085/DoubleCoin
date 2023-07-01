# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'

target 'DoubleCoin' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for DoubleCoin
	pod 'SwiftLint'
  pod 'MJRefresh'
  pod 'Kingfisher'
  pod 'IQKeyboardManagerSwift'
  pod 'NVActivityIndicatorView'
  pod 'JGProgressHUD'
  pod 'Alamofire'
  pod 'TinyConstraints'
  pod 'Charts'
  pod 'iCarousel'
  pod 'Starscream'
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
        end
      end
   end
end
