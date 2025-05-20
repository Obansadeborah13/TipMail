(define-map messages
  { message-id: uint }
  {
    sender: principal,
    recipient: principal,
    tip: uint,
    timestamp: uint,
    message-hash: (buff 32),
    status: uint ;; 0 = pending, 1 = accepted, 2 = rejected, 3 = expired
  }
)

(define-constant expiry-blocks u100) ;; messages expire after 100 blocks

(define-public (send-message (recipient principal) (message-id uint) (message-hash (buff 32)) (tip uint))
  (let 
    (
      (msg-key { message-id: message-id })
      (msg-data {
        sender: tx-sender,
        recipient: recipient,
        tip: tip,
        timestamp: burn-block-height,
        message-hash: message-hash,
        status: u0
      })
    )
    (asserts! (> tip u0) (err u1))
    (asserts! (is-none (map-get? messages msg-key)) (err u2))
    (try! (stx-transfer? tip tx-sender (as-contract tx-sender)))
    (map-set messages msg-key msg-data)
    (ok message-id)
  )
)

(define-public (accept-message (message-id uint))
  (let 
    (
      (msg-key { message-id: message-id })
      (msg (unwrap! (map-get? messages msg-key) (err u4)))
    )
    (asserts! (is-eq (get recipient msg) tx-sender) (err u2))
    (asserts! (is-eq (get status msg) u0) (err u3))
    (try! (stx-transfer? (get tip msg) (as-contract tx-sender) tx-sender))
    (map-set messages msg-key (merge msg { status: u1 }))
    (ok u1)
  )
)

(define-public (reject-message (message-id uint))
  (let 
    (
      (msg-key { message-id: message-id })
      (msg (unwrap! (map-get? messages msg-key) (err u4)))
    )
    (asserts! (is-eq (get recipient msg) tx-sender) (err u2))
    (asserts! (is-eq (get status msg) u0) (err u3))
    (try! (stx-transfer? (get tip msg) (as-contract tx-sender) (get sender msg)))
    (map-set messages msg-key (merge msg { status: u2 }))
    (ok u2)
  )
)

(define-public (claim-expired (message-id uint))
  (let 
    (
      (msg-key { message-id: message-id })
      (msg (unwrap! (map-get? messages msg-key) (err u4)))
    )
    (asserts! (is-eq (get sender msg) tx-sender) (err u2))
    (asserts! (is-eq (get status msg) u0) (err u3))
    (asserts! (>= (- burn-block-height (get timestamp msg)) expiry-blocks) (err u5))
    (try! (stx-transfer? (get tip msg) (as-contract tx-sender) tx-sender))
    (map-set messages msg-key (merge msg { status: u3 }))
    (ok u3)
  )
)

(define-read-only (get-message-info (message-id uint))
  (map-get? messages { message-id: message-id })
)

