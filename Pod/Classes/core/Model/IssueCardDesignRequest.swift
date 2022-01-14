//
//  IssueCardDesignRequest.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 23/4/21.
//

import Foundation

public struct IssueCardDesignRequest {
    public let designKey: String?
    public let qrCode: String?
    public let extraEmbossingLine: String?
    public let imageURL: String?
    public let additionalImageURL: String?

    internal init(designKey: String?,
                  qrCode: String?,
                  extraEmbossingLine: String?,
                  imageURL: String?, additionalImageURL: String?)
    {
        self.designKey = designKey
        self.qrCode = qrCode
        self.extraEmbossingLine = extraEmbossingLine
        self.imageURL = imageURL
        self.additionalImageURL = additionalImageURL
    }

    public func toJSON() -> [String: AnyObject] {
        [
            "design_key": designKey as AnyObject,
            "qr_code": qrCode as AnyObject,
            "extra_embossing_line": extraEmbossingLine as AnyObject,
            "image_url": imageURL as AnyObject,
            "additional_image_url": additionalImageURL as AnyObject,
        ]
    }
}

struct IssueCardDesignRequestMapper {
    private init() {}

    public static func map(from design: IssueCardDesign) -> IssueCardDesignRequest {
        IssueCardDesignRequest(designKey: design.designKey,
                               qrCode: design.qrCode,
                               extraEmbossingLine: design.extraEmbossingLine,
                               imageURL: design.imageURL,
                               additionalImageURL: design.additionalImageURL)
    }
}
