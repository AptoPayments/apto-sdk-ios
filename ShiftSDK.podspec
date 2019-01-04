#
# Be sure to run `pod lib lint ShiftSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ShiftSDK"
  s.version          = "1.1.16"
  s.summary          = "The Shift platform iOS SDK."
  s.description      = <<-DESC
                        Shift iOS SDK
                       DESC
  s.homepage         = "https://github.com/ShiftFinancial/shift-sdk-ios"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors          = { "Ivan Oliver" => "ivan@shiftpayments.com", "Takeichi Kanzaki" => "takeichi@shiftpayments.com" }
  s.source           = { :git => "https://github.com/ShiftFinancial/shift-sdk-ios.git", :tag => "1.1.16" }

  s.platform = :ios
  s.ios.deployment_target = '10.0'
  s.swift_version = '4.0'
  s.requires_arc = true

  s.module_name = 'ShiftSDK'
  s.source_files = ['Pod/Classes/**/*.swift','Pod/Vendor/CardIO/include/*.h']
  s.resources = ["Pod/Assets/*.png","Pod/Assets/*.cer", "Pod/Assets/*.css", "Pod/Localization/*.lproj", "Pod/Assets/*.xcassets", "Pod/Fonts/*.ttf"]

  s.preserve_paths = 'Pod/Vendor/CardIO/lib/*.a'
  s.vendored_libraries = 'Pod/Vendor/CardIO/lib/libCardIO.a', 'Pod/Vendor/CardIO/lib/libopencv_core.a', 'Pod/Vendor/CardIO/lib/libopencv_imgproc.a'
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => "Pod/Vendor/CardIO/include", 'OTHER_LDFLAGS' => "-lc++ -ObjC", 'LIBRARY_SEARCH_PATHS' => "Pod/Vendor/CardIO/lib" }

  s.frameworks = 'UIKit', 'CoreLocation', 'Accelerate', 'AudioToolbox', 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'CoreVideo', 'Foundation', 'MobileCoreServices', 'OpenGLES', 'QuartzCore', 'Security', 'LocalAuthentication', 'CallKit'
  s.dependency 'Alamofire', '~> 4.7'
  s.dependency 'SwiftyJSON', '~> 4.0'
  s.dependency 'SnapKit', '~> 4.0'
  s.dependency 'Bond', '~> 6.8'
  s.dependency 'HTAutocompleteTextField', '~> 1.3'
  s.dependency 'GoogleKit', '~> 0.3'
  s.dependency 'PhoneNumberKit', '~> 2.5'
  s.dependency 'TTTAttributedLabel', '~> 2.0'
  s.dependency 'UIScrollView-InfiniteScroll', '~> 1.0'
  s.dependency 'TrustKit', '~> 1.5'
  s.dependency 'Stripe', '~> 12.0'
  s.dependency 'Down', '~> 0.5'
  s.dependency 'Plaid', '~> 1.1'
  s.dependency 'PullToRefreshKit', '~> 0.8'
  s.dependency 'SwiftToast', '~> 1.1'
  s.dependency 'FTLinearActivityIndicator', '~> 1.1'
  s.dependency 'AlamofireNetworkActivityIndicator', '~> 2.2'
end
