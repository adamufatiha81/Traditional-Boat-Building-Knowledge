;; Apprenticeship Tracking Contract
;; Records training progress of new boat builders

;; Define data maps
(define-map apprenticeships
  { id: uint }
  {
    master: principal,
    apprentice: principal,
    boat-type: (string-ascii 50),
    start-time: uint,
    end-time: (optional uint),
    status: (string-ascii 10),
    description: (string-ascii 300)
  }
)

;; Define data maps for skill achievements
(define-map skill-achievements
  { apprenticeship-id: uint, skill-id: uint }
  {
    skill-name: (string-ascii 100),
    proficiency: uint,
    certified-time: uint,
    notes: (string-ascii 200)
  }
)

;; Define ID counters
(define-data-var next-apprenticeship-id uint u1)
(define-data-var next-skill-id uint u1)

;; Error codes
(define-constant err-invalid-input u1)
(define-constant err-not-found u2)
(define-constant err-not-authorized u3)
(define-constant err-invalid-status u4)

;; Read-only functions
(define-read-only (get-apprenticeship (id uint))
  (map-get? apprenticeships { id: id })
)

(define-read-only (get-skill (apprenticeship-id uint) (skill-id uint))
  (map-get? skill-achievements { apprenticeship-id: apprenticeship-id, skill-id: skill-id })
)

;; Public functions
(define-public (start-apprenticeship
    (apprentice principal)
    (boat-type (string-ascii 50))
    (description (string-ascii 300)))

  (begin
    ;; Check inputs
    (asserts! (> (len boat-type) u0) (err err-invalid-input))
    (asserts! (> (len description) u0) (err err-invalid-input))

    ;; Insert apprenticeship data
    (map-set apprenticeships
      { id: (var-get next-apprenticeship-id) }
      {
        master: tx-sender,
        apprentice: apprentice,
        boat-type: boat-type,
        start-time: block-height,
        end-time: none,
        status: "ACTIVE",
        description: description
      }
    )

    ;; Increment apprenticeship ID counter
    (var-set next-apprenticeship-id (+ (var-get next-apprenticeship-id) u1))

    ;; Return success with apprenticeship ID
    (ok (- (var-get next-apprenticeship-id) u1))
  )
)

(define-public (complete-apprenticeship (id uint))
  (let ((apprenticeship (unwrap! (get-apprenticeship id) (err err-not-found))))
    ;; Check authorization
    (asserts! (is-eq tx-sender (get master apprenticeship)) (err err-not-authorized))

    ;; Check status is active
    (asserts! (is-eq (get status apprenticeship) "ACTIVE") (err err-invalid-status))

    ;; Update apprenticeship
    (map-set apprenticeships
      { id: id }
      (merge apprenticeship {
        end-time: (some block-height),
        status: "COMPLETED"
      })
    )

    ;; Return success
    (ok true)
  )
)

(define-public (certify-skill
    (apprenticeship-id uint)
    (skill-name (string-ascii 100))
    (proficiency uint)
    (notes (string-ascii 200)))

  (let ((apprenticeship (unwrap! (get-apprenticeship apprenticeship-id) (err err-not-found))))
    ;; Check authorization
    (asserts! (is-eq tx-sender (get master apprenticeship)) (err err-not-authorized))

    ;; Check inputs
    (asserts! (> (len skill-name) u0) (err err-invalid-input))
    (asserts! (<= proficiency u100) (err err-invalid-input))

    ;; Check status is active
    (asserts! (is-eq (get status apprenticeship) "ACTIVE") (err err-invalid-status))

    ;; Record skill achievement
    (map-set skill-achievements
      { apprenticeship-id: apprenticeship-id, skill-id: (var-get next-skill-id) }
      {
        skill-name: skill-name,
        proficiency: proficiency,
        certified-time: block-height,
        notes: notes
      }
    )

    ;; Increment skill ID counter
    (var-set next-skill-id (+ (var-get next-skill-id) u1))

    ;; Return success with skill ID
    (ok (- (var-get next-skill-id) u1))
  )
)

(define-public (update-skill-proficiency
    (apprenticeship-id uint)
    (skill-id uint)
    (proficiency uint)
    (notes (string-ascii 200)))

  (let (
    (apprenticeship (unwrap! (get-apprenticeship apprenticeship-id) (err err-not-found)))
    (skill (unwrap! (get-skill apprenticeship-id skill-id) (err err-not-found)))
  )
    ;; Check authorization
    (asserts! (is-eq tx-sender (get master apprenticeship)) (err err-not-authorized))

    ;; Check inputs
    (asserts! (<= proficiency u100) (err err-invalid-input))

    ;; Check status is active
    (asserts! (is-eq (get status apprenticeship) "ACTIVE") (err err-invalid-status))

    ;; Update skill proficiency
    (map-set skill-achievements
      { apprenticeship-id: apprenticeship-id, skill-id: skill-id }
      (merge skill {
        proficiency: proficiency,
        certified-time: block-height,
        notes: notes
      })
    )

    ;; Return success
    (ok true)
  )
)
