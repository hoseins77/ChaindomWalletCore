//
//  HDWalletKey.swift
//  ChaindomWalletCore
//
//  Created by Hossein on 1/6/25.
//
//
import Foundation
import secp256k1
import BigInt
import CommonCrypto

public struct DerivedKey {
    public let privateKey: Data
    public let publicKey: Data
}

public class HDWalletKey {
    // Constants
    private let hardenedOffset: UInt32 = 0x80000000
    private let curveOrder = BigUInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141", radix: 16)!
    
    // Master key components
    private let masterPrivateKey: Data
    private let masterChainCode: Data
    
    // Secp256k1 context
    private let context: OpaquePointer?
    
    // Initializer
    public init?(seed: Data) {
        guard seed.count >= 16 && seed.count <= 64 else {
            // BIP32 specifies seed length between 128 and 512 bits
            return nil
        }
        
        // Create HMAC-SHA512 with key "Bitcoin seed"
        guard let hmacData = HDWalletKey.HMAC_SHA512(key: "Bitcoin seed".data(using: .ascii)!, data: seed) else {
            return nil
        }
        
        // Split into master private key and chain code
        let IL = hmacData.prefix(32)
        let IR = hmacData.suffix(32)
        
        // Ensure master private key is within [1, n-1]
        let ILBigInt = BigUInt(IL)
        if ILBigInt == 0 || ILBigInt >= curveOrder {
            return nil
        }
        
        self.masterPrivateKey = IL
        self.masterChainCode = IR
        
        // Initialize Secp256k1 context
        self.context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))
        guard self.context != nil else {
            return nil
        }
    }
    
    deinit {
        if let ctx = self.context {
            secp256k1_context_destroy(ctx)
        }
    }
    
    public func derive(path: DerivationPath) -> DerivedKey? {
        return derive(path: path.rawValue)
    }
    
    // Derive a key based on the path
    public func derive(path: String) -> DerivedKey? {
        // Parse the path
        let segments = path.split(separator: "/")
        guard segments.first == "m" else {
            // Path must start with 'm'
            return nil
        }
        
        var currentPrivateKey = masterPrivateKey
        var currentChainCode = masterChainCode
        
        for segment in segments.dropFirst() {
            let hardened: Bool
            var index: UInt32
            
            if segment.hasSuffix("'") {
                hardened = true
                let indexString = segment.dropLast()
                guard let idx = UInt32(indexString) else { return nil }
                index = idx + hardenedOffset
            } else {
                hardened = false
                guard let idx = UInt32(segment) else { return nil }
                index = idx
            }
            
            // Derive child key
            guard let child = deriveChild(privateKey: currentPrivateKey, chainCode: currentChainCode, index: index, hardened: hardened) else {
                return nil
            }
            
            currentPrivateKey = child.privateKey
            currentChainCode = child.chainCode
        }
        
        // Compute public key from private key
        guard let publicKey = privateKeyToPublicKey(privateKey: currentPrivateKey) else {
            return nil
        }
        
        return DerivedKey(privateKey: currentPrivateKey, publicKey: publicKey)
    }
    
    // Helper to derive a child key
    private func deriveChild(privateKey: Data, chainCode: Data, index: UInt32, hardened: Bool) -> (privateKey: Data, chainCode: Data)? {
        var data = Data()
        
        if hardened {
            // Hardened: data = 0x00 + parent_priv_key + index
            data.append(0x00)
            data.append(privateKey)
        } else {
            // Non-hardened: data = parent_pub_key + index
            guard let parentPub = privateKeyToPublicKey(privateKey: privateKey) else {
                return nil
            }
            data.append(parentPub)
        }
        
        // Append index in big-endian
        var indexBE = index.bigEndian
        let indexData = Data(bytes: &indexBE, count: 4)
        data.append(indexData)
        
        // HMAC-SHA512 with parent chain code as key
        guard let hmacData = HDWalletKey.HMAC_SHA512(key: chainCode, data: data) else {
            return nil
        }
        
        let IL = hmacData.prefix(32)
        let IR = hmacData.suffix(32)
        
        let ILBigInt = BigUInt(IL)
        if ILBigInt >= curveOrder {
            return nil
        }
        
        // Child private key = (IL + parent_priv_key) mod n
        let parentPrivBigInt = BigUInt(privateKey)
        let childPrivBigInt = (ILBigInt + parentPrivBigInt) % curveOrder
        if childPrivBigInt == 0 {
            return nil
        }
        
        // Convert back to Data (32 bytes)
        var childPrivBytes = childPrivBigInt.serialize()
        if childPrivBytes.count < 32 {
            childPrivBytes = Data(repeating: 0, count: 32 - childPrivBytes.count) + childPrivBytes
        }
        let childPrivateKey = childPrivBytes
        
        let childChainCode = IR
        
        return (childPrivateKey, childChainCode)
    }
    
    // Helper to convert private key to compressed public key
    private func privateKeyToPublicKey(privateKey: Data) -> Data? {
        guard let ctx = self.context else { return nil }
        
        var pubkey = secp256k1_pubkey()
        let privateKeyBytes = [UInt8](privateKey)
        
        let result = secp256k1_ec_pubkey_create(ctx, &pubkey, privateKeyBytes)
        if result != 1 {
            return nil
        }
        
        var output = [UInt8](repeating: 0, count: 33)
        var outputLength: size_t = output.count
        secp256k1_ec_pubkey_serialize(ctx, &output, &outputLength, &pubkey, UInt32(SECP256K1_EC_COMPRESSED))
        
        return Data(output)
    }
    
    // Static HMAC-SHA512 using CommonCrypto
    private static func HMAC_SHA512(key: Data, data: Data) -> Data? {
        var mac = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        key.withUnsafeBytes { keyBytes in
            data.withUnsafeBytes { dataBytes in
                CCHmac(
                    CCHmacAlgorithm(kCCHmacAlgSHA512),
                    keyBytes.baseAddress,
                    key.count,
                    dataBytes.baseAddress,
                    data.count,
                    &mac
                )
            }
        }
        return Data(mac)
    }
}
