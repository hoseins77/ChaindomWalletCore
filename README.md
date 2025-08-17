# Chaindom Wallet Core

Chaindom Wallet Core is an open-source **multi-chain crypto wallet core** written entirely in **Swift**.

It provides developers with a clean, secure, and modular foundation for building crypto wallets that support multiple blockchains, **100% Swift**.

This project aims to serve as the **core building block** of a larger ecosystem:
 
 **Chaindom Wallet** – a user-facing multi-chain wallet app powered by Chaindom Wallet Core.

## **Vision**

Chaindom Wallet Core is designed to be:

- **Multi-chain** – supporting Ethereum, Binance Smart Chain, Bitcoin, with plans for Solana, TON, and more.
- **Secure by design** – implementing HD Wallet standards (**BIP32, BIP39, BIP44**) in pure Swift.
- **Modular** – blockchain logic is separated, making it easy to add new chains.
- **Developer-first** – clean APIs for wallet creation, key management, balances, transactions, and history.

## **Features (Planned & In Progress)**

- [X] Mnemonic + key derivation
- [ ] HDWallet class for support wallet actions in one place
- [ ] Etherium address generation
- [ ] Bitcoin Adress generation
- [ ] Transaction building and signing
- [ ] Smart contract ABI support
- [ ] Add support for more chains

## **Getting Started**

### **Requirements**

- Swift 5.9+
- Xcode 15+
- iOS 16+ / macOS 13+

### **Installation**
  
Add Chaindom Wallet Core as a Swift Package:
```Swift
dependencies: [
    .package(url: "https://github.com/yourusername/ChaindomWalletCore.git", branch: "main")
]
```

## **Contributing**

Contributions are welcome!
Open an issue or submit a PR to help shape the future of Chaindom Wallet Core.
