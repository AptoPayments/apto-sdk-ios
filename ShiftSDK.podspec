#
# Be sure to run `pod lib lint ShiftSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ShiftSDK"
  s.version          = "1.1.14"
  s.summary          = "The Shift platform iOS SDK."
  s.description      = <<-DESC
                        Shift iOS SDK
                       DESC
  s.homepage         = "https://github.com/ShiftFinancial/shift-sdk-ios"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Ivan Oliver" => "ivan@shiftpayments.com" }
  s.source           = { :git => "https://github.com/ShiftFinancial/shift-sdk-ios.git", :tag => "1.1.14" }

  s.platform = :ios
  s.ios.deployment_target = '10.0'
  s.swift_version = '4.1'
  s.requires_arc = true

  s.module_name = 'ShiftSDK'
  s.source_files = ['Pod/Classes/**/*.swift','Pod/Vendor/CardIO/include/*.h']
  s.resources = ["Pod/Assets/*.png","Pod/Assets/*.cer", "Pod/Assets/*.css", "Pod/Localization/*.lproj", "Pod/Assets/*.xcassets", "Pod/Fonts/*.ttf"]

  s.preserve_paths = 'Pod/Vendor/CardIO/lib/*.a'
  s.vendored_libraries = 'Pod/Vendor/CardIO/lib/libCardIO.a', 'Pod/Vendor/CardIO/lib/libopencv_core.a', 'Pod/Vendor/CardIO/lib/libopencv_imgproc.a'
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => "Pod/Vendor/CardIO/include", 'OTHER_LDFLAGS' => "-lc++ -ObjC", 'LIBRARY_SEARCH_PATHS' => "Pod/Vendor/CardIO/lib" }

  s.frameworks = 'UIKit', 'CoreLocation', 'Accelerate', 'AudioToolbox', 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'CoreVideo', 'Foundation', 'MobileCoreServices', 'OpenGLES', 'QuartzCore', 'Security', 'LocalAuthentication', 'CallKit'
  s.dependency 'Alamofire'
  s.dependency 'SwiftyJSON'
  s.dependency 'SnapKit'
  s.dependency 'Bond'
  s.dependency 'HTAutocompleteTextField'
  s.dependency 'GoogleKit'
  s.dependency 'PhoneNumberKit'
  s.dependency 'TTTAttributedLabel'
  s.dependency 'UIScrollView-InfiniteScroll'
  s.dependency 'TrustKit'
  s.dependency 'Stripe'
  s.dependency 'Down'
  s.dependency 'Plaid'
  s.dependency 'PullToRefreshKit'
  s.dependency 'SwiftToast'

end
