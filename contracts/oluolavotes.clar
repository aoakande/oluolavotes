;; Decentralized Voting System

;; Define constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant VOTING_PERIOD u1000)

;; Define data maps
(define-map Proposals
    { proposal-id: uint }
    { 
        title: (string-utf8 50),
        description: (string-utf8 500),
        votes-for: uint,
        votes-against: uint,
        end-block-height: uint
    }
)

(define-map Votes
    { voter: principal, proposal-id: uint }
    { vote: bool }
)

;; Define data variables
(define-data-var proposal-count uint u0)

;; Read-only functions
(define-read-only (get-proposal (proposal-id uint))
    (map-get? Proposals { proposal-id: proposal-id })
)

(define-read-only (get-vote (voter principal) (proposal-id uint))
    (map-get? Votes { voter: voter, proposal-id: proposal-id })
)

;; Public functions
(define-public (create-proposal (title (string-utf8 50)) (description (string-utf8 500)))
    (let
        (
            (new-proposal-id (+ (var-get proposal-count) u1))
            (end-block-height (+ block-height VOTING_PERIOD))
        )
        (map-set Proposals
            { proposal-id: new-proposal-id }
            {
                title: title,
                description: description,
                votes-for: u0,
                votes-against: u0,
                end-block-height: end-block-height
            }
        )
        (var-set proposal-count new-proposal-id)
        (ok new-proposal-id)
    )
)

(define-public (vote (proposal-id uint) (vote bool))
    (let
        (
            (proposal (unwrap! (get-proposal proposal-id) (err u1)))
            (existing-vote (get-vote tx-sender proposal-id))
        )
        (asserts! (< block-height (get end-block-height proposal)) (err u2))
        (asserts! (is-none existing-vote) (err u3))

        (map-set Votes
            { voter: tx-sender, proposal-id: proposal-id }
            { vote: vote }
        )

        (map-set Proposals
            { proposal-id: proposal-id }
            (merge proposal 
                {
                    votes-for: (if vote (+ (get votes-for proposal) u1) (get votes-for proposal)),
                    votes-against: (if (not vote) (+ (get votes-against proposal) u1) (get votes-against proposal))
                }
            )
        )
        (ok true)
    )
)

;; Admin functions
(define-public (end-voting (proposal-id uint))
    (let
        (
            (proposal (unwrap! (get-proposal proposal-id) (err u1)))
        )
        (asserts! (>= block-height (get end-block-height proposal)) (err u4))
        (asserts! (is-eq tx-sender CONTRACT_OWNER) (err u5))

        ;; Implement any post-voting logic here

        (ok true)
    )
)
