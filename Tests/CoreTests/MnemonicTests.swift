//
//  BIP39Tests.swift
//  ChaindomWalletCore
//
//  Created by Hossein on 1/7/25.
//
import Testing
@testable import ChaindomWalletCore

@Suite("Mnemonic Tests")
class MnemonicTests {
    
    @Test("Test Mnemonic Generation")
    func testMnemonicGeneration() async throws {
        let mnemonic = Mnemonic.generate(strength: 128)
        #expect(mnemonic != nil)
        #expect(mnemonic.split(separator: " ").count == 12)
    }
    
    @Test("Test Mnemonic Validation")
    func testMnemonicValidation() async throws {
        let validMnemonic = "mercy shock future conduct text sure police veteran orient bus truck prison"
        #expect(Mnemonic.isValid(mnemonic: validMnemonic) == true)

        let invalidMnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon"
        #expect(Mnemonic.isValid(mnemonic: invalidMnemonic) == false)
    }
    
    @Test("Test Mnemonic To Seed Conversion")
    func testMnemonicToSeedConversion() async throws {
        let mnemonic = "mercy shock future conduct text sure police veteran orient bus truck prison"
        
        let seed = Mnemonic.toSeed(mnemonic: mnemonic, passphrase: "")
        #expect(seed?.hex == "6a958976aa6fefcd2e9cc11ab71e3f0e5c842bf4d9e2f89ece1c3460cb900751206b72aea7145ade9627309501ac895ea77568408c4d228b49a5f76b54e09b68")
        
        let seedWithPassphrase = Mnemonic.toSeed(mnemonic: mnemonic, passphrase: "passphrase")
        #expect(seedWithPassphrase?.hex == "cba81165653ac41fc074ae68544f87a819183e0db09f3e5a7e4aba29d2b948d158569e144c222dbfff71618b3cbc073f8e8db5a197b1ee8137ade0f31684e10c")
    }
}
