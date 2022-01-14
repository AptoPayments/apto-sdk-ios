//
//  Content.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 18/04/2017.
//
//

public struct NativeContent: Equatable, Codable {
    public let asset: String?
    public let backgroundImage: String?
    public let backgroundColor: String?
    public let darkBackgroundColor: String?
}

public extension NativeContent {
    var dynamicBackgroundColor: UIColor? {
        guard let color = UIColor.colorFromHexString(backgroundColor),
              let darkColor = UIColor.colorFromHexString(darkBackgroundColor)
        else {
            return nil
        }
        return UIColor.dynamicColor(light: color, dark: darkColor)
    }
}

public enum Content: Equatable {
    case plainText(String)
    case markdown(String)
    case externalURL(URL)
    case nativeContent(NativeContent)

    mutating func replaceInURL(string: String, with: String?) {
        switch self {
        case let .externalURL(url):
            if let with = with {
                guard let newURL = URL(string: url.absoluteString.replace([string: with])) else {
                    return
                }
                self = .externalURL(newURL)
            } else {
                guard let newURL = URL(string: url.absoluteString.replace([string: ""])) else {
                    return
                }
                self = .externalURL(newURL)
            }
        default:
            return
        }
    }

    var isPlainText: Bool {
        if case .plainText = self {
            return true
        }
        return false
    }

    public var isEmpty: Bool {
        switch self {
        case let .plainText(text):
            return text.isEmpty
        case let .markdown(markdown):
            return markdown.isEmpty
        case .externalURL:
            return false
        case .nativeContent:
            return false
        }
    }
}

extension Content: Codable {
    private enum CodingKeys: String, CodingKey {
        case plainText, markdown, externalURL, nativeContent
    }

    enum ContentCodingError: Error {
        case decoding(String)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(String.self, forKey: .plainText) {
            self = .plainText(value)
            return
        }
        if let value = try? values.decode(String.self, forKey: .markdown) {
            self = .markdown(value)
            return
        }
        if let value = try? values.decode(URL.self, forKey: .externalURL) {
            self = .externalURL(value)
            return
        }
        if let value = try? values.decode(NativeContent.self, forKey: .nativeContent) {
            self = .nativeContent(value)
            return
        }

        throw ContentCodingError.decoding("\(dump(values))")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .plainText(text):
            try container.encode(text, forKey: .plainText)
        case let .markdown(value):
            try container.encode(value, forKey: .markdown)
        case let .externalURL(url):
            try container.encode(url, forKey: .externalURL)
        case let .nativeContent(value):
            try container.encode(value, forKey: .nativeContent)
        }
    }
}
