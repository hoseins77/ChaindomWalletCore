//
//  BlockChain.swift
//  ChaindomWalletCore
//
//  Created by Hossein on 1/15/25.
//
import Foundation

/// Enum representing supported blockchains
public enum Blockchain {
    case ethereum
    case bitcoin
    case solana
    case binanceSmartChain

    /// Returns the coin type for the blockchain.
    var coinType: Int {
        switch self {
        case .ethereum: return 60
        case .bitcoin: return 0
        case .solana: return 501
        case .binanceSmartChain: return 60
        }
    }
}
