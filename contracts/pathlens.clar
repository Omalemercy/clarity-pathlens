;; PathLens Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-input (err u103))

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
    status: (string-ascii 20)
  }
)

(define-map milestones
  uint
  {
    path-id: uint,
    title: (string-ascii 100),
    description: (string-ascii 500),
    days-required: uint,
    completed: bool
  }
)

(define-map user-mentors
  principal
  (list 10 principal)
)

;; Public Functions
(define-public (create-path (title (string-ascii 100)) (description (string-ascii 500)))
  (let 
    ((path-id (var-get next-path-id)))
    (map-set paths path-id {
      owner: tx-sender,
      title: title,
      description: description,
      status: "active"
    })
    (var-set next-path-id (+ path-id u1))
    (ok path-id)
  )
)

(define-public (add-milestone (path-id uint) (title (string-ascii 100)) (description (string-ascii 500)) (days-required uint))
  (let 
    ((path (unwrap! (map-get? paths path-id) err-not-found))
     (milestone-id (var-get next-milestone-id)))
    (asserts! (is-eq (get owner path) tx-sender) err-unauthorized)
    (map-set milestones milestone-id {
      path-id: path-id,
      title: title,
      description: description,
      days-required: days-required,
      completed: false
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
    (map-set milestones milestone-id (merge milestone { completed: true }))
    (ok true)
  )
)

(define-public (connect-mentor (mentor principal))
  (let 
    ((current-mentors (default-to (list) (map-get? user-mentors tx-sender))))
    (map-set user-mentors tx-sender (unwrap! (as-max-len? (append current-mentors mentor) u10) err-invalid-input))
    (ok true)
  )
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
