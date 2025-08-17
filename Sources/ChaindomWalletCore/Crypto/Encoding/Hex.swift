//
//  Hex.swift
//  ChaindomWalletCore
//
//  Created by Hossein on 1/6/25.
//
import Foundation

extension Data {
    init?(hex: String) {
        let len = hex.count / 2
        var data = Data(capacity: len)
        var index = hex.startIndex

        for _ in 0..<len {
            let nextIndex = hex.index(index, offsetBy: 2)
            guard let byte = UInt8(hex[index..<nextIndex], radix: 16) else {
                return nil // Invalid hex string
            }
            data.append(byte)
            index = nextIndex
        }
        self = data
    }
}

extension Data {
    var hex: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
