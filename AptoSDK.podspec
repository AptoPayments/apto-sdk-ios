#
# Be sure to run `pod lib lint AptoCoreSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AptoSDK"
  s.version          = "3.20.0"
  s.summary          = "The Apto core platform iOS SDK."
  s.description      = <<-DESC
                        Apto iOS Core SDK
                       DESC
  s.homepage         = "https://github.com/AptoPayments/apto-sdk-ios.git"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors          = { "Apto Payments" => "mobile@aptopayments.com" }
  s.source           = { :git => "https://github.com/AptoPayments/apto-sdk-ios.git", :tag => "3.20.0" }

  s.platform = :ios
  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
  s.requires_arc = true

  s.module_name = 'AptoSDK'
  s.source_files = ['Pod/Classes/core/**/*.swift']
  s.resources = ["Pod/Assets/*.cer", "Pod/Localization/*.lproj", "Pod/CHANGELOG_core.md"]

  s.frameworks = 'Foundation', 'UIKit'
  s.dependency 'Alamofire', '~> 5.4.3'
  s.dependency 'Bond', '~> 7.6'
  s.dependency 'SwiftyJSON', '~> 5.0'
  s.dependency 'GoogleKit', '~> 0.3'
  s.dependency 'PhoneNumberKit', '~> 3.3.3'
  s.dependency 'TrustKit', '~> 1.6'
  s.dependency 'FTLinearActivityIndicator', '1.2.1'
  s.dependency 'AlamofireNetworkActivityIndicator', '~> 3.1'
  s.dependency 'Mixpanel-swift', '~> 3.2.0'
end
