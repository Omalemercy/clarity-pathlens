# PathLens
A decentralized career path mapping platform built on Stacks using Clarity smart contracts.

## Features
- Create and manage career paths
- Add milestones and certifications 
- Connect with mentors
- Track progress on career goals
- Earn achievements for completing milestones

## Setup and Installation
1. Clone the repository
2. Install Clarinet
3. Run `clarinet check` to verify contracts
4. Run `clarinet test` to run test suite

## Usage Examples
```clarity
;; Create a new career path
(contract-call? .pathlens create-path "Software Engineer" "Path to becoming a senior software engineer")

;; Add milestone to path
(contract-call? .pathlens add-milestone 1 "Learn JavaScript" "Master JavaScript fundamentals" u30)

;; Connect with mentor
(contract-call? .pathlens connect-mentor 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Complete milestone
(contract-call? .pathlens complete-milestone 1)
```

## Dependencies
- Clarity language
- Clarinet for testing and deployment
