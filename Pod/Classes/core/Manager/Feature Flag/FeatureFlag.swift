import Foundation
import LaunchDarkly

@propertyWrapper
public struct FeatureFlag<Value: LDFlagValueConvertible> {
  
  private let key: FeatureFlagKey
  private let defaultValue: Value
  private let featureFlag: LaunchDarkly
  
  init(_ key: FeatureFlagKey,
       defaultValue: Value,
       featureFlag: LaunchDarkly)
  {
    self.key = key
    self.defaultValue = defaultValue
    self.featureFlag = featureFlag
  }
  
  public init(_ key: FeatureFlagKey,
              defaultValue: Value) {
    self.init(key, defaultValue: defaultValue, featureFlag: .shared)
  }

  public var wrappedValue: Value {
    get {
      featureFlag.variation(key, defaultValue: defaultValue)
    }
  }
}
