;; Gym Pass - Fitness Center Membership Contract
;; A subscription service for recurring gym membership payments

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-funds (err u101))
(define-constant err-subscription-not-found (err u102))
(define-constant err-subscription-expired (err u103))
(define-constant err-unauthorized (err u104))
(define-constant err-invalid-amount (err u105))

;; Data Variables
(define-data-var membership-price uint u1000000) ;; 1 STX in microSTX
(define-data-var subscription-duration uint u2629746) ;; 1 month in seconds (30.44 days)

;; Data Maps
(define-map subscriptions 
  { member: principal }
  { 
    start-time: uint,
    end-time: uint,
    is-active: bool,
    total-paid: uint
  }
)

(define-map gym-admins { admin: principal } { authorized: bool })

;; Read-only functions
(define-read-only (get-membership-price)
  (var-get membership-price)
)

(define-read-only (get-subscription-duration)
  (var-get subscription-duration)
)

(define-read-only (get-subscription (member principal))
  (map-get? subscriptions { member: member })
)

(define-read-only (is-member-active (member principal))
  (match (map-get? subscriptions { member: member })
    subscription (and 
      (get is-active subscription)
      (>= (get end-time subscription) burn-block-height)
    )
    false
  )
)

(define-read-only (get-contract-balance)
  (stx-get-balance (as-contract tx-sender))
)

(define-read-only (is-admin (user principal))
  (default-to false (get authorized (map-get? gym-admins { admin: user })))
)

;; Private functions
(define-private (calculate-end-time (start-time uint))
  (+ start-time (var-get subscription-duration))
)

;; Public functions

;; Subscribe or renew membership
(define-public (subscribe)
  (let (
    (member tx-sender)
    (price (var-get membership-price))
    (current-time burn-block-height)
    (existing-sub (map-get? subscriptions { member: member }))
  )
    (asserts! (>= (stx-get-balance tx-sender) price) err-insufficient-funds)
    
    ;; Transfer payment to contract
    (try! (stx-transfer? price tx-sender (as-contract tx-sender)))
    
    ;; Update or create subscription
    (match existing-sub
      subscription 
      (let (
        (new-start-time (if (get is-active subscription)
                          (get end-time subscription) ;; Extend from current end time
                          current-time)) ;; Start fresh if expired
        (new-end-time (calculate-end-time new-start-time))
        (new-total (+ (get total-paid subscription) price))
      )
        (map-set subscriptions 
          { member: member }
          {
            start-time: new-start-time,
            end-time: new-end-time,
            is-active: true,
            total-paid: new-total
          }
        )
      )
      ;; New subscription
      (map-set subscriptions 
        { member: member }
        {
          start-time: current-time,
          end-time: (calculate-end-time current-time),
          is-active: true,
          total-paid: price
        }
      )
    )
    (ok true)
  )
)

;; Cancel subscription (member can cancel their own)
(define-public (cancel-subscription)
  (let (
    (member tx-sender)
    (subscription (unwrap! (map-get? subscriptions { member: member }) err-subscription-not-found))
  )
    (map-set subscriptions 
      { member: member }
      (merge subscription { is-active: false })
    )
    (ok true)
  )
)

;; Admin functions

;; Set membership price (admin only)
(define-public (set-membership-price (new-price uint))
  (begin
    (asserts! (or (is-eq tx-sender contract-owner) (is-admin tx-sender)) err-unauthorized)
    (asserts! (> new-price u0) err-invalid-amount)
    (var-set membership-price new-price)
    (ok true)
  )
)

;; Set subscription duration (admin only)
(define-public (set-subscription-duration (new-duration uint))
  (begin
    (asserts! (or (is-eq tx-sender contract-owner) (is-admin tx-sender)) err-unauthorized)
    (asserts! (> new-duration u0) err-invalid-amount)
    (var-set subscription-duration new-duration)
    (ok true)
  )
)

;; Add gym admin
(define-public (add-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set gym-admins { admin: new-admin } { authorized: true })
    (ok true)
  )
)

;; Remove gym admin
(define-public (remove-admin (admin principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-delete gym-admins { admin: admin })
    (ok true)
  )
)

;; Revoke member access (admin only)
(define-public (revoke-member-access (member principal))
  (let (
    (subscription (unwrap! (map-get? subscriptions { member: member }) err-subscription-not-found))
  )
    (asserts! (or (is-eq tx-sender contract-owner) (is-admin tx-sender)) err-unauthorized)
    (map-set subscriptions 
      { member: member }
      (merge subscription { is-active: false })
    )
    (ok true)
  )
)

;; Withdraw funds (owner only)
(define-public (withdraw (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= amount (stx-get-balance (as-contract tx-sender))) err-insufficient-funds)
    (as-contract (stx-transfer? amount tx-sender contract-owner))
  )
)

;; Withdraw all funds (owner only)
(define-public (withdraw-all)
  (let (
    (balance (stx-get-balance (as-contract tx-sender)))
  )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (as-contract (stx-transfer? balance tx-sender contract-owner))
  )
)