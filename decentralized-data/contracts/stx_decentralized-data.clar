;; title: blockchain_data_indexer
;; version: 1.0.0
;; summary: Blockchain Data Indexing and Query Service
;; description: Comprehensive system for indexing blockchain data including blocks, transactions,
;;              contracts, and events with efficient querying capabilities

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_BLOCK (err u101))
(define-constant ERR_INVALID_TRANSACTION (err u102))
(define-constant ERR_INDEX_NOT_FOUND (err u103))
(define-constant ERR_INVALID_QUERY (err u104))
(define-constant ERR_INDEXER_NOT_REGISTERED (err u105))
(define-constant ERR_INSUFFICIENT_PAYMENT (err u106))
(define-constant ERR_RATE_LIMIT_EXCEEDED (err u107))
(define-constant ERR_INVALID_TIME_RANGE (err u108))
(define-constant ERR_TOO_MANY_RESULTS (err u109))
(define-constant ERR_INVALID_CONTRACT (err u110))

;; Query types
(define-constant QUERY_TYPE_BLOCK u1)
(define-constant QUERY_TYPE_TRANSACTION u2)
(define-constant QUERY_TYPE_CONTRACT u3)
(define-constant QUERY_TYPE_EVENT u4)
(define-constant QUERY_TYPE_ADDRESS u5)
(define-constant QUERY_TYPE_TOKEN_TRANSFER u6)
(define-constant QUERY_TYPE_CONTRACT_CALL u7)
(define-constant QUERY_TYPE_CUSTOM u8)

;; Index types
(define-constant INDEX_TYPE_BLOCK_HEIGHT u1)
(define-constant INDEX_TYPE_BLOCK_HASH u2)
(define-constant INDEX_TYPE_TX_HASH u3)
(define-constant INDEX_TYPE_ADDRESS u4)
(define-constant INDEX_TYPE_CONTRACT u5)
(define-constant INDEX_TYPE_TOKEN u6)
(define-constant INDEX_TYPE_EVENT u7)
(define-constant INDEX_TYPE_TIME u8)

;; Economic parameters
(define-constant INDEXER_REGISTRATION_FEE u5000000) ;; 5 STX
(define-constant QUERY_FEE u100000) ;; 0.1 STX per query
(define-constant PREMIUM_QUERY_FEE u500000) ;; 0.5 STX for complex queries
(define-constant INDEXER_BOND u20000000) ;; 20 STX bond for indexers
(define-constant MAX_RESULTS_PER_QUERY u100)
(define-constant RATE_LIMIT_PER_BLOCK u10) ;; Max queries per block per user

;; Data Variables
(define-data-var next-block-index uint u1)
(define-data-var next-transaction-index uint u1)
(define-data-var next-event-index uint u1)
(define-data-var next-query-id uint u1)
(define-data-var current-indexed-height uint u0)
(define-data-var indexing-reward-pool uint u0)
(define-data-var total-queries-processed uint u0)

;; Helper functions for min/max operations
(define-private (min-uint (a uint) (b uint))
    (if (<= a b) a b))

(define-private (max-uint (a uint) (b uint))
    (if (>= a b) a b))

;; Registered indexers who can submit blockchain data
(define-map registered-indexers principal {
    name: (string-ascii 64),
    indexer-type: uint, ;; 1=full-node, 2=specialized, 3=archive
    bond-amount: uint,
    active: bool,
    blocks-indexed: uint,
    last-indexed-height: uint,
    reputation-score: uint,
    registered-at: uint
})

;; Block data index
(define-map block-index uint {
    block-height: uint,
    block-hash: (buff 32),
    parent-hash: (buff 32),
    timestamp: uint,
    miner: (optional principal),
    transaction-count: uint,
    total-fees: uint,
    block-size: uint,
    difficulty: uint,
    indexed-by: principal,
    indexed-at: uint
})

;; Transaction data index
(define-map transaction-index uint {
    tx-hash: (buff 32),
    block-height: uint,
    block-index: uint,
    tx-type: (string-ascii 32), ;; "contract-call", "token-transfer", "contract-deploy"
    sender: principal,
    recipient: (optional principal),
    amount: (optional uint),
    fee: uint,
    nonce: uint,
    contract-address: (optional principal),
    function-name: (optional (string-ascii 64)),
    success: bool,
    error-code: (optional uint),
    events-count: uint,
    indexed-at: uint
})

;; Contract deployment and call index
(define-map contract-index principal {
    deployer: principal,
    contract-name: (string-ascii 64),
    deployed-at-height: uint,
    deployed-at-time: uint,
    source-code-hash: (buff 32),
    total-calls: uint,
    unique-callers: uint,
    last-call-height: uint,
    contract-type: (string-ascii 32), ;; "token", "defi", "nft", "dao", "other"
    is-active: bool
})

;; Event logs index
(define-map event-index uint {
    tx-hash: (buff 32),
    tx-index: uint,
    block-height: uint,
    contract-address: principal,
    event-type: (string-ascii 64),
    event-data: (buff 256),
    topics: (list 4 (buff 32)),
    indexed-at: uint
})

;; Address activity index
(define-map address-index principal {
    first-seen-height: uint,
    last-seen-height: uint,
    transaction-count: uint,
    sent-amount: uint,
    received-amount: uint,
    contract-calls: uint,
    contracts-deployed: uint,
    tokens-held: (list 20 principal), ;; List of token contracts
    nft-count: uint,
    address-type: (string-ascii 32) ;; "user", "contract", "multisig"
})

;; Token transfer index
(define-map token-transfer-index uint {
    tx-hash: (buff 32),
    block-height: uint,
    token-contract: principal,
    from-address: principal,
    to-address: principal,
    amount: uint,
    memo: (optional (buff 64)),
    transfer-type: (string-ascii 32), ;; "transfer", "mint", "burn"
    indexed-at: uint
})

;; Query cache for frequently requested data
(define-map query-cache (buff 32) {
    query-hash: (buff 32),
    result-hash: (buff 32),
    result-count: uint,
    cached-at: uint,
    expires-at: uint,
    hit-count: uint
})

;; Query statistics and rate limiting
(define-map query-stats principal {
    total-queries: uint,
    successful-queries: uint,
    failed-queries: uint,
    premium-queries: uint,
    last-query-block: uint,
    queries-this-block: uint,
    total-fees-paid: uint
})

;; Index metadata and statistics
(define-map index-metadata uint {
    index-type: uint,
    name: (string-ascii 64),
    description: (string-ascii 256),
    total-entries: uint,
    last-updated: uint,
    indexer: principal,
    active: bool
})

;; Custom query templates for complex searches
(define-map query-templates uint {
    template-name: (string-ascii 64),
    query-pattern: (string-ascii 512),
    parameter-types: (list 10 (string-ascii 32)),
    result-schema: (string-ascii 256),
    complexity-score: uint,
    usage-count: uint,
    created-by: principal
})

;; Blockchain analytics aggregates
(define-map analytics-data uint {
    metric-name: (string-ascii 64),
    time-period: uint, ;; Block height or time window
    value: uint,
    data-type: (string-ascii 32), ;; "count", "sum", "average", "rate"
    calculated-at: uint
})

;; Helper Functions

;; Generate query hash for caching
(define-private (generate-query-hash 
    (query-type uint)
    (parameters (buff 256)))
    (hash160 (concat 
        (unwrap-panic (to-consensus-buff? query-type))
        parameters)))

;; Check rate limits
(define-private (check-rate-limit (user principal))
    (let ((stats (default-to 
            { total-queries: u0, successful-queries: u0, failed-queries: u0, 
              premium-queries: u0, last-query-block: u0, queries-this-block: u0, 
              total-fees-paid: u0 }
            (map-get? query-stats user))))
        (if (and (is-eq (get last-query-block stats) stacks-block-height)
                 (>= (get queries-this-block stats) RATE_LIMIT_PER_BLOCK))
            false
            true)))

;; Update query statistics
(define-private (update-query-stats (user principal) (success bool) (premium bool))
    (let ((current-stats (default-to 
            { total-queries: u0, successful-queries: u0, failed-queries: u0, 
              premium-queries: u0, last-query-block: u0, queries-this-block: u0, 
              total-fees-paid: u0 }
            (map-get? query-stats user)))
          (queries-this-block (if (is-eq (get last-query-block current-stats) stacks-block-height)
                                 (+ (get queries-this-block current-stats) u1)
                                 u1)))
        (map-set query-stats user
            (merge current-stats {
                total-queries: (+ (get total-queries current-stats) u1),
                successful-queries: (if success 
                    (+ (get successful-queries current-stats) u1)
                    (get successful-queries current-stats)),
                failed-queries: (if success 
                    (get failed-queries current-stats)
                    (+ (get failed-queries current-stats) u1)),
                premium-queries: (if premium
                    (+ (get premium-queries current-stats) u1)
                    (get premium-queries current-stats)),
                last-query-block: stacks-block-height,
                queries-this-block: queries-this-block,
                total-fees-paid: (+ (get total-fees-paid current-stats)
                    (if premium PREMIUM_QUERY_FEE QUERY_FEE))
            }))))

;; Cache query results
(define-private (cache-query-result 
    (query-hash (buff 32))
    (result-hash (buff 32))
    (result-count uint))
    (map-set query-cache query-hash {
        query-hash: query-hash,
        result-hash: result-hash,
        result-count: result-count,
        cached-at: stacks-block-height,
        expires-at: (+ stacks-block-height u144), ;; Cache for ~24 hours
        hit-count: u1
    }))

;; Update indexer reputation
(define-private (update-indexer-reputation (indexer principal) (success bool))
    (match (map-get? registered-indexers indexer)
        indexer-info (map-set registered-indexers indexer
            (merge indexer-info {
                reputation-score: (if success
                    (min-uint u1000 (+ (get reputation-score indexer-info) u5))
                    (max-uint u0 (- (get reputation-score indexer-info) u10)))
            }))
        false))

;; Public Functions

;; Register as a blockchain data indexer
(define-public (register-indexer 
    (name (string-ascii 64))
    (indexer-type uint))
    (let ((bond-amount INDEXER_BOND))
        (asserts! (is-none (map-get? registered-indexers tx-sender)) ERR_INDEXER_NOT_REGISTERED)
        
        ;; Transfer bond
        (try! (stx-transfer? bond-amount tx-sender (as-contract tx-sender)))
        
        (map-set registered-indexers tx-sender {
            name: name,
            indexer-type: indexer-type,
            bond-amount: bond-amount,
            active: true,
            blocks-indexed: u0,
            last-indexed-height: u0,
            reputation-score: u500,
            registered-at: stacks-block-height
        })
        
        (ok true)))

;; Index a block with its basic information
(define-public (index-block
    (height uint)
    (block-hash (buff 32))
    (parent-hash (buff 32))
    (timestamp uint)
    (miner (optional principal))
    (transaction-count uint)
    (total-fees uint)
    (block-size uint)
    (difficulty uint))
    (let ((block-index-id (var-get next-block-index))
          (indexer-info (unwrap! (map-get? registered-indexers tx-sender) ERR_INDEXER_NOT_REGISTERED)))
        
        (asserts! (get active indexer-info) ERR_NOT_AUTHORIZED)
        (asserts! (> height (get last-indexed-height indexer-info)) ERR_INVALID_BLOCK)
        
        (map-set block-index block-index-id {
            block-height: height,
            block-hash: block-hash,
            parent-hash: parent-hash,
            timestamp: timestamp,
            miner: miner,
            transaction-count: transaction-count,
            total-fees: total-fees,
            block-size: block-size,
            difficulty: difficulty,
            indexed-by: tx-sender,
            indexed-at: stacks-block-height
        })
        
        ;; Update indexer stats
        (map-set registered-indexers tx-sender
            (merge indexer-info {
                blocks-indexed: (+ (get blocks-indexed indexer-info) u1),
                last-indexed-height: height
            }))
        
        (var-set next-block-index (+ block-index-id u1))
        (var-set current-indexed-height (max-uint (var-get current-indexed-height) height))
        (update-indexer-reputation tx-sender true)
        (ok block-index-id)))

;; Index a transaction with detailed information
(define-public (index-transaction
    (tx-hash (buff 32))
    (height uint)
    (tx-type (string-ascii 32))
    (sender principal)
    (recipient (optional principal))
    (amount (optional uint))
    (fee uint)
    (nonce uint)
    (contract-address (optional principal))
    (function-name (optional (string-ascii 64)))
    (success bool)
    (error-code (optional uint))
    (events-count uint))
    (let ((tx-index-id (var-get next-transaction-index))
          (block-data (map-get? block-index height)))
        
        (asserts! (is-some (map-get? registered-indexers tx-sender)) ERR_INDEXER_NOT_REGISTERED)
        (asserts! (is-some block-data) ERR_INVALID_BLOCK)
        
        (map-set transaction-index tx-index-id {
            tx-hash: tx-hash,
            block-height: height,
            block-index: height,
            tx-type: tx-type,
            sender: sender,
            recipient: recipient,
            amount: amount,
            fee: fee,
            nonce: nonce,
            contract-address: contract-address,
            function-name: function-name,
            success: success,
            error-code: error-code,
            events-count: events-count,
            indexed-at: stacks-block-height
        })
        
        ;; Update address activity
        (update-address-activity sender height amount true)
        (match recipient
            addr (update-address-activity addr height amount false)
            true)
        
        (var-set next-transaction-index (+ tx-index-id u1))
        (ok tx-index-id)))

;; Index contract deployment or update contract statistics
(define-public (index-contract
    (contract-address principal)
    (deployer principal)
    (contract-name (string-ascii 64))
    (deployed-at-height uint)
    (source-code-hash (buff 32))
    (contract-type (string-ascii 32)))
    (begin
        (asserts! (is-some (map-get? registered-indexers tx-sender)) ERR_INDEXER_NOT_REGISTERED)
        
        (map-set contract-index contract-address {
            deployer: deployer,
            contract-name: contract-name,
            deployed-at-height: deployed-at-height,
            deployed-at-time: stacks-block-height,
            source-code-hash: source-code-hash,
            total-calls: u0,
            unique-callers: u0,
            last-call-height: u0,
            contract-type: contract-type,
            is-active: true
        })
        
        (ok true)))

;; Index an event log
(define-public (index-event
    (tx-hash (buff 32))
    (tx-index uint)
    (height uint)
    (contract-address principal)
    (event-type (string-ascii 64))
    (event-data (buff 256))
    (topics (list 4 (buff 32))))
    (let ((event-index-id (var-get next-event-index)))
        
        (asserts! (is-some (map-get? registered-indexers tx-sender)) ERR_INDEXER_NOT_REGISTERED)
        
        (map-set event-index event-index-id {
            tx-hash: tx-hash,
            tx-index: tx-index,
            block-height: height,
            contract-address: contract-address,
            event-type: event-type,
            event-data: event-data,
            topics: topics,
            indexed-at: stacks-block-height
        })
        
        (var-set next-event-index (+ event-index-id u1))
        (ok event-index-id)))

;; Index token transfer
(define-public (index-token-transfer
    (tx-hash (buff 32))
    (height uint)
    (token-contract principal)
    (from-address principal)
    (to-address principal)
    (amount uint)
    (memo (optional (buff 64)))
    (transfer-type (string-ascii 32)))
    (let ((transfer-index-id (var-get next-transaction-index)))
        
        (asserts! (is-some (map-get? registered-indexers tx-sender)) ERR_INDEXER_NOT_REGISTERED)
        
        (map-set token-transfer-index transfer-index-id {
            tx-hash: tx-hash,
            block-height: height,
            token-contract: token-contract,
            from-address: from-address,
            to-address: to-address,
            amount: amount,
            memo: memo,
            transfer-type: transfer-type,
            indexed-at: stacks-block-height
        })
        
        (ok transfer-index-id)))

;; Update address activity helper
(define-private (update-address-activity
    (address principal)
    (height uint)
    (amount (optional uint))
    (is-sender bool))
    (let ((current-activity (default-to
            { first-seen-height: height, last-seen-height: height,
              transaction-count: u0, sent-amount: u0, received-amount: u0,
              contract-calls: u0, contracts-deployed: u0, tokens-held: (list),
              nft-count: u0, address-type: "user" }
            (map-get? address-index address))))
        (map-set address-index address
            (merge current-activity {
                last-seen-height: height,
                transaction-count: (+ (get transaction-count current-activity) u1),
                sent-amount: (if (and is-sender (is-some amount))
                    (+ (get sent-amount current-activity) (unwrap-panic amount))
                    (get sent-amount current-activity)),
                received-amount: (if (and (not is-sender) (is-some amount))
                    (+ (get received-amount current-activity) (unwrap-panic amount))
                    (get received-amount current-activity))
            }))))

;; Query Functions

;; Query blocks by height range
(define-public (query-blocks-by-height-range 
    (start-height uint)
    (end-height uint))
    (let ((fee QUERY_FEE))
        (asserts! (check-rate-limit tx-sender) ERR_RATE_LIMIT_EXCEEDED)
        (asserts! (<= start-height end-height) ERR_INVALID_TIME_RANGE)
        (asserts! (<= (- end-height start-height) MAX_RESULTS_PER_QUERY) ERR_TOO_MANY_RESULTS)
        
        ;; Charge query fee
        (try! (stx-transfer? fee tx-sender CONTRACT_OWNER))
        
        (update-query-stats tx-sender true false)
        (var-set total-queries-processed (+ (var-get total-queries-processed) u1))
        
        ;; Return success - actual data would be retrieved off-chain
        (ok { query-id: (var-get next-query-id), result-count: (- end-height start-height) })))

;; Query transactions by hash
(define-read-only (query-transaction-by-hash (tx-hash (buff 32)))
    (let ((query-hash (generate-query-hash QUERY_TYPE_TRANSACTION tx-hash)))
        ;; Check cache first
        (match (map-get? query-cache query-hash)
            cached-result (some cached-result)
            ;; Search through transaction index - simplified for demo
            none)))

;; Query address activity
(define-public (query-address-activity (address principal))
    (let ((fee QUERY_FEE))
        (asserts! (check-rate-limit tx-sender) ERR_RATE_LIMIT_EXCEEDED)
        
        (try! (stx-transfer? fee tx-sender CONTRACT_OWNER))
        (update-query-stats tx-sender true false)
        
        (ok (map-get? address-index address))))

;; Query contract information
(define-read-only (query-contract-info (contract-address principal))
    (map-get? contract-index contract-address))

;; Complex query using premium service
(define-public (premium-query
    (query-type uint)
    (parameters (buff 256))
    (max-results uint))
    (let ((fee PREMIUM_QUERY_FEE))
        (asserts! (check-rate-limit tx-sender) ERR_RATE_LIMIT_EXCEEDED)
        (asserts! (<= max-results MAX_RESULTS_PER_QUERY) ERR_TOO_MANY_RESULTS)
        
        (try! (stx-transfer? fee tx-sender CONTRACT_OWNER))
        (update-query-stats tx-sender true true)
        
        ;; Generate unique query ID for tracking
        (let ((query-id (var-get next-query-id)))
            (var-set next-query-id (+ query-id u1))
            (ok { query-id: query-id, estimated-results: max-results }))))

;; Query events by contract and type
(define-public (query-events
    (contract-address principal)
    (event-type (optional (string-ascii 64)))
    (from-block uint)
    (to-block uint))
    (let ((fee QUERY_FEE))
        (asserts! (check-rate-limit tx-sender) ERR_RATE_LIMIT_EXCEEDED)
        (asserts! (<= from-block to-block) ERR_INVALID_TIME_RANGE)
        
        (try! (stx-transfer? fee tx-sender CONTRACT_OWNER))
        (update-query-stats tx-sender true false)
        
        (ok { contract: contract-address, from: from-block, to: to-block })))

;; Query token transfers
(define-public (query-token-transfers
    (token-contract principal)
    (from-address (optional principal))
    (to-address (optional principal))
    (from-block uint)
    (to-block uint))
    (let ((fee QUERY_FEE))
        (asserts! (check-rate-limit tx-sender) ERR_RATE_LIMIT_EXCEEDED)
        (asserts! (<= from-block to-block) ERR_INVALID_TIME_RANGE)
        
        (try! (stx-transfer? fee tx-sender CONTRACT_OWNER))
        (update-query-stats tx-sender true false)
        
        (ok { token: token-contract, from-block: from-block, to-block: to-block })))

;; Read-only Functions

;; Get indexer information
(define-read-only (get-indexer-info (indexer principal))
    (map-get? registered-indexers indexer))

;; Get current indexing status
(define-read-only (get-indexing-status)
    {
        current-indexed-height: (var-get current-indexed-height),
        total-blocks-indexed: (var-get next-block-index),
        total-transactions-indexed: (var-get next-transaction-index),
        total-events-indexed: (var-get next-event-index),
        total-queries-processed: (var-get total-queries-processed),
        current-block: stacks-block-height
    })

;; Get query statistics for user
(define-read-only (get-user-query-stats (user principal))
    (map-get? query-stats user))

;; Get cached query result
(define-read-only (get-cached-query (query-hash (buff 32)))
    (match (map-get? query-cache query-hash)
        cached-result (if (> (get expires-at cached-result) stacks-block-height)
                        (some cached-result)
                        none)
        none))

;; Get system analytics
(define-read-only (get-system-analytics (metric-name (string-ascii 64)))
    (map-get? analytics-data u1)) ;; Simplified - would have proper metric lookup

;; Administrative Functions

;; Update query fees
(define-public (update-query-fees 
    (new-basic-fee uint)
    (new-premium-fee uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        ;; In a full implementation, would update fee variables
        (ok true)))

;; Pause/unpause indexer
(define-public (toggle-indexer-status (indexer principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (match (map-get? registered-indexers indexer)
            indexer-info (begin
                        (map-set registered-indexers indexer
                            (merge indexer-info { active: (not (get active indexer-info)) }))
                        (ok true))
            ERR_INDEXER_NOT_REGISTERED)))

;; Withdraw accumulated fees
(define-public (withdraw-fees (amount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        (try! (as-contract (stx-transfer? amount tx-sender CONTRACT_OWNER)))
        (ok amount)))

;; Emergency functions
(define-public (emergency-pause)
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        ;; Would implement emergency pause logic
        (ok true)))

;; Batch operations for efficiency
(define-public (batch-index-transactions (transactions (list 50 { 
    tx-hash: (buff 32),
    block-height: uint,
    tx-type: (string-ascii 32),
    sender: principal,
    recipient: (optional principal),
    amount: (optional uint),
    fee: uint,
    success: bool })))
    (begin
        (asserts! (is-some (map-get? registered-indexers tx-sender)) ERR_INDEXER_NOT_REGISTERED)
        ;; Would implement batch processing
        (ok (len transactions))))

;; Analytics and reporting
(define-public (generate-analytics-report 
    (metric-type (string-ascii 32))
    (time-period uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
        ;; Would implement analytics generation
        (ok true)))