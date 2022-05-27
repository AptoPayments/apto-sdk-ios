//
//  DummyVoipImpl.swift
//  AptoSDK
//
//  Created by Fabio Cuomo on 26/11/21.
//

import Foundation

public class DummyVoipImpl: NSObject, VoIPCallProtocol {
    private var startedAt: Date?
    private var callback: Result<Void, NSError>.Callback?

    public var isMuted: Bool = false
    public var isOnHold: Bool = false
    public var timeElapsed: TimeInterval = 0

    public func call(_ destination: VoIPToken, callback: @escaping Result<Void, NSError>.Callback) {}

    public func sendDigits(_ digits: VoIPDigits) {}

    public func disconnect() {}
}
