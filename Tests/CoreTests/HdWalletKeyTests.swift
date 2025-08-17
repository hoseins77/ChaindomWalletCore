//
//  HdWalletKeyTests.swift
//  ChaindomWalletCore
//
//  Created by Hossein on 1/6/25.
//

import Foundation
import Testing
@testable import ChaindomWalletCore

@Suite("HdWalletKey Tests")
struct HdWalletKeyTests {
    
    typealias keyDerivationArguments = (path: String, publicKeyHex: String, privateKeyHex: String)
    
    @Test("Test Key Derivation", arguments: [
        (path: "m/44'/0'/0'/0/0",
         publicKeyHex: "034f0c96f46cbe4957b2f080793b9c6236f87043c2a90b418958f88613b2f27899",
         privateKeyHex: "61c926b9ccf2d3c5f6c76147cd3b640ed355dfb090b5b5aa019497b911f21d2d"),
        (path: "m/44'/60'/0'/0/0",
         publicKeyHex: "03c7f8dbe129d24dce4d467d5a555bcf1eec42204f6d576035d8c3716f1dd08965",
         privateKeyHex: "05b627332ff2f468d310313a94933cd4b595875b4e856146f20b4930d991103c"),
    ])
    func testKeyDerivation(_ args: keyDerivationArguments) async throws{
        let seedHexString = "c097b079262b98aae1818707a68946a8ff742ac37e2835e55af8a0cf1423943a8f6fbd243c52e6a4e91d59601daab9c8c5a508b2490b12171b9fdc4f21234da2"
        let seed = Data(hex: seedHexString) ?? Data()
        let key = HDWalletKey(seed: seed)

        let derivedKey = key?.derive(path: args.path)
        #expect(derivedKey?.publicKey.hex == args.publicKeyHex)
        #expect(derivedKey?.privateKey.hex == args.privateKeyHex)
    }

    @Test("Test Invalid Path Key Derivation")
    func testInvalidPathDerivation() async throws {
        let seed = Data(hex: "000102030405060708090a0b0c0d0e0f") ?? Data()
        let bip32 = HDWalletKey(seed: seed)

        let derivedKey = bip32?.derive(path: "invalid/path")
        #expect(derivedKey == nil)
    }
}
