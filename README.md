# Decentralized Oracle Redundancy System (DORS)

A robust and secure decentralized oracle system built on the Stacks blockchain using Clarity smart contracts. DORS provides reliable price feed data through a sophisticated stake-weighted consensus mechanism with multiple data source integration.

## Overview

DORS solves the oracle problem in blockchain networks by implementing a redundant, stake-weighted system where multiple oracle nodes provide and verify data. The system ensures high reliability through economic incentives, round-based consensus mechanisms, and performance tracking.

### Key Features

- **Advanced Stake-Based Participation**: 
  - Minimum stake requirement: 1,000,000 microSTX
  - Stake-weighted voting power
  - Dynamic performance scoring

- **Round-Based Consensus**:
  - Time-windowed submission periods
  - Stake-weighted price aggregation
  - Outlier detection and filtering

- **Performance Tracking**:
  - Accuracy scoring system
  - Historical performance metrics
  - Weighted reputation scores

- **Economic Incentives**:
  - Rewards for accurate submissions
  - Penalties for deviation
  - Stake-based influence

## Technical Architecture

### Smart Contracts

The system consists of three main data structures:

```clarity
;; Oracle Node Data
(define-map oracle-nodes 
    principal 
    {
        stake: uint,
        active: bool,
        accuracy-score: uint,
        total-submissions: uint,
        total-correct: uint,
        weighted-score: uint,
        last-submission-height: uint
    }
)

;; Price Round Data
(define-map price-rounds
    uint
    {
        final-price: (optional uint),
        submissions-count: uint,
        consensus-reached: bool,
        round-closed: bool,
        total-stake-weight: uint
    }
)

;; Round Submissions
(define-map round-submissions
    {round-id: uint, oracle: principal}
    {
        price: uint,
        stake-weight: uint,
        verified: bool,
        rewarded: bool
    }
)
```

### Key Functions

1. **Oracle Registration and Management**
   - `register-oracle`: Register as an oracle node with required stake
   - `calculate-stake-weight`: Compute node's influence based on stake and performance

2. **Price Submission System**
   - `submit-price-with-weight`: Submit price data with stake-weighted influence
   - `finalize-round`: Process submissions and determine consensus price

3. **Consensus Mechanism**
   - Round-based submission windows
   - Stake-weighted median calculation
   - Automatic round progression

4. **Performance Tracking**
   - Accuracy score calculation
   - Historical performance metrics
   - Dynamic stake weight adjustments

## Setup Instructions

### Prerequisites

- Stacks blockchain environment (testnet or mainnet)
- Clarity CLI tools
- Minimum stake amount in STX
- Node.js and npm (for testing environment)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/dors.git
cd dors
```

2. Install dependencies:
```bash
npm install
```

3. Deploy the contract:
```bash
clarinet contract deploy oracle-system
```

### Usage

To register as an oracle:
```clarity
(contract-call? .oracle-system register-oracle)
```

To submit price data:
```clarity
(contract-call? .oracle-system submit-price-with-weight u1000000)
```

To check round status:
```clarity
(contract-call? .oracle-system get-round-status u1)
```

## Testing

Run the test suite:
```bash
clarinet test
```

## Security Considerations

- Minimum stake requirement prevents spam
- Time-windowed submissions prevent manipulation
- Stake-weighted consensus reduces attack vectors
- Performance tracking identifies malicious actors
- Economic penalties for bad behavior

## Development Phases

### Phase 1 (Completed)
- Basic oracle registration
- Simple price submission
- Administrative controls

### Phase 2 (Current)
- Enhanced consensus mechanism
- Stake-weighted reporting
- Round-based submissions
- Performance tracking
- Economic incentives

### Future Phases
1. Multiple data source integration
2. Advanced verification methods
3. Cross-chain compatibility
4. Governance mechanisms
5. Advanced economic models

## Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/AmazingFeature`
3. Commit your changes: `git commit -m 'Add some AmazingFeature'`
4. Push to the branch: `git push origin feature/AmazingFeature`
5. Open a Pull Request

### Contribution Guidelines

- Follow Clarity best practices
- Include comprehensive tests
- Update documentation
- Follow the existing code style
- Add inline comments for complex logic

## License

This project is licensed under the MIT License.

## Acknowledgments

- Stacks Foundation
- Clarity Lang Documentation
- Bitcoin Network
- Blockchain Oracle Community

## Changelog

### v0.2.0 (Current)
- Added round-based consensus mechanism
- Implemented stake-weighted reporting
- Enhanced performance tracking
- Added economic incentives

### v0.1.0
- Initial release
- Basic oracle functionality
- Simple price submissions