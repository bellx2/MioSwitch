platform :ios, '9.0'
use_frameworks!

def mioPods
	pod 'Alamofire', '~> 4.0'
	pod 'RxSwift'
	pod 'RxCocoa'
	pod 'APIKit', '~> 3.0'
	pod 'SwiftyJSON'
	pod 'Moya', '8.0.0-beta.3'
	pod 'Moya/RxSwift'
	pod 'Moya-ObjectMapper/RxSwift', :git => 'https://github.com/ivanbruel/Moya-ObjectMapper'
end

target 'MioSwitch' do
	mioPods
end

target 'MioWidget' do
	mioPods
end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['SWIFT_VERSION'] = '3.0'
		end
	end
end

plugin 'cocoapods-keys', {
  :project => "MioSwitch",
  :keys => [
    "DevID"
  ]}
