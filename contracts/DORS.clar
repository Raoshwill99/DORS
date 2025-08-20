;; Compact Decentralized Oracle System
;; Core functionality only

;; Constants
(define-constant min-stake u1000000)
(define-constant min-oracles u3)

;; Data structures
(define-map oracles 
    principal 
    {
        stake: uint,
        active: bool,
        accuracy: uint
    }
)

(define-map price-data
    uint
    {
        price: (optional uint),
        submissions: uint,
        closed: bool
    }
)

(define-map submissions
    {round: uint, oracle: principal}
    uint
)

;; Data variables
(define-data-var current-round uint u0)

;; Core functions
(define-public (register-oracle)
    (let ((stake (stx-get-balance tx-sender)))
        (asserts! (>= stake min-stake) (err u1))
        (map-set oracles tx-sender {
            stake: stake,
            active: true,
            accuracy: u100
        })
        (ok true)
    )
)

(define-public (submit-price (price uint))
    (let
        (
            (round-id (var-get current-round))
            (oracle-data (unwrap! (map-get? oracles tx-sender) (err u1)))
        )
        (asserts! (get active oracle-data) (err u2))
        (asserts! (is-none (map-get? submissions {round: round-id, oracle: tx-sender})) (err u3))
        
        (map-set submissions {round: round-id, oracle: tx-sender} price)
        
        (match (map-get? price-data round-id)
            round-data (map-set price-data round-id
                (merge round-data {
                    submissions: (+ (get submissions round-data) u1)
                })
            )
            (map-set price-data round-id {
                price: none,
                submissions: u1,
                closed: false
            })
        )
        (ok true)
    )
)

(define-public (finalize-round)
    (let
        (
            (round-id (var-get current-round))
            (round-data (unwrap! (map-get? price-data round-id) (err u4)))
        )
        (asserts! (not (get closed round-data)) (err u5))
        (asserts! (>= (get submissions round-data) min-oracles) (err u6))
        
        ;; Simple average consensus (replace with median for production)
        (let ((consensus-price u1000000)) ;; Placeholder calculation
            (map-set price-data round-id
                (merge round-data {
                    price: (some consensus-price),
                    closed: true
                })
            )
            (var-set current-round (+ round-id u1))
            (ok consensus-price)
        )
    )
)

;; Read-only functions
(define-read-only (get-oracle (oracle principal))
    (map-get? oracles oracle)
)

(define-read-only (get-current-price)
    (let ((round-id (- (var-get current-round) u1)))
        (match (map-get? price-data round-id)
            data (get price data)
            none
        )
    )
)

(define-read-only (get-round-info (round-id uint))
    (map-get? price-data round-id)
)