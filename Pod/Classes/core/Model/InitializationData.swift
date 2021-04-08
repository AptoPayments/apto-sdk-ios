//
//  InitializationData.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 12/3/21.
//

import Foundation

@objc public class InitializationData: NSObject {
    /// A string up to 256 characters that will be attached to the user after signing up.  Optional parameter.
    public var userMetadata: String? = nil
    /// A string up to 256 characters that will be attached to the card after issuance.  Optional parameter.
    public var cardMetadata: String? = nil
    /// A string that identifies the custodian uid. Optional parameter.
    public var custodianId: String? = nil
    
    /**
     Initializes a new Metadata with the provided additional data.

     - Parameters:
        - userMetadata: A string up to 256 characters that will be attached to the user after signing up. Optional parameter.
        - cardMetadata: A string up to 256 characters that will be attached to the card after issuance. Optional parameter.
        - custodianId: A string that identifies the custodian uid. Optional parameter.

     - Returns: A new instance of Metadata.
     */
    public init(userMetadata: String?, cardMetadata: String?, custodianId: String?) {
        self.userMetadata = userMetadata
        self.cardMetadata = cardMetadata
        self.custodianId = custodianId
    }
}
