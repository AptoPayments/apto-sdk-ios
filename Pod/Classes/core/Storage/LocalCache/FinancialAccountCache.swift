//
//  FinancialAccountCache.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 03/12/2018.
//

protocol FinancialAccountCacheProtocol {
    func cachedFundingSource(accountId: String) -> FundingSource?
    func cachedFundingSources() -> [String: FundingSource]?
    func saveFundingSource(_ fundingSource: FundingSource, accountId: String)
    func cachedCard(accountId: String) -> Card?
    func saveCard(_ financialAccount: FinancialAccount)
    func cachedCards() -> [String: Card]?
    func cachedTransactions(accountId: String) -> [Transaction]?
    func saveTransactions(_ transactions: [Transaction], accountId: String)
    func cachedTransactions() -> [String: [Transaction]]?
    func cachedFundingSources(accountId: String) -> [FundingSource]?
    func cachedFundingSourceList() -> [String: [FundingSource]]?
    func saveFundingSources(_ fundingSources: [FundingSource], accountId: String)
}

class FinancialAccountCache: FinancialAccountCacheProtocol {
    private let localCacheFileManager: LocalCacheFileManagerProtocol

    init(localCacheFileManager: LocalCacheFileManagerProtocol) {
        self.localCacheFileManager = localCacheFileManager
    }

    func cachedFundingSource(accountId: String) -> FundingSource? {
        guard let fundingSources = cachedFundingSources() else { return nil }
        return fundingSources[accountId]
    }

    func saveFundingSource(_ fundingSource: FundingSource, accountId: String) {
        DispatchQueue.global().async { [weak self] in
            do {
                guard let self = self else { return }
                var fundingSources = self.cachedFundingSources() ?? [String: FundingSource]()
                fundingSources[accountId] = fundingSource
                let data = try PropertyListEncoder().encode(fundingSources)
                try self.localCacheFileManager.write(data: data, filename: .fundingSourceFilename)
                // Update existing card funding source
                if let card = self.cachedCard(accountId: accountId) {
                    card.fundingSource = fundingSource
                    self.saveCard(card)
                }
            } catch {
                ErrorLogger.defaultInstance().log(error: error)
            }
        }
    }

    func cachedFundingSources() -> [String: FundingSource]? {
        do {
            if let data = try localCacheFileManager.read(filename: .fundingSourceFilename) {
                // First we try to decode the data as CustodianWallet, if not possible then try to decode then as the base
                // FundingSource class. This is ugly but the only options Codable give us to not erase the subclass type.
                do {
                    return try PropertyListDecoder().decode([String: CustodianWallet].self, from: data)
                } catch {
                    do {
                        return try PropertyListDecoder().decode([String: FundingSource].self, from: data)
                    } catch {
                        return nil
                    }
                }
            }
        } catch {
            return nil
        }
        return nil
    }

    func cachedCard(accountId: String) -> Card? {
        guard let cards = cachedCards() else { return nil }
        return cards[accountId]
    }

    func saveCard(_ financialAccount: FinancialAccount) {
        guard let card = financialAccount as? Card else { return }
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            var cards = self.cachedCards() ?? [String: Card]()
            cards[card.accountId] = card
            do {
                let data = try PropertyListEncoder().encode(cards)
                try self.localCacheFileManager.write(data: data, filename: .cardsFilename)
            } catch {
                ErrorLogger.defaultInstance().log(error: error)
            }
        }
    }

    func cachedCards() -> [String: Card]? {
        do {
            if let data = try localCacheFileManager.read(filename: .cardsFilename) {
                let cards = try PropertyListDecoder().decode([String: Card].self, from: data)
                return cards
            }
        } catch {
            return nil
        }
        return nil
    }

    func cachedTransactions(accountId: String) -> [Transaction]? {
        guard let transactions = cachedTransactions() else { return nil }
        return transactions[accountId]
    }

    func saveTransactions(_ transactions: [Transaction], accountId: String) {
        let cached = cachedTransactions() ?? [String: [Transaction]]()
        guard let currentTransactions = cached[accountId], !currentTransactions.isEmpty else {
            store(transactions: transactions, accountId: accountId, currentContent: cached)
            return
        }
        guard !transactions.isEmpty else { return }
        var allTransaction = currentTransactions
        transactions.forEach { transaction in
            if let index = allTransaction.firstIndex(where: { transaction.transactionId == $0.transactionId }) {
                allTransaction[index] = transaction
            } else {
                allTransaction.append(transaction)
            }
        }
        allTransaction.sort { $0.createdAt > $1.createdAt }
        store(transactions: allTransaction, accountId: accountId, currentContent: cached)
    }

    func cachedTransactions() -> [String: [Transaction]]? {
        do {
            if let data = try localCacheFileManager.read(filename: .transactionsFilename) {
                return try PropertyListDecoder().decode([String: [Transaction]].self, from: data)
            }
        } catch {
            return nil
        }
        return nil
    }

    func cachedFundingSources(accountId: String) -> [FundingSource]? {
        guard let fundingSources = cachedFundingSourceList() else { return nil }
        return fundingSources[accountId]
    }

    func cachedFundingSourceList() -> [String: [FundingSource]]? {
        do {
            if let data = try localCacheFileManager.read(filename: .fundingSourceListFilename) {
                // First we try to decode the data as CustodianWallet, if not possible then try to decode then as the base
                // FundingSource class. This is ugly but the only options Codable give us to not erase the subclass type.
                do {
                    return try PropertyListDecoder().decode([String: [CustodianWallet]].self, from: data)
                } catch {
                    do {
                        return try PropertyListDecoder().decode([String: [FundingSource]].self, from: data)
                    } catch {
                        return nil
                    }
                }
            }
        } catch {
            return nil
        }
        return nil
    }

    func saveFundingSources(_ fundingSources: [FundingSource], accountId: String) {
        DispatchQueue.global().async { [weak self] in
            do {
                guard let self = self else { return }
                var current = self.cachedFundingSourceList() ?? [String: [FundingSource]]()
                current[accountId] = fundingSources
                let data = try PropertyListEncoder().encode(current)
                try self.localCacheFileManager.write(data: data, filename: .fundingSourceListFilename)
            } catch {
                ErrorLogger.defaultInstance().log(error: error)
            }
        }
    }

    // MARK: - Private methods

    private func store(transactions: [Transaction], accountId: String, currentContent: [String: [Transaction]]) {
        DispatchQueue.global().async { [weak self] in
            do {
                guard let self = self else { return }
                var content = currentContent
                content[accountId] = transactions
                let data = try PropertyListEncoder().encode(content)
                try self.localCacheFileManager.write(data: data, filename: .transactionsFilename)
            } catch {
                ErrorLogger.defaultInstance().log(error: error)
            }
        }
    }
}
