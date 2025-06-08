# Blockchain Data Indexer

A comprehensive blockchain data indexing and query service built on Stacks that provides efficient indexing, storage, and querying capabilities for blockchain data including blocks, transactions, contracts, events, and address activities.

## Overview

The Blockchain Data Indexer is a decentralized service that allows registered indexers to systematically catalog blockchain data and provides a paid query API for developers and applications to access this indexed information efficiently.

## Features

### Core Indexing Capabilities
- **Block Indexing**: Complete block data including metadata, transactions, and mining information
- **Transaction Indexing**: Detailed transaction records with success/failure status and event logs
- **Contract Indexing**: Smart contract deployment tracking and call statistics
- **Event Indexing**: Comprehensive event log storage with topic-based filtering
- **Address Activity**: Complete address transaction history and activity metrics
- **Token Transfers**: Specialized indexing for token movements and transfers

### Query Services
- **Basic Queries**: Standard blockchain data retrieval with reasonable fees
- **Premium Queries**: Complex analytical queries with advanced filtering
- **Cached Results**: Intelligent caching system for frequently requested data
- **Rate Limiting**: Built-in protection against query spam
- **Batch Operations**: Efficient bulk data processing

### Economic Model
- **Indexer Registration**: Stake-based registration system with reputation scoring
- **Query Fees**: Pay-per-query model with different tiers
- **Indexer Rewards**: Incentivized data indexing through fee sharing
- **Bond System**: Security bonds for indexer accountability

## Architecture

### Data Structures

#### Indexer Management
- **Registered Indexers**: Qualified data providers with staked bonds
- **Reputation System**: Performance-based scoring for indexer reliability
- **Multi-tier Indexing**: Support for full-node, specialized, and archive indexers

#### Data Indexes
- **Block Index**: Height-based and hash-based block lookups
- **Transaction Index**: Hash-based transaction retrieval with metadata
- **Contract Index**: Contract deployment and interaction tracking
- **Event Index**: Event log storage with topic-based filtering
- **Address Index**: Comprehensive address activity tracking
- **Token Transfer Index**: Specialized token movement tracking

#### Query Infrastructure
- **Query Cache**: Automatic caching of frequently requested data
- **Rate Limiting**: Per-user query limits to prevent abuse
- **Query Statistics**: Usage tracking and analytics
- **Template System**: Reusable query patterns for complex operations

## Getting Started

### For Indexers

#### 1. Register as an Indexer
```clarity
(contract-call? .blockchain-data-indexer register-indexer 
    "My Indexer Service" 
    u1) ;; 1=full-node, 2=specialized, 3=archive
```

**Requirements:**
- Stake 20 STX as a security bond
- Choose indexer type based on your capabilities
- Maintain good reputation through reliable indexing

#### 2. Start Indexing Data

**Index Blocks:**
```clarity
(contract-call? .blockchain-data-indexer index-block
    block-height
    block-hash
    parent-hash
    timestamp
    miner
    transaction-count
    total-fees
    block-size
    difficulty)
```

**Index Transactions:**
```clarity
(contract-call? .blockchain-data-indexer index-transaction
    tx-hash
    block-height
    tx-type
    sender
    recipient
    amount
    fee
    nonce
    contract-address
    function-name
    success
    error-code
    events-count)
```

### For Developers/Users

#### 1. Basic Queries

**Query Block Range:**
```clarity
(contract-call? .blockchain-data-indexer query-blocks-by-height-range
    start-height
    end-height)
```
*Cost: 0.1 STX per query*

**Query Address Activity:**
```clarity
(contract-call? .blockchain-data-indexer query-address-activity
    'SP1234567890ABCDEF...)
```

**Query Contract Information:**
```clarity
(contract-call? .blockchain-data-indexer query-contract-info
    'SP1234567890ABCDEF.my-contract)
```

#### 2. Advanced Queries

**Premium Complex Queries:**
```clarity
(contract-call? .blockchain-data-indexer premium-query
    query-type
    parameters-buffer
    max-results)
```
*Cost: 0.5 STX per query*

**Event Queries:**
```clarity
(contract-call? .blockchain-data-indexer query-events
    contract-address
    (some "transfer")
    from-block
    to-block)
```

**Token Transfer Queries:**
```clarity
(contract-call? .blockchain-data-indexer query-token-transfers
    token-contract
    (some from-address)
    (some to-address)
    from-block
    to-block)
```

## Economic Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| Indexer Registration Fee | 5 STX | One-time fee to register as indexer |
| Indexer Bond | 20 STX | Security deposit for indexers |
| Basic Query Fee | 0.1 STX | Standard query cost |
| Premium Query Fee | 0.5 STX | Complex query cost |
| Rate Limit | 10 queries/block | Maximum queries per user per block |
| Max Results | 100 | Maximum results per query |
| Cache Duration | 144 blocks | ~24 hours cache lifetime |

## Query Types

### Basic Query Types
- `QUERY_TYPE_BLOCK (1)`: Block data queries
- `QUERY_TYPE_TRANSACTION (2)`: Transaction lookups
- `QUERY_TYPE_CONTRACT (3)`: Contract information
- `QUERY_TYPE_EVENT (4)`: Event log searches
- `QUERY_TYPE_ADDRESS (5)`: Address activity
- `QUERY_TYPE_TOKEN_TRANSFER (6)`: Token movements
- `QUERY_TYPE_CONTRACT_CALL (7)`: Contract interactions
- `QUERY_TYPE_CUSTOM (8)`: Custom query templates

### Index Types
- `INDEX_TYPE_BLOCK_HEIGHT (1)`: Height-based indexing
- `INDEX_TYPE_BLOCK_HASH (2)`: Hash-based block lookup
- `INDEX_TYPE_TX_HASH (3)`: Transaction hash indexing
- `INDEX_TYPE_ADDRESS (4)`: Address-based indexing
- `INDEX_TYPE_CONTRACT (5)`: Contract-based indexing
- `INDEX_TYPE_TOKEN (6)`: Token-specific indexing
- `INDEX_TYPE_EVENT (7)`: Event log indexing
- `INDEX_TYPE_TIME (8)`: Time-based indexing

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 100 | ERR_NOT_AUTHORIZED | Unauthorized access |
| 101 | ERR_INVALID_BLOCK | Invalid block data |
| 102 | ERR_INVALID_TRANSACTION | Invalid transaction data |
| 103 | ERR_INDEX_NOT_FOUND | Requested index not found |
| 104 | ERR_INVALID_QUERY | Malformed query |
| 105 | ERR_INDEXER_NOT_REGISTERED | Indexer not registered |
| 106 | ERR_INSUFFICIENT_PAYMENT | Insufficient fee payment |
| 107 | ERR_RATE_LIMIT_EXCEEDED | Too many queries |
| 108 | ERR_INVALID_TIME_RANGE | Invalid time range |
| 109 | ERR_TOO_MANY_RESULTS | Result set too large |
| 110 | ERR_INVALID_CONTRACT | Invalid contract address |

## Indexer Types

### Full Node Indexers (Type 1)
- Index complete blockchain data
- Highest reputation weight
- Eligible for all data types

### Specialized Indexers (Type 2)
- Focus on specific data types (e.g., DeFi, NFTs)
- Moderate reputation weight
- Expert in particular domains

### Archive Indexers (Type 3)
- Historical data specialists
- Long-term data preservation
- Essential for historical queries

## Data Quality & Reputation

### Reputation Scoring
- **Starting Score**: 500 points
- **Successful Index**: +5 points (max 1000)
- **Failed Index**: -10 points (min 0)
- **Reputation Affects**: Query result prioritization

### Quality Assurance
- Cross-verification between multiple indexers
- Automatic reputation adjustment
- Slashing for malicious behavior

## Monitoring & Analytics

### System Status
```clarity
(contract-call? .blockchain-data-indexer get-indexing-status)
```

**Returns:**
- Current indexed height
- Total blocks/transactions/events indexed
- Total queries processed
- Current block height

### User Statistics
```clarity
(contract-call? .blockchain-data-indexer get-user-query-stats user-address)
```

**Returns:**
- Total queries made
- Success/failure rates
- Premium query usage
- Total fees paid

## Administrative Functions

### Contract Owner Functions
- Update query fees
- Pause/unpause indexers
- Withdraw accumulated fees
- Emergency pause system
- Generate analytics reports

### Emergency Procedures
- System-wide pause capability
- Indexer suspension
- Fee adjustment mechanisms

## Development Roadmap

### Phase 1: Core Infrastructure ✅
- Basic indexing capabilities
- Simple query system
- Economic model implementation

### Phase 2: Advanced Features (Current)
- Premium query services
- Complex analytical queries
- Enhanced caching system

### Phase 3: Analytics & Reporting
- Business intelligence tools
- Custom dashboard creation
- API integration services

### Phase 4: Scaling & Optimization
- Horizontal scaling solutions
- Performance optimizations
- Advanced query optimization

## Integration Examples

### Web3 Application Integration
```javascript
// Example using Stacks.js
const queryResult = await contractCall({
    contractAddress: 'SP...',
    contractName: 'blockchain-data-indexer',
    functionName: 'query-address-activity',
    functionArgs: [standardPrincipalCV(address)],
    network: new StacksMainnet()
});
```

### Analytics Dashboard
```javascript
// Fetch system statistics
const stats = await contractCall({
    contractAddress: 'SP...',
    contractName: 'blockchain-data-indexer',
    functionName: 'get-indexing-status',
    functionArgs: [],
    network: new StacksMainnet()
});
```

## Security Considerations

### Indexer Security
- Bond-based registration prevents malicious actors
- Reputation system ensures data quality
- Multi-indexer verification for critical data

### Query Security
- Rate limiting prevents DoS attacks
- Fee structure discourages spam
- Input validation on all queries

### Economic Security
- Staking mechanism aligns incentives
- Slashing conditions for misbehavior
- Fee distribution rewards good actors

## Contributing

### For Indexers
1. Register with appropriate bond
2. Follow indexing standards
3. Maintain high uptime and accuracy
4. Participate in community governance

### For Developers
1. Use the query API responsibly
2. Implement proper error handling
3. Cache results when appropriate
4. Provide feedback on query performance

### For the Community
1. Report bugs and issues
2. Suggest feature improvements
3. Participate in governance discussions
4. Help with documentation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Documentation**: [docs.blockchain-indexer.com](https://docs.blockchain-indexer.com)
- **Community**: [Discord](https://discord.gg/blockchain-indexer)
- **Issues**: [GitHub Issues](https://github.com/blockchain-indexer/issues)
- **Email**: support@blockchain-indexer.com

## Acknowledgments

- Stacks blockchain for the underlying infrastructure
- Community contributors and early adopters
- Indexer operators maintaining the network
- Developers building on the platform

---

*Built with ❤️ for the Stacks ecosystem*