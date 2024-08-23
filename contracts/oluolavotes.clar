;; Decentralized Voting System

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant VOTING-PERIOD u1000)

;; Error codes
(define-constant ERR-NOT-FOUND (err u100))
(define-constant ERR-VOTING-ENDED (err u101))
(define-constant ERR-ALREADY-VOTED (err u102))
(define-constant ERR-VOTING-NOT-ENDED (err u103))
(define-constant ERR-NOT-AUTHORIZED (err u104))

;; Data maps
(define-map proposals
    { proposal-id: uint }
    {
        title: (string-utf8 50),
        description: (string-utf8 500),
        votes-for: uint,
        votes-against: uint,
        end-block-height: uint
    }
)

(define-map votes
    { voter: principal, proposal-id: uint }
    { vote: bool }
)

;; Data variables
(define-data-var proposal-count uint u0)

;; Read-only functions
(define-read-only (get-proposal (proposal-id uint))
    (ok (unwrap! (map-get? proposals { proposal-id: proposal-id }) ERR-NOT-FOUND))
)

(define-read-only (get-vote (voter principal) (proposal-id uint))
    (ok (unwrap! (map-get? votes { voter: voter, proposal-id: proposal-id }) ERR-NOT-FOUND))
)

(define-read-only (get-error-message (error-code (response bool uint)))
    (match error-code
        ERR-NOT-FOUND "Proposal not found"
        ERR-VOTING-ENDED "Voting period has ended"
        ERR-ALREADY-VOTED "User has already voted"
        ERR-VOTING-NOT-ENDED "Voting period has not ended yet"
        ERR-NOT-AUTHORIZED "Not authorized to perform this action"
        (err u0) "Unknown error"
        (ok _) "No error"
    )
)

;; Public functions
(define-public (create-proposal (title (string-utf8 50)) (description (string-utf8 500)))
    (let
        (
            (new-proposal-id (+ (var-get proposal-count) u1))
            (end-block-height (+ block-height VOTING-PERIOD))
        )
        (map-set proposals
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

(define-public (vote (proposal-id uint) (vote-for bool))
    (let
        (
            (proposal (try! (get-proposal proposal-id)))
            (existing-vote (map-get? votes { voter: tx-sender, proposal-id: proposal-id }))
        )
        (asserts! (< block-height (get end-block-height proposal)) ERR-VOTING-ENDED)
        (asserts! (is-none existing-vote) ERR-ALREADY-VOTED)
        
        (map-set votes
            { voter: tx-sender, proposal-id: proposal-id }
            { vote: vote-for }
        )
        
        (map-set proposals
            { proposal-id: proposal-id }
            (merge proposal 
                {
                    votes-for: (if vote-for (+ (get votes-for proposal) u1) (get votes-for proposal)),
                    votes-against: (if (not vote-for) (+ (get votes-against proposal) u1) (get votes-against proposal))
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
            (proposal (try! (get-proposal proposal-id)))
        )
        (asserts! (>= block-height (get end-block-height proposal)) ERR-VOTING-NOT-ENDED)
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        
        ;; Implement any post-voting logic here
        
        (ok true)
    )
)
