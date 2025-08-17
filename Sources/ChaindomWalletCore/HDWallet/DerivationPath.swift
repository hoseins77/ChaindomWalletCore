//
//  DerivationPath.swift
//  ChaindomWalletCore
//
//  Created by Hossein on 1/15/25.
//

public struct DerivationPath {
    let purpose: Int
    let coinType: Int
    let account: Int
    let change: Int
    let addressIndex: Int

    /// Initialize with specific components
    init(coinType: Int, account: Int = 0, change: Int = 0, addressIndex: Int = 0) {
        self.purpose = 44
        self.coinType = coinType
        self.account = account
        self.change = change
        self.addressIndex = addressIndex
    }

    /// Shorthand initializer using the Blockchain enum
    static func forBlockchain(_ blockchain: Blockchain, account: Int = 0, change: Int = 0, addressIndex: Int = 0) -> DerivationPath {
        return DerivationPath(
            coinType: blockchain.coinType,
            account: account,
            change: change,
            addressIndex: addressIndex
        )
    }

    /// Generate the raw BIP44 path string
    var rawValue: String {
        return "m/\(purpose)'/\(coinType)'/\(account)'/\(change)/\(addressIndex)"
    }
}
