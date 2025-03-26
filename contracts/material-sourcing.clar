;; Material Sourcing Contract
;; Tracks appropriate woods and other boat building components

;; Define data maps
(define-map material-sources
  { id: uint }
  {
    material-type: (string-ascii 50),
    name: (string-ascii 100),
    region: (string-ascii 100),
    properties: (string-ascii 300),
    sustainability-score: uint,
    registered-by: principal,
    registration-time: uint
  }
)

;; Define data maps for material quality reports
(define-map material-quality-reports
  { source-id: uint, reporter: principal }
  {
    quality-score: uint,
    report-time: uint,
    comments: (string-ascii 200)
  }
)

;; Define ID counter
(define-data-var next-source-id uint u1)

;; Error codes
(define-constant err-invalid-input u1)
(define-constant err-not-found u2)

;; Read-only functions
(define-read-only (get-material-source (id uint))
  (map-get? material-sources { id: id })
)

(define-read-only (get-quality-report (source-id uint) (reporter principal))
  (map-get? material-quality-reports { source-id: source-id, reporter: reporter })
)

;; Public functions
(define-public (register-material-source
    (material-type (string-ascii 50))
    (name (string-ascii 100))
    (region (string-ascii 100))
    (properties (string-ascii 300))
    (sustainability-score uint))

  (begin
    ;; Check inputs
    (asserts! (> (len material-type) u0) (err err-invalid-input))
    (asserts! (> (len name) u0) (err err-invalid-input))
    (asserts! (> (len region) u0) (err err-invalid-input))
    (asserts! (> (len properties) u0) (err err-invalid-input))
    (asserts! (<= sustainability-score u100) (err err-invalid-input))

    ;; Insert material source data
    (map-set material-sources
      { id: (var-get next-source-id) }
      {
        material-type: material-type,
        name: name,
        region: region,
        properties: properties,
        sustainability-score: sustainability-score,
        registered-by: tx-sender,
        registration-time: block-height
      }
    )

    ;; Increment source ID counter
    (var-set next-source-id (+ (var-get next-source-id) u1))

    ;; Return success with source ID
    (ok (- (var-get next-source-id) u1))
  )
)

(define-public (update-material-source
    (id uint)
    (properties (string-ascii 300))
    (sustainability-score uint))

  (let ((source (unwrap! (get-material-source id) (err err-not-found))))
    ;; Check authorization
    (asserts! (is-eq tx-sender (get registered-by source)) (err err-invalid-input))

    ;; Check inputs
    (asserts! (<= sustainability-score u100) (err err-invalid-input))

    ;; Update material source
    (map-set material-sources
      { id: id }
      (merge source {
        properties: properties,
        sustainability-score: sustainability-score
      })
    )

    ;; Return success
    (ok true)
  )
)

(define-public (report-material-quality
    (source-id uint)
    (quality-score uint)
    (comments (string-ascii 200)))

  (begin
    ;; Check source exists
    (asserts! (is-some (get-material-source source-id)) (err err-not-found))

    ;; Check inputs
    (asserts! (<= quality-score u100) (err err-invalid-input))

    ;; Record quality report
    (map-set material-quality-reports
      { source-id: source-id, reporter: tx-sender }
      {
        quality-score: quality-score,
        report-time: block-height,
        comments: comments
      }
    )

    ;; Return success
    (ok true)
  )
)
