//
//  Mnemonic.swift
//  ChaindomWalletCore
//
//  Created by Hossein on 1/7/25.
//
import Foundation
import CommonCrypto
import CryptoKit

struct Mnemonic {
    // Generates a mnemonic phrase with the given strength (e.g., 128 bits for 12 words).
    static func generate(strength: Int) -> String {
        guard [128, 160, 192, 224, 256].contains(strength) else {
            fatalError("Invalid strength. Must be one of 128, 160, 192, 224, 256.")
        }
        
        let byteCount = strength / 8
        let entropy = Data((0..<byteCount).map { _ in UInt8.random(in: 0...255) })
        return generateMnemonic(from: entropy)
    }
    
    // Validates if the given mnemonic is valid according to BIP-39 rules.
    static func isValid(mnemonic: String, wordList: BIP39WordList = EnglishWordList()) -> Bool {
        let words = mnemonic.split(separator: " ").map(String.init)
        
        // 1) The valid BIP-39 sizes are 12, 15, 18, 21, 24
        guard [12, 15, 18, 21, 24].contains(words.count) else {
            return false
        }
        
        // 2) Verify each word is in the list and fetch its index
        let indices: [Int] = words.compactMap { wordList.index(of: $0) }
        guard indices.count == words.count else {
            return false
        }
        
        // 3) Combine indices into bits (each index is 11 bits)
        // e.g. 12 words = 132 bits, where 128 bits is entropy and 4 bits is checksum
        var allBits: [Bool] = []
        for index in indices {
            // each index is 11 bits
            let bitMask = 1 << 10 // for shifting up to 11 bits
            for i in 0..<11 {
                let shifted = index & (bitMask >> i)
                // if shifted != 0, that bit is 1
                let bitValue = shifted != 0
                allBits.append(bitValue)
            }
        }
        
        // 4) Split into entropy bits + checksum bits
        // checksum length in bits = entropy length / 32
        // entropy length in bits = 32 * (numberOfWords / 3)
        let entropyBitsLength = 32 * (words.count / 3)
        let checksumBitsLength = entropyBitsLength / 32
        let totalBitsNeeded = entropyBitsLength + checksumBitsLength
        
        // Basic sanity check; make sure we have enough bits
        guard allBits.count == totalBitsNeeded else {
            return false
        }
        
        let entropyBits = Array(allBits[0..<entropyBitsLength])
        let checksumBits = Array(allBits[entropyBitsLength..<totalBitsNeeded])
        
        // Convert entropy bits back to Data
        let entropyData = Data.fromBits(entropyBits)
        
        // 5) Compute the SHA-256 of entropy, then extract the needed checksum bits
        let hash = sha256(entropyData)
        let hashData = Data(hash)
        
        // We only need the top `checksumBitsLength` bits of the hash
        var computedChecksumBits: [Bool] = []
        for i in 0..<checksumBitsLength {
            computedChecksumBits.append(hashData.bit(at: i))
        }
        
        // 6) Compare the computed checksum with the mnemonic’s checksum
        return checksumBits == computedChecksumBits
    }
    
    // Converts a mnemonic phrase into a seed using the specified passphrase.
    static func toSeed(mnemonic: String, passphrase: String) -> Data? {
        let salt = "mnemonic" + passphrase
        let seed = pbkdf2(password: mnemonic, salt: salt)
        return seed
    }
    
    // Helper to generate mnemonic from entropy
    private static func generateMnemonic(from entropy: Data, wordList: BIP39WordList = EnglishWordList()) -> String {
        let words = wordList.words
        let checksumBits = entropy.sha256().prefix(1)
        let entropyBits = entropy.bits
        let combinedBits = entropyBits + checksumBits.bits.prefix(entropy.count / 4)
        let wordCount = combinedBits.count / 11
        
        var mnemonic = [String]()
        for i in 0..<wordCount {
            let startIndex = i * 11
            let endIndex = startIndex + 11
            let wordIndex = Int(combinedBits[startIndex..<endIndex].joined(), radix: 2)!
            mnemonic.append(words[wordIndex])
        }
        return mnemonic.joined(separator: " ")
    }
    
    // PBKDF2 key derivation for seed generation
    private static func pbkdf2(password: String, salt: String, iterations: Int = 2048, keyLength: Int = 64) -> Data? {
        guard let passwordData = password.data(using: .utf8),
              let saltData = salt.data(using: .utf8) else {
            return nil
        }
        
        var derivedKey = Data(count: keyLength)
        
        let result = derivedKey.withUnsafeMutableBytes { derivedKeyBytes in
            saltData.withUnsafeBytes { saltBytes in
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),                     // Algorithm
                    password,                                         // Password
                    passwordData.count,                               // Password length
                    saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self), // Salt
                    saltData.count,                                   // Salt length
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512),     // Hash algorithm
                    UInt32(iterations),                               // Iterations
                    derivedKeyBytes.bindMemory(to: UInt8.self).baseAddress, // Output
                    keyLength                                         // Output key length
                )
            }
        }
        
        if result == kCCSuccess {
            return derivedKey
        } else {
            return nil
        }
    }
    
    static func sha256(_ data: Data) -> Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(buffer.count), &digest)
        }
        return Data(digest)
    }
}

// Extensions to add utility for Data and Array
private extension Data {
    var bits: [String] {
        self.map { String($0, radix: 2).leftPadding(toLength: 8, withPad: "0") }.joined()
            .map { String($0) }
    }
}

private extension Array where Element == String {
    func joined() -> String {
        return self.joined(separator: "")
    }
}

private extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        if self.count < toLength {
            return String(repeatElement(character, count: toLength - self.count)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
}

extension Data {
    func sha256() -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(self.count), &hash)
        }
        return Data(hash)
    }
    
    func sha256HexString() -> String {
        return self.sha256().map { String(format: "%02x", $0) }.joined()
    }
}

extension Data {
    /// Returns the bit at a specific index in this Data (where bitIndex=0 is the MSB).
    func bit(at bitIndex: Int) -> Bool {
        // bitIndex 0 is the left-most (most significant) bit
        let byteIndex = bitIndex / 8
        // if bitIndex = 0, offset = 7 (left-most bit in a byte)
        let offset = 7 - (bitIndex % 8)
        
        guard byteIndex < count else { return false }
        
        let byte = self[byteIndex]
        let mask = UInt8(1 << offset)
        
        return (byte & mask) != 0
    }
    
    /// Create a Data by interpreting a bool array as bits (MSB first).
    static func fromBits(_ bits: [Bool]) -> Data {
        let length = (bits.count + 7) / 8
        var data = Data(repeating: 0, count: length)
        
        for (i, bit) in bits.enumerated() {
            if bit {
                let byteIndex = i / 8
                let offset = 7 - (i % 8)
                data[byteIndex] |= (1 << offset)
            }
        }
        return data
    }
}
