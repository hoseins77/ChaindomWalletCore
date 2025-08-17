//
//  BIP32WordList.swift
//  ChaindomWalletCore
//
//  Created by Hossein on 1/23/25.
//
protocol BIP39WordList {
    var words: [String] { set get }
}

extension BIP39WordList {
    func index(of word: String) -> Int? {
        return words.firstIndex(of: word)
    }
}
