import Foundation

protocol PaymentSourcesStorageProtocol {
    func addPaymentSource(_ apiKey: String,
                          userToken: String,
                          _ paymentSource: PaymentSourceRequest,
                          callback: @escaping Result<PaymentSource, NSError>.Callback)

    func getPaymentSources(_ apiKey: String,
                           userToken: String,
                           request: PaginationQuery?,
                           callback: @escaping Result<[PaymentSource], NSError>.Callback)
    func deletePaymentSource(_ apiKey: String,
                             userToken: String,
                             paymentSourceId: String,
                             callback: @escaping Result<Void, NSError>.Callback)
    func pushFunds(_ apiKey: String,
                   userToken: String,
                   request: PushFundsRequest,
                   callback: @escaping Result<PaymentResult, NSError>.Callback)
}

struct PaymentSourcesStorage: PaymentSourcesStorageProtocol {
    private let transport: JSONTransport

    init(transport: JSONTransport) {
        self.transport = transport
    }

    func addPaymentSource(_ apiKey: String,
                          userToken: String,
                          _ paymentSource: PaymentSourceRequest,
                          callback: @escaping Result<PaymentSource, NSError>.Callback)
    {
        let url = URLWrapper(baseUrl: transport.environment.pciVaultBaseUrl(),
                             url: JSONRouter.paymentSources,
                             urlParameters: nil)
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
        transport.post(url,
                       authorization: auth,
                       parameters: buildAddPaymentSource(with: paymentSource),
                       filterInvalidTokenResult: true) { result in
            switch result {
            case let .success(json):
                guard let paymentSource = json.paymentSource() else {
                    callback(.failure(ServiceError(code: .jsonError)))
                    return
                }
                callback(.success(paymentSource))
            case let .failure(error):
                callback(.failure(error))
            }
        }
    }

    func getPaymentSources(_ apiKey: String,
                           userToken: String,
                           request: PaginationQuery?,
                           callback: @escaping Result<[PaymentSource], NSError>.Callback)
    {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(),
                             url: JSONRouter.paymentSources,
                             urlParameters: buildUrlParametersForPaymentSources(with: request))
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
        transport.get(url,
                      authorization: auth,
                      parameters: nil,
                      headers: nil,
                      acceptRedirectTo: nil,
                      filterInvalidTokenResult: true) { result in
            switch result {
            case let .success(json):
                callback(.success(json.paymentSources))
            case let .failure(error):
                callback(.failure(error))
            }
        }
    }

    func deletePaymentSource(_ apiKey: String,
                             userToken: String,
                             paymentSourceId: String,
                             callback: @escaping Result<Void, NSError>.Callback)
    {
        let url = URLWrapper(baseUrl: transport.environment.baseUrl(),
                             url: JSONRouter.paymentSources,
                             urlTrailing: paymentSourceId,
                             urlParameters: nil)
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
        transport.delete(url,
                         authorization: auth,
                         parameters: ["payment_source_id": paymentSourceId as AnyObject],
                         filterInvalidTokenResult: true) { result in
            switch result {
            case .success:
                callback(.success(()))
            case let .failure(error):
                callback(.failure(error))
            }
        }
    }

    func pushFunds(_ apiKey: String,
                   userToken: String,
                   request: PushFundsRequest,
                   callback: @escaping Result<PaymentResult, NSError>.Callback)
    {
        let url = URLWrapper(baseUrl: transport
            .environment
            .baseUrl().replacingOccurrences(of: "/v1", with: ""),
            url: JSONRouter.paymentSourcesPushFunds,
            urlParameters: [":paymentSourceId": request.paymentSourceId])
        let auth = JSONTransportAuthorization.accessAndUserToken(projectToken: apiKey, userToken: userToken)
        transport.post(url,
                       authorization: auth,
                       parameters: buildPushFunds(with: request), filterInvalidTokenResult: true) { result in
            switch result {
            case let .success(json):
                guard let paymentResult = json.paymentResult else {
                    callback(.failure(ServiceError(code: .jsonError)))
                    return
                }
                callback(.success(paymentResult))
            case let .failure(error):
                callback(.failure(error))
            }
        }
    }

    // MARK: - Helpers

    private func buildUrlParametersForPaymentSources(with request: PaginationQuery?) -> [String: String] {
        var parameters = [String: String]()
        if let limit = request?.limit {
            parameters["limit"] = String(limit)
        }
        if let startingAfter = request?.startingAfter {
            parameters["starting_after"] = startingAfter
        }
        if let endingBefore = request?.endingBefore {
            parameters["ending_before"] = endingBefore
        }
        return parameters
    }

    private func buildPushFunds(with request: PushFundsRequest) -> [String: AnyObject]? {
        guard let currency = request.amount.currency.value, let amount = request.amount.amount.value else {
            return nil
        }
        return [
            "amount": [
                "currency": currency as AnyObject,
                "amount": amount as AnyObject,
            ] as AnyObject,
            "balance_id": request.balanceId as AnyObject,
        ]
    }

    private func buildAddPaymentSource(with request: PaymentSourceRequest) -> [String: AnyObject]? {
        switch request {
        case let .card(cardRequest):
            return [
                "type": "card" as AnyObject,
                "card": [
                    "pan": cardRequest.pan,
                    "cvv": cardRequest.cvv,
                    "exp_date": cardRequest.expirationDate,
                    "last_four": cardRequest.lastFour,
                    "postal_code": cardRequest.zipCode,
                ] as AnyObject,
            ]
        case let .bankAccount(bankAccountRequest):
            return [
                "type": "bank_account" as AnyObject,
                "bank_account": [
                    "routing_number": bankAccountRequest.routingNumber,
                    "account_number": bankAccountRequest.accountNumber,
                ] as AnyObject,
            ]
        }
    }
}
