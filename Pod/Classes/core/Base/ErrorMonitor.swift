//
//  ErrorMonitor.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 18/03/2018.
//

import Foundation

open class ErrorLogger: NSObject {
    public static var sharedInstance: ErrorLogger?

    @objc public static func defaultInstance() -> ErrorLogger {
        guard let sharedInstance = ErrorLogger.sharedInstance else {
            let logger = ErrorLogger()
            ErrorLogger.sharedInstance = logger
            return logger
        }
        return sharedInstance
    }

    open func log(error _: Error) {
        // Implement this in subclasses
    }
}

public extension Error {
    func errorDetails() -> [String: String] {
        let nserror = self as NSError
        var properties: [String: String] = [
            "domain": nserror.domain,
            "code": "\(nserror.code)",
        ]
        if let details = nserror.userInfo[NSLocalizedFailureReasonErrorKey], let detailsAsString = details as? String {
            properties["details"] = detailsAsString
        }
        return properties
    }
}
