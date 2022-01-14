//
//  UIImage.swift
//  AptoCoreSDK
//
//  Created by Takeichi Kanzaki on 15/07/2019.
//

import Foundation

class PodBundle: Bundle {
    public static func bundle() -> Bundle {
        return Bundle(for: classForCoder())
    }
}

extension UIImage {
    func toBase64() -> String {
        return pngData()!.base64EncodedString() // swiftlint:disable:this force_unwrapping
    }
}
