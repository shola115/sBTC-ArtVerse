
;; sBTC-ArtVerse

;; Digital Art NFT Collection

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-listing-not-found (err u102))
(define-constant err-insufficient-funds (err u103))
(define-constant err-token-not-found (err u104))
(define-constant err-invalid-price (err u105))
(define-constant err-invalid-token-id (err u106))
(define-constant err-self-transfer (err u107))

;; Data Variables
(define-data-var last-token-id uint u0)
(define-data-var base-uri (string-ascii 256) "https://api.yourartcollections.com/metadata/")
(define-data-var mint-price uint u1000000) ;; 1 STX in microSTX
(define-data-var royalty-percent uint u5) ;; 5% royalty

;; Data Maps
(define-map token-metadata 
    uint 
    {
        name: (string-ascii 64),
        description: (string-ascii 256),
        image: (string-ascii 256),
        creator: principal
    }
)

(define-map marketplace-listings
    uint
    {
        price: uint,
        seller: principal
    }
)

(define-map approved-operators principal bool)

;; NFT Functions
(define-non-fungible-token digital-art uint)

(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
    (ok (some (var-get base-uri)))
)

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? digital-art token-id))
)

(define-read-only (get-token-metadata (token-id uint))
    (map-get? token-metadata token-id)
)

(define-read-only (get-listing (token-id uint))
    (map-get? marketplace-listings token-id)
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (> token-id u0) err-invalid-token-id)
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (asserts! (not (is-eq sender recipient)) err-self-transfer)
        (asserts! (is-some (nft-get-owner? digital-art token-id)) err-token-not-found)
        (map-delete marketplace-listings token-id)
        (nft-transfer? digital-art token-id sender recipient)
    )
)

(define-public (mint-nft 
    (name (string-ascii 64))
    (description (string-ascii 256)) 
    (image (string-ascii 256))
    (recipient principal))
    (let
        (
            (token-id (+ (var-get last-token-id) u1))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (> (len name) u0) err-invalid-token-id)
        (asserts! (not (is-eq recipient contract-owner)) err-self-transfer)
        (try! (nft-mint? digital-art token-id recipient))
        (map-set token-metadata token-id {
            name: name,
            description: description,
            image: image,
            creator: tx-sender
        })
        (var-set last-token-id token-id)
        (ok token-id)
    )
)


(define-public (public-mint)
    (let
        (
            (token-id (+ (var-get last-token-id) u1))
            (mint-cost (var-get mint-price))
        )
        (try! (stx-transfer? mint-cost tx-sender contract-owner))
        (try! (nft-mint? digital-art token-id tx-sender))
        (map-set token-metadata token-id {
            name: "Digital Art NFT",
            description: "A unique piece of digital art",
            image: "",
            creator: tx-sender
        })
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

(define-public (list-for-sale (token-id uint) (price uint))
    (let
        (
            (owner (unwrap! (nft-get-owner? digital-art token-id) err-token-not-found))
        )
        (asserts! (> token-id u0) err-invalid-token-id)
        (asserts! (> price u0) err-invalid-price)
        (asserts! (is-eq tx-sender owner) err-not-token-owner)
        (map-set marketplace-listings token-id {price: price, seller: tx-sender})
        (ok true)
    )
)

(define-public (buy-nft (token-id uint))
    (let
        (
            (listing (unwrap! (map-get? marketplace-listings token-id) err-listing-not-found))
            (price (get price listing))
            (seller (get seller listing))
            (metadata (unwrap! (map-get? token-metadata token-id) err-token-not-found))
            (creator (get creator metadata))
            (royalty (/ (* price (var-get royalty-percent)) u100))
            (seller-amount (- price royalty))
        )
        (asserts! (> token-id u0) err-invalid-token-id)
        (asserts! (not (is-eq tx-sender seller)) err-self-transfer)
        (try! (stx-transfer? seller-amount tx-sender seller))
        (try! (stx-transfer? royalty tx-sender creator))
        (try! (nft-transfer? digital-art token-id seller tx-sender))
        (map-delete marketplace-listings token-id)
        (ok true)
    )
)

;; Admin functions
(define-public (set-mint-price (new-price uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (> new-price u0) err-invalid-price)
        (var-set mint-price new-price)
        (ok true)
    )
)

(define-public (set-base-uri (new-uri (string-ascii 256)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (> (len new-uri) u0) err-invalid-token-id)
        (var-set base-uri new-uri)
        (ok true)
    )
)
