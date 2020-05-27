import Foundation
import LaunchDarkly

struct LaunchDarkly {
  static let shared = LaunchDarkly()
  
  private let client: LDClient
  
  init(client: LDClient = .shared) {
    self.client = client
  }
  
  func initialize() {
    let configuration = LDConfig(mobileKey: "<< MOBILE API KEY >>")
    client.startCompleteWhenFlagsReceived(config: configuration)
  }
 
  func variation<T: LDFlagValueConvertible>(_ key: FeatureFlagKey, defaultValue: T) -> T {
    client.variation(forKey: key.value, fallback: defaultValue)
  }
}
