import Foundation

public class WebTokenError: NSError {
    public init() {
        let errorMessage = "error.transport.undefined".podLocalized()
        let userInfo: [String: Any] = [NSLocalizedDescriptionKey: errorMessage]
        super.init(domain: "com.aptopayments.sdk.error.web_token", code: 5555, userInfo: userInfo)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
