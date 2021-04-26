//
//  IssueCardDesign.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 23/4/21.
//

import Foundation

public struct IssueCardDesign {
    public let designKey: String?
    public let qrCode: String?
    public let extraEmbossingLine: String?
    public let imageURL: String?
    public let additionalImageURL: String?

    public init(designKey: String?, qrCode: String?, extraEmbossingLine: String?, imageURL: String?, additionalImageURL: String?) {
        self.designKey = designKey
        self.qrCode = qrCode
        self.extraEmbossingLine = extraEmbossingLine
        self.imageURL = imageURL
        self.additionalImageURL = additionalImageURL
    }
}
