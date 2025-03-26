;; Builder Certification Contract
;; Validates expertise in traditional boat building methods

;; Define data maps
(define-map builder-profiles
  { builder: principal }
  {
    name: (string-ascii 100),
    region: (string-ascii 100),
    specialization: (string-ascii 200),
    experience-years: uint,
    registration-time: uint
  }
)

;; Define data maps for certifications
(define-map builder-certifications
  { builder: principal }
  {
    certification-level: uint,
    certified-by: (list 10 principal),
    certification-time: uint,
    endorsement-count: uint
  }
)

;; Define data maps for endorsements
(define-map builder-endorsements
  { builder: principal, endorser: principal }
  {
    endorsement-time: uint,
    comments: (string-ascii 200)
  }
)

;; Error codes
(define-constant err-invalid-input u1)
(define-constant err-already-endorsed u2)
(define-constant err-not-found u3)
(define-constant err-self-endorsement u4)

;; Read-only functions
(define-read-only (get-builder-profile (builder principal))
  (map-get? builder-profiles { builder: builder })
)

(define-read-only (get-builder-certification (builder principal))
  (map-get? builder-certifications { builder: builder })
)

(define-read-only (get-endorsement (builder principal) (endorser principal))
  (map-get? builder-endorsements { builder: builder, endorser: endorser })
)

;; Public functions
(define-public (register-builder
    (name (string-ascii 100))
    (region (string-ascii 100))
    (specialization (string-ascii 200))
    (experience-years uint))

  (begin
    ;; Check inputs
    (asserts! (> (len name) u0) (err err-invalid-input))
    (asserts! (> (len region) u0) (err err-invalid-input))
    (asserts! (> (len specialization) u0) (err err-invalid-input))

    ;; Insert builder profile
    (map-set builder-profiles
      { builder: tx-sender }
      {
        name: name,
        region: region,
        specialization: specialization,
        experience-years: experience-years,
        registration-time: block-height
      }
    )

    ;; Initialize certification with level 0
    (map-set builder-certifications
      { builder: tx-sender }
      {
        certification-level: u0,
        certified-by: (list),
        certification-time: block-height,
        endorsement-count: u0
      }
    )

    ;; Return success
    (ok true)
  )
)

(define-public (update-builder-profile
    (name (string-ascii 100))
    (region (string-ascii 100))
    (specialization (string-ascii 200))
    (experience-years uint))

  (let ((profile (unwrap! (get-builder-profile tx-sender) (err err-not-found))))
    ;; Check inputs
    (asserts! (> (len name) u0) (err err-invalid-input))
    (asserts! (> (len region) u0) (err err-invalid-input))
    (asserts! (> (len specialization) u0) (err err-invalid-input))

    ;; Update profile
    (map-set builder-profiles
      { builder: tx-sender }
      {
        name: name,
        region: region,
        specialization: specialization,
        experience-years: experience-years,
        registration-time: (get registration-time profile)
      }
    )

    ;; Return success
    (ok true)
  )
)

(define-public (endorse-builder
    (builder principal)
    (comments (string-ascii 200)))

  (let (
    (builder-cert (unwrap! (get-builder-certification builder) (err err-not-found)))
    (endorser-cert (unwrap! (get-builder-certification tx-sender) (err err-not-found)))
  )
    ;; Check not self-endorsement
    (asserts! (not (is-eq tx-sender builder)) (err err-self-endorsement))

    ;; Check endorser is at least level 1
    (asserts! (>= (get certification-level endorser-cert) u1) (err err-invalid-input))

    ;; Check not already endorsed
    (asserts! (is-none (get-endorsement builder tx-sender)) (err err-already-endorsed))

    ;; Record endorsement
    (map-set builder-endorsements
      { builder: builder, endorser: tx-sender }
      {
        endorsement-time: block-height,
        comments: comments
      }
    )

    ;; Update endorsement count
    (map-set builder-certifications
      { builder: builder }
      (merge builder-cert {
        endorsement-count: (+ (get endorsement-count builder-cert) u1)
      })
    )

    ;; Auto-upgrade certification level based on endorsements
    (if (and
          (>= (+ (get endorsement-count builder-cert) u1) u3)
          (< (get certification-level builder-cert) u1)
        )
      (map-set builder-certifications
        { builder: builder }
        (merge builder-cert {
          certification-level: u1,
          endorsement-count: (+ (get endorsement-count builder-cert) u1)
        })
      )
      true
    )

    ;; Return success
    (ok true)
  )
)
