;; Design Registration Contract
;; Documents traditional watercraft construction methods

;; Define data maps
(define-map boat-designs
  { id: uint }
  {
    name: (string-ascii 100),
    region: (string-ascii 100),
    boat-type: (string-ascii 50),
    description: (string-ascii 500),
    techniques: (string-ascii 500),
    registered-by: principal,
    registration-time: uint
  }
)

;; Define data maps for design attestations
(define-map design-attestations
  { design-id: uint, attester: principal }
  {
    attestation-time: uint,
    comments: (string-ascii 200)
  }
)

;; Define ID counter
(define-data-var next-design-id uint u1)

;; Error codes
(define-constant err-invalid-input u1)
(define-constant err-not-found u2)
(define-constant err-already-attested u3)

;; Read-only functions
(define-read-only (get-design (id uint))
  (map-get? boat-designs { id: id })
)

(define-read-only (get-attestation (design-id uint) (attester principal))
  (map-get? design-attestations { design-id: design-id, attester: attester })
)

;; Public functions
(define-public (register-design
    (name (string-ascii 100))
    (region (string-ascii 100))
    (boat-type (string-ascii 50))
    (description (string-ascii 500))
    (techniques (string-ascii 500)))

  (begin
    ;; Check inputs
    (asserts! (> (len name) u0) (err err-invalid-input))
    (asserts! (> (len region) u0) (err err-invalid-input))
    (asserts! (> (len boat-type) u0) (err err-invalid-input))
    (asserts! (> (len description) u0) (err err-invalid-input))
    (asserts! (> (len techniques) u0) (err err-invalid-input))

    ;; Insert design data
    (map-set boat-designs
      { id: (var-get next-design-id) }
      {
        name: name,
        region: region,
        boat-type: boat-type,
        description: description,
        techniques: techniques,
        registered-by: tx-sender,
        registration-time: block-height
      }
    )

    ;; Increment design ID counter
    (var-set next-design-id (+ (var-get next-design-id) u1))

    ;; Return success with design ID
    (ok (- (var-get next-design-id) u1))
  )
)

(define-public (update-design
    (id uint)
    (description (string-ascii 500))
    (techniques (string-ascii 500)))

  (let ((design (unwrap! (get-design id) (err err-not-found))))
    ;; Check authorization
    (asserts! (is-eq tx-sender (get registered-by design)) (err err-invalid-input))

    ;; Update design
    (map-set boat-designs
      { id: id }
      (merge design {
        description: description,
        techniques: techniques
      })
    )

    ;; Return success
    (ok true)
  )
)

(define-public (attest-design
    (design-id uint)
    (comments (string-ascii 200)))

  (begin
    ;; Check design exists
    (asserts! (is-some (get-design design-id)) (err err-not-found))

    ;; Check not self-attesting
    (asserts! (not (is-eq tx-sender (get registered-by (unwrap-panic (get-design design-id)))))
        (err err-invalid-input))

    ;; Check not already attested
    (asserts! (is-none (get-attestation design-id tx-sender)) (err err-already-attested))

    ;; Record attestation
    (map-set design-attestations
      { design-id: design-id, attester: tx-sender }
      {
        attestation-time: block-height,
        comments: comments
      }
    )

    ;; Return success
    (ok true)
  )
)
