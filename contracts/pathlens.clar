;; PathLens Contract - Enhanced Version

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-input (err u103))
(define-constant err-already-completed (err u104))
(define-constant err-path-inactive (err u105))
(define-constant err-mentor-pending (err u106))

;; Data Variables
(define-data-var next-path-id uint u1)
(define-data-var next-milestone-id uint u1)

;; Data Maps
(define-map paths 
  uint 
  {
    owner: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    status: (string-ascii 20),
    created-at: uint
  }
)

(define-map milestones
  uint
  {
    path-id: uint,
    title: (string-ascii 100),
    description: (string-ascii 500),
    days-required: uint,
    completed: bool,
    completed-at: (optional uint),
    sequence: uint
  }
)

(define-map user-mentors
  principal
  {
    mentors: (list 10 principal),
    pending: (list 10 principal)
  }
)

;; Public Functions
(define-public (create-path (title (string-ascii 100)) (description (string-ascii 500)))
  (let 
    ((path-id (var-get next-path-id)))
    (map-set paths path-id {
      owner: tx-sender,
      title: title,
      description: description,
      status: "active",
      created-at: block-height
    })
    (var-set next-path-id (+ path-id u1))
    (ok path-id)
  )
)

(define-public (add-milestone (path-id uint) (title (string-ascii 100)) (description (string-ascii 500)) (days-required uint) (sequence uint))
  (let 
    ((path (unwrap! (map-get? paths path-id) err-not-found))
     (milestone-id (var-get next-milestone-id)))
    (asserts! (is-eq (get owner path) tx-sender) err-unauthorized)
    (asserts! (is-eq (get status path) "active") err-path-inactive)
    (map-set milestones milestone-id {
      path-id: path-id,
      title: title,
      description: description,
      days-required: days-required,
      completed: false,
      completed-at: none,
      sequence: sequence
    })
    (var-set next-milestone-id (+ milestone-id u1))
    (ok milestone-id)
  )
)

(define-public (complete-milestone (milestone-id uint))
  (let 
    ((milestone (unwrap! (map-get? milestones milestone-id) err-not-found))
     (path (unwrap! (map-get? paths (get path-id milestone)) err-not-found)))
    (asserts! (is-eq (get owner path) tx-sender) err-unauthorized)
    (asserts! (not (get completed milestone)) err-already-completed)
    (asserts! (is-eq (get status path) "active") err-path-inactive)
    (map-set milestones milestone-id (merge milestone { 
      completed: true,
      completed-at: (some block-height)
    }))
    (ok true)
  )
)

(define-public (update-path-status (path-id uint) (new-status (string-ascii 20)))
  (let ((path (unwrap! (map-get? paths path-id) err-not-found)))
    (asserts! (is-eq (get owner path) tx-sender) err-unauthorized)
    (map-set paths path-id (merge path { status: new-status }))
    (ok true)
  )
)

(define-public (request-mentor (mentor principal))
  (let 
    ((current-data (default-to { mentors: (list), pending: (list) } (map-get? user-mentors tx-sender))))
    (map-set user-mentors tx-sender (merge current-data {
      pending: (unwrap! (as-max-len? (append (get pending current-data) mentor) u10) err-invalid-input)
    }))
    (ok true)
  )
)

(define-public (approve-mentorship (mentee principal))
  (let 
    ((mentee-data (unwrap! (map-get? user-mentors mentee) err-not-found)))
    (asserts! (is-some (index-of (get pending mentee-data) tx-sender)) err-mentor-pending)
    (map-set user-mentors mentee {
      mentors: (unwrap! (as-max-len? (append (get mentors mentee-data) tx-sender) u10) err-invalid-input),
      pending: (filter not-tx-sender (get pending mentee-data))
    })
    (ok true)
  )
)

;; Private Functions
(define-private (not-tx-sender (principal principal))
  (not (is-eq principal tx-sender))
)

;; Read Only Functions
(define-read-only (get-path (path-id uint))
  (ok (map-get? paths path-id))
)

(define-read-only (get-milestone (milestone-id uint))
  (ok (map-get? milestones milestone-id))
)

(define-read-only (get-user-mentors (user principal))
  (ok (map-get? user-mentors user))
)
