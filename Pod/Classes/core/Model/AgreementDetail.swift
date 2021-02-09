//
//  AgreementDetail.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 22/1/21.
//

import Foundation

public struct AgreementDetail: Equatable {
    public let idStr: String?
    public let agreementKey: String?
    public let userAction: UserActionType?
    public let actionRecordedAt: Date?
}
