//
//  Result.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 25/01/16.
//  Copyright © 2019 Apto Payments. All rights reserved.
//

import Foundation

public extension Result {
    typealias Callback = (_ result: Result<Success, Failure>) -> Void

    var value: Success? {
        guard case let .success(value) = self else {
            return nil
        }
        return value
    }

    var error: Failure? {
        guard case let .failure(error) = self else {
            return nil
        }
        return error
    }

    var isSuccess: Bool {
        return value != nil ? true : false
    }

    var isFailure: Bool {
        return !isSuccess
    }
}
