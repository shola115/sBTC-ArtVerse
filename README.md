

#  Digital Art NFT Collection – Smart Contract

A complete NFT implementation on the Clarity smart contract language for the Stacks blockchain. It supports minting, metadata storage, marketplace listing, royalty distribution, and administrative controls.

---

## 📦 Features

* ✅ Mint NFTs (admin & public)
* 🎨 Metadata support (name, description, image, creator)
* 💸 Buy & sell NFTs via on-chain marketplace
* 💰 Creator royalties on each sale
* 🔒 Ownership checks & transfer validations
* 🔧 Admin control over base URI and mint price

---

## 🔐 Permissions

| Action                    | Permission        |
| ------------------------- | ----------------- |
| Mint NFT (admin)          | Contract owner    |
| Mint NFT (public)         | Anyone (pays fee) |
| Transfer NFT              | Owner only        |
| List NFT for sale         | Owner only        |
| Buy NFT                   | Anyone (with STX) |
| Set base URI / mint price | Contract owner    |

---

## 📄 Contract Constants

```clarity
(define-constant contract-owner tx-sender) ;; Set at deployment
(define-constant mint-price u1000000) ;; Default: 1 STX
(define-constant royalty-percent u5) ;; 5% royalty to creator
```

---

## 📑 NFT Metadata

Each NFT stores:

* `name`: string (max 64 chars)
* `description`: string (max 256 chars)
* `image`: URL (max 256 chars)
* `creator`: wallet address of minter

---

## 🚀 Functions Overview

### 📦 Minting

#### `mint-nft(name, description, image, recipient)`

* Admin-only minting with full metadata control.

#### `public-mint()`

* Anyone can mint a default NFT by paying `mint-price`.

---

### 🔁 Transfers

#### `transfer(token-id, sender, recipient)`

* Transfers token if `tx-sender == sender`.
* Prevents sending to self or non-existing token.

---

### 🛒 Marketplace

#### `list-for-sale(token-id, price)`

* Owner lists token for sale.

#### `buy-nft(token-id)`

* Buyer pays seller and creator (royalty split).
* Token transferred to buyer and listing removed.

---

### 🧾 Metadata Access

#### `get-token-metadata(token-id)`

* Returns name, description, image, creator.

#### `get-token-uri(token-id)`

* Returns base URI (can be used to fetch metadata off-chain).

#### `get-owner(token-id)`

* Returns owner of token.

---

### ⚙️ Admin Functions

#### `set-mint-price(new-price)`

* Updates public minting fee.

#### `set-base-uri(new-uri)`

* Updates base metadata URI for NFTs.

---

## ⚠️ Errors & Codes

| Error Name               | Code   |
| ------------------------ | ------ |
| `err-owner-only`         | `u100` |
| `err-not-token-owner`    | `u101` |
| `err-listing-not-found`  | `u102` |
| `err-insufficient-funds` | `u103` |
| `err-token-not-found`    | `u104` |
| `err-invalid-price`      | `u105` |
| `err-invalid-token-id`   | `u106` |
| `err-self-transfer`      | `u107` |

---

## 💡 Usage Tips

* Use `mint-nft` to create curated or rare NFTs as the admin.
* Use `public-mint` for open collection drops.
* Listings are removed automatically on sale or manual transfer.
* Set a base URI to link off-chain metadata hosting (e.g., IPFS or web API).

---

## 🛠️ Deployment Notes

* `contract-owner` is set to the deploying address.
* Ensure your backend (if any) uses the same base URI for off-chain metadata.
* Track `last-token-id` for minting and indexing NFTs.

---
