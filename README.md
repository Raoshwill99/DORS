# Compact Decentralized Oracle System (CDOS)

A streamlined and efficient decentralized oracle system built on the Stacks blockchain using Clarity smart contracts. CDOS provides reliable price feed data through a simplified stake-weighted consensus mechanism focused on core oracle functionality.

## Overview

CDOS addresses the oracle problem with a lean, efficient approach that maintains security and reliability while reducing complexity. The system uses economic incentives through staking requirements and accuracy-based consensus to ensure trustworthy price data.

### Key Features

- **Simplified Oracle Registration**: 
  - Minimum stake requirement: 1,000,000 microSTX
  - Streamlined registration process
  - Basic accuracy tracking

- **Essential Price Submission**: 
  - Direct price submission system
  - Round-based consensus mechanism
  - Duplicate submission protection

- **Core Consensus Mechanism**:
  - Minimum 3 oracle requirement for consensus
  - Simple averaging algorithm (upgradeable to median)
  - Automated round finalization

- **Lightweight Architecture**:
  - ~80 lines of Clarity code
  - Reduced gas costs
  - Easy to audit and maintain

## Technical Architecture

### Smart Contract Structure

The compact system uses three main data structures:

```clarity
;; Oracle Registry
(define-map oracles 
    principal 
    {
        stake: uint,
        active: bool,
        accuracy: uint
    }
)

;; Price Round Data
(define-map price-data
    uint
    {
        price: (optional uint),
        submissions: uint,
        closed: bool
    }
)

;; Submission Tracking
(define-map submissions
    {round: uint, oracle: principal}
    uint
)
```

### Core Functions

1. **Oracle Registration**
   - `register-oracle`: Register with minimum stake requirement

2. **Price Submission**
   - `submit-price`: Submit price data for current round

3. **Consensus Mechanism**
   - `finalize-round`: Close round and establish consensus price

4. **Data Access**
   - `get-oracle`: Retrieve oracle information
   - `get-current-price`: Get latest consensus price
   - `get-round-info`: Get specific round data

## Setup Instructions

### Prerequisites

- Stacks blockchain environment (testnet or mainnet)
- Clarity CLI tools
- Minimum 1,000,000 microSTX for staking
- Node.js (optional, for testing)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/compact-oracle.git
cd compact-oracle
```

2. Deploy the contract:
```bash
clarinet contract deploy compact-oracle
```

### Usage

Register as an oracle:
```clarity
(contract-call? .compact-oracle register-oracle)
```

Submit price data:
```clarity
(contract-call? .compact-oracle submit-price u1000000)
```

Finalize a round:
```clarity
(contract-call? .compact-oracle finalize-round)
```

Get current price:
```clarity
(contract-call? .compact-oracle get-current-price)
```

## Testing

Run the test suite:
```bash
clarinet test
```

## Security Features

### Core Security Mechanisms

- **Stake Requirements**: Economic security through minimum stake
- **Duplicate Prevention**: One submission per oracle per round
- **Consensus Threshold**: Minimum oracle participation required
- **Round Isolation**: Submissions isolated by round ID

### Limitations

This compact version prioritizes simplicity over advanced features:
- No multi-source verification
- Basic consensus algorithm
- Limited attack vector protection
- No sophisticated slashing mechanisms

## Performance

### Gas Efficiency
- Minimal storage operations
- Optimized data structures
- Reduced computational complexity

### Metrics
```clarity
;; Simple accuracy tracking
accuracy = (correct-submissions / total-submissions) × 100
```

## Development Roadmap

### Current Version (v1.0)
- Basic oracle registration ✅
- Simple price submission ✅
- Round-based consensus ✅
- Essential read functions ✅

### Future Enhancements
- Enhanced consensus algorithms (median instead of average)
- Multi-source data integration
- Advanced verification methods
- Governance mechanisms

## API Reference

### Public Functions

```clarity
;; Register as an oracle
(register-oracle) -> (response bool uint)

;; Submit price for current round
(submit-price uint) -> (response bool uint)

;; Finalize current round
(finalize-round) -> (response uint uint)
```

### Read-Only Functions

```clarity
;; Get oracle data
(get-oracle principal) -> (optional oracle-data)

;; Get latest consensus price
(get-current-price) -> (optional uint)

;; Get round information
(get-round-info uint) -> (optional round-data)
```

## Error Codes

- `u1`: Oracle not registered or insufficient stake
- `u2`: Oracle inactive
- `u3`: Already submitted for current round
- `u4`: Round data not found
- `u5`: Round already closed
- `u6`: Insufficient oracle participation

## Contributing

We welcome contributions! Areas of focus:

1. **Consensus Improvements**: Enhance the averaging mechanism
2. **Security Auditing**: Review and test the contract
3. **Documentation**: Improve guides and examples
4. **Testing**: Add comprehensive test coverage

### Development Guidelines

- Follow Clarity best practices
- Include unit tests for new features
- Document all functions and error cases
- Maintain code simplicity and readability

## Migration from Complex Systems

If migrating from a more complex oracle system:

1. **Data Migration**: Export historical price data
2. **Oracle Re-registration**: Existing oracles need to re-register
3. **Stake Transfer**: Move existing stakes to new contract
4. **Integration Updates**: Update consuming contracts

## License

This project is licensed under the MIT License.

## Changelog

### v1.0.0 (Current)
- Initial compact release
- Basic oracle registration
- Simple price submission system
- Round-based consensus mechanism
- Essential read-only functions

## Acknowledgments

- Stacks Foundation for blockchain infrastructure
- Clarity language development team
- Oracle research community
- Contributors and testers
