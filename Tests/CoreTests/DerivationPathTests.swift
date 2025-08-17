//
//  BIP44Tests.swift
//  ChaindomWalletCore
//
//  Created by Hossein on 1/15/25.
//


import Testing
@testable import ChaindomWalletCore

@Suite("DerivationPathTests")
struct DerivationPathTests {
    
    @Test("Test Shorthand Initialization")
    func testShorthandInitialization() async throws {
        let ethPath = DerivationPath.forBlockchain(.ethereum)
        #expect(ethPath.rawValue == "m/44'/60'/0'/0/0")

        let btcPath = DerivationPath.forBlockchain(.bitcoin, account: 1, addressIndex: 5)
        #expect(btcPath.rawValue == "m/44'/0'/1'/0/5")
    }
    
    @Test("Test Raw Value Consistency")
    func testRawValueConsistency() async throws {
        let ethPath = DerivationPath(coinType: 60, account: 0, change: 0, addressIndex: 0)
        #expect(ethPath.rawValue == "m/44'/60'/0'/0/0")
    }
}
