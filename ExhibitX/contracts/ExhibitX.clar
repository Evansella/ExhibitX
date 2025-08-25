;; Exhibition and Art Grants Platform Contract
;; Decentralized infrastructure for managing and distributing arts council grants, promoting creativity worldwide

;; Define constants
(define-constant ARTS-COUNCIL tx-sender)
(define-constant ERROR-NOT-ARTS-COUNCIL (err u100))
(define-constant ERROR-GRANT-ALREADY-AWARDED (err u101))
(define-constant ERROR-ARTIST-NOT-APPROVED (err u102))
(define-constant ERROR-INSUFFICIENT-GRANT-FUNDS (err u103))
(define-constant ERROR-EXHIBITION-SEASON-INACTIVE (err u104))
(define-constant ERROR-INVALID-GRANT-AMOUNT (err u105))
(define-constant ERROR-SHOWCASE-PERIOD-NOT-ENDED (err u106))
(define-constant ERROR-INVALID-ARTIST (err u107))
(define-constant ERROR-INVALID-EXHIBITION-PERIOD (err u108))

;; Define data variables
(define-data-var is-exhibition-season-active bool true)
(define-data-var total-grants-awarded uint u0)
(define-data-var grant-amount-per-artist uint u100)
(define-data-var exhibition-season-start-block uint stacks-block-height)
(define-data-var showcase-period-length uint u10000) ;; Number of blocks after which unclaimed grants can be redistributed

;; Define data maps
(define-map approved-exhibition-artists principal bool)
(define-map awarded-grant-amounts principal uint)

;; Define fungible token
(define-fungible-token creative-grant-token)

;; Define events
(define-data-var next-exhibition-event-id uint u0)
(define-map exhibition-events uint {event-type: (string-ascii 20), description: (string-ascii 256)})

;; Exhibition event logging function
(define-private (log-exhibition-event (event-type (string-ascii 20)) (description (string-ascii 256)))
  (let ((event-id (var-get next-exhibition-event-id)))
    (map-set exhibition-events event-id {event-type: event-type, description: description})
    (var-set next-exhibition-event-id (+ event-id u1))
    event-id))

;; Arts council functions

(define-public (approve-exhibition-artist (artist-address principal))
  (begin
    (asserts! (is-eq tx-sender ARTS-COUNCIL) ERROR-NOT-ARTS-COUNCIL)
    (asserts! (is-none (map-get? approved-exhibition-artists artist-address)) ERROR-INVALID-ARTIST)
    (log-exhibition-event "artist-approved" "new artist approved for exhibition")
    (ok (map-set approved-exhibition-artists artist-address true))))

(define-public (revoke-artist-approval (artist-address principal))
  (begin
    (asserts! (is-eq tx-sender ARTS-COUNCIL) ERROR-NOT-ARTS-COUNCIL)
    (asserts! (is-some (map-get? approved-exhibition-artists artist-address)) ERROR-ARTIST-NOT-APPROVED)
    (log-exhibition-event "approval-revoked" "artist exhibition approval revoked")
    (ok (map-delete approved-exhibition-artists artist-address))))

(define-public (bulk-approve-artists (artist-addresses (list 200 principal)))
  (begin
    (asserts! (is-eq tx-sender ARTS-COUNCIL) ERROR-NOT-ARTS-COUNCIL)
    (log-exhibition-event "bulk-approval" "multiple artists approved for exhibition")
    (ok (map approve-exhibition-artist artist-addresses))))

(define-public (update-grant-amount (new-amount uint))
  (begin
    (asserts! (is-eq tx-sender ARTS-COUNCIL) ERROR-NOT-ARTS-COUNCIL)
    (asserts! (> new-amount u0) ERROR-INVALID-GRANT-AMOUNT)
    (var-set grant-amount-per-artist new-amount)
    (log-exhibition-event "grant-updated" "creative grant amount per artist updated")
    (ok new-amount)))

(define-public (update-showcase-period (new-period uint))
  (begin
    (asserts! (is-eq tx-sender ARTS-COUNCIL) ERROR-NOT-ARTS-COUNCIL)
    (asserts! (> new-period u0) ERROR-INVALID-EXHIBITION-PERIOD)
    (var-set showcase-period-length new-period)
    (log-exhibition-event "period-updated" "exhibition showcase period updated")
    (ok new-period)))

;; Grant distribution function

(define-public (claim-artist-grant)
  (let (
    (artist-address tx-sender)
    (grant-funding (var-get grant-amount-per-artist))
  )
    (asserts! (var-get is-exhibition-season-active) ERROR-EXHIBITION-SEASON-INACTIVE)
    (asserts! (is-some (map-get? approved-exhibition-artists artist-address)) ERROR-ARTIST-NOT-APPROVED)
    (asserts! (is-none (map-get? awarded-grant-amounts artist-address)) ERROR-GRANT-ALREADY-AWARDED)
    (asserts! (<= grant-funding (ft-get-balance creative-grant-token ARTS-COUNCIL)) ERROR-INSUFFICIENT-GRANT-FUNDS)
    (try! (ft-transfer? creative-grant-token grant-funding ARTS-COUNCIL artist-address))
    (map-set awarded-grant-amounts artist-address grant-funding)
    (var-set total-grants-awarded (+ (var-get total-grants-awarded) grant-funding))
    (log-exhibition-event "grant-awarded" "creative grant awarded to artist")
    (ok grant-funding)))

;; Fund redistribution function

(define-public (redistribute-unclaimed-grants)
  (let (
    (current-block stacks-block-height)
    (redistribution-allowed-after (+ (var-get exhibition-season-start-block) (var-get showcase-period-length)))
  )
    (asserts! (is-eq tx-sender ARTS-COUNCIL) ERROR-NOT-ARTS-COUNCIL)
    (asserts! (>= current-block redistribution-allowed-after) ERROR-SHOWCASE-PERIOD-NOT-ENDED)
    (let (
      (total-minted (ft-get-supply creative-grant-token))
      (total-awarded (var-get total-grants-awarded))
      (unclaimed-amount (- total-minted total-awarded))
    )
      (try! (ft-burn? creative-grant-token unclaimed-amount ARTS-COUNCIL))
      (log-exhibition-event "grants-redistributed" "unclaimed creative grants redistributed")
      (ok unclaimed-amount))))

;; Read-only functions

(define-read-only (get-exhibition-season-status)
  (var-get is-exhibition-season-active))

(define-read-only (is-artist-approved (artist-address principal))
  (default-to false (map-get? approved-exhibition-artists artist-address)))

(define-read-only (has-artist-claimed-grant (artist-address principal))
  (is-some (map-get? awarded-grant-amounts artist-address)))

(define-read-only (get-artist-grant-amount (artist-address principal))
  (default-to u0 (map-get? awarded-grant-amounts artist-address)))

(define-read-only (get-total-grants-awarded)
  (var-get total-grants-awarded))

(define-read-only (get-grant-amount-per-artist)
  (var-get grant-amount-per-artist))

(define-read-only (get-showcase-period)
  (var-get showcase-period-length))

(define-read-only (get-exhibition-season-start-block)
  (var-get exhibition-season-start-block))

(define-read-only (get-exhibition-event (event-id uint))
  (map-get? exhibition-events event-id))

;; Contract initialization

(begin
  (ft-mint? creative-grant-token u1000000000 ARTS-COUNCIL)) 
