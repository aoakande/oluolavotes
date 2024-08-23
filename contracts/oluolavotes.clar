;; Decentralized Voting System

;; Define constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant VOTING_PERIOD u1000)

;; Define error codes
(define-constant ERR-NOT-FOUND u100)
(define-constant ERR-VOTING-ENDED u101)
(define-constant ERR-ALREADY-VOTED u102)
(define-constant ERR-VOTING-NOT-ENDED u103)
(define-constant ERR-NOT-AUTHORIZED u104)

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
            (proposal (unwrap! (get-proposal proposal-id) 
                (err (to-uint ERR-NOT-FOUND))))
            (existing-vote (get-vote tx-sender proposal-id))
        )
        (asserts! (< block-height (get end-block-height proposal)) 
            (err (to-uint ERR-VOTING-ENDED)))
        (asserts! (is-none existing-vote) 
            (err (to-uint ERR-ALREADY-VOTED)))
        
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
            (proposal (unwrap! (get-proposal proposal-id) 
                (err (to-uint ERR-NOT-FOUND))))
        )
        (asserts! (>= block-height (get end-block-height proposal)) 
            (err (to-uint ERR-VOTING-NOT-ENDED)))
        (asserts! (is-eq tx-sender CONTRACT_OWNER) 
            (err (to-uint ERR-NOT-AUTHORIZED)))
        
        ;; Implement any post-voting logic here
        
        (ok true)
    )
)

;; Error handling helper function
(define-read-only (get-error-message (error-code uint))
    (match error-code
        ERR-NOT-FOUND "Proposal not found"
        ERR-VOTING-ENDED "Voting period has ended"
        ERR-ALREADY-VOTED "User has already voted"
        ERR-VOTING-NOT-ENDED "Voting period has not ended yet"
        ERR-NOT-AUTHORIZED "Not authorized to perform this action"
        "Unknown error"
    )
)
