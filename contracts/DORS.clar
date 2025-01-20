;; Decentralized Oracle Redundancy System - Phase 2
;; Enhanced Consensus and Stake-Weighted Reporting

;; Constants from previous implementation
(define-constant contract-owner tx-sender)
(define-constant min-stake u1000000)
(define-constant consensus-threshold u80)

;; New constants for enhanced functionality
(define-constant max-price-deviation u500) ;; 5% maximum deviation
(define-constant reward-amount u100) ;; Reward for accurate submissions
(define-constant penalty-amount u50) ;; Penalty for inaccurate submissions

;; Enhanced data structures
(define-map oracle-nodes 
    principal 
    {
        stake: uint,
        active: bool,
        accuracy-score: uint,
        total-submissions: uint,
        total-correct: uint,
        weighted-score: uint,
        last-submission-height: uint
    }
)

(define-map price-rounds
    uint  ;; round-id
    {
        final-price: (optional uint),
        submissions-count: uint,
        consensus-reached: bool,
        round-closed: bool,
        total-stake-weight: uint
    }
)

(define-map round-submissions
    {round-id: uint, oracle: principal}
    {
        price: uint,
        stake-weight: uint,
        verified: bool,
        rewarded: bool
    }
)

;; Data variables
(define-data-var current-round uint u0)
(define-data-var price-submission-window uint u144) ;; ~24 hours in blocks

;; Enhanced public functions
(define-public (submit-price-with-weight (price uint))
    (let
        (
            (current-round-id (var-get current-round))
            (oracle-data (unwrap! (map-get? oracle-nodes tx-sender) (err u1)))
        )
        ;; Verify oracle eligibility
        (asserts! (get active oracle-data) (err u2))
        (asserts! (can-submit-in-round current-round-id oracle-data) (err u3))
        
        (let 
            (
                (stake-weight (calculate-stake-weight 
                    (get stake oracle-data)
                    (get accuracy-score oracle-data)
                ))
            )
            ;; Record submission with stake weight
            (map-set round-submissions 
                {round-id: current-round-id, oracle: tx-sender}
                {
                    price: price,
                    stake-weight: stake-weight,
                    verified: false,
                    rewarded: false
                }
            )
            
            ;; Update round data
            (match (map-get? price-rounds current-round-id)
                round-data (map-set price-rounds current-round-id
                    (merge round-data {
                        submissions-count: (+ (get submissions-count round-data) u1),
                        total-stake-weight: (+ (get total-stake-weight round-data) stake-weight)
                    })
                )
                (map-set price-rounds current-round-id {
                    final-price: none,
                    submissions-count: u1,
                    consensus-reached: false,
                    round-closed: false,
                    total-stake-weight: stake-weight
                })
            )
            
            ;; Update oracle data
            (map-set oracle-nodes tx-sender
                (merge oracle-data {
                    total-submissions: (+ (get total-submissions oracle-data) u1),
                    last-submission-height: block-height
                })
            )
            (ok true)
        )
    )
)

(define-public (finalize-round)
    (let
        (
            (current-round-id (var-get current-round))
            (round-data (unwrap! (map-get? price-rounds current-round-id) (err u4)))
        )
        ;; Check if round can be finalized
        (asserts! (not (get round-closed round-data)) (err u5))
        (asserts! (>= (get submissions-count round-data) u3) (err u6))
        
        ;; Calculate consensus price and update round
        (let
            (
                (consensus-price (calculate-consensus-price current-round-id round-data))
            )
            ;; Update round with final price
            (map-set price-rounds current-round-id
                (merge round-data {
                    final-price: (some consensus-price),
                    consensus-reached: true,
                    round-closed: true
                })
            )
            
            ;; Start new round
            (var-set current-round (+ current-round-id u1))
            (ok consensus-price)
        )
    )
)

;; Helper functions
(define-private (calculate-stake-weight (stake uint) (accuracy-score uint))
    (let
        (
            (base-weight (/ (* stake) u1000000))
            (accuracy-multiplier (/ (* accuracy-score) u100))
        )
        (* base-weight accuracy-multiplier)
    )
)

(define-private (can-submit-in-round (round-id uint) (oracle-data {stake: uint, accuracy-score: uint, total-submissions: uint, total-correct: uint, weighted-score: uint, last-submission-height: uint, active: bool}))
    (and
        (>= (- block-height (get last-submission-height oracle-data)) (var-get price-submission-window))
        (is-none (map-get? round-submissions {round-id: round-id, oracle: tx-sender}))
    )
)

(define-private (calculate-consensus-price (round-id uint) (round-data {final-price: (optional uint), submissions-count: uint, consensus-reached: bool, round-closed: bool, total-stake-weight: uint}))
    ;; Implementation of stake-weighted median calculation
    ;; This is a simplified version - in production, you'd want more sophisticated outlier detection
    u1000000 ;; Placeholder return value
)

;; Read-only functions
(define-read-only (get-round-status (round-id uint))
    (map-get? price-rounds round-id)
)

(define-read-only (get-oracle-submission (round-id uint) (oracle-address principal))
    (map-get? round-submissions {round-id: round-id, oracle: oracle-address})
)