# Exhibition and Art Grants Platform

A decentralized smart contract built on the Stacks blockchain for managing and distributing arts council grants, promoting creativity worldwide through transparent and automated grant distribution.

## Overview

This platform enables arts councils to efficiently manage artist approvals, distribute grants through fungible tokens, and maintain transparent records of all grant activities. The system supports bulk operations, configurable grant amounts, and automated redistribution of unclaimed funds.

## Features

### Core Functionality
- **Artist Approval System**: Arts councils can approve and revoke artist eligibility
- **Grant Distribution**: Automated token-based grant distribution to approved artists
- **Bulk Operations**: Efficient batch approval of multiple artists
- **Configurable Parameters**: Adjustable grant amounts and showcase periods
- **Event Logging**: Comprehensive tracking of all platform activities
- **Fund Redistribution**: Automatic reallocation of unclaimed grants after showcase periods

### Token Economics
- **Native Token**: `creative-grant-token` fungible token for grant distribution
- **Initial Supply**: 1 billion tokens minted to the arts council
- **Per-Artist Grant**: Configurable amount (default: 100 tokens)
- **Burn Mechanism**: Unclaimed grants are burned after redistribution periods

## Contract Architecture

### Constants
```clarity
ARTS-COUNCIL                    // Contract deployer address
ERROR-NOT-ARTS-COUNCIL         // Authorization error (u100)
ERROR-GRANT-ALREADY-AWARDED    // Duplicate grant error (u101)
ERROR-ARTIST-NOT-APPROVED      // Artist eligibility error (u102)
ERROR-INSUFFICIENT-GRANT-FUNDS // Funding error (u103)
ERROR-EXHIBITION-SEASON-INACTIVE // Season status error (u104)
ERROR-INVALID-GRANT-AMOUNT     // Amount validation error (u105)
ERROR-SHOWCASE-PERIOD-NOT-ENDED // Timing error (u106)
ERROR-INVALID-ARTIST           // Artist validation error (u107)
ERROR-INVALID-EXHIBITION-PERIOD // Period validation error (u108)
```

### Data Storage
- **Artist Approvals**: Mapping of approved exhibition artists
- **Grant Awards**: Record of distributed grant amounts per artist
- **Exhibition Events**: Comprehensive event logging system
- **Configuration**: Adjustable grant amounts and showcase periods

## Public Functions

### Arts Council Functions

#### `approve-exhibition-artist`
```clarity
(approve-exhibition-artist (artist-address principal))
```
Approves an artist for exhibition grant eligibility.
- **Caller**: Arts council only
- **Returns**: `(response bool uint)`

#### `revoke-artist-approval`
```clarity
(revoke-artist-approval (artist-address principal))
```
Revokes an artist's exhibition eligibility.
- **Caller**: Arts council only
- **Returns**: `(response bool uint)`

#### `bulk-approve-artists`
```clarity
(bulk-approve-artists (artist-addresses (list 200 principal)))
```
Approves multiple artists in a single transaction (up to 200).
- **Caller**: Arts council only
- **Returns**: `(response (list 200 (response bool uint)) uint)`

#### `update-grant-amount`
```clarity
(update-grant-amount (new-amount uint))
```
Updates the grant amount per artist.
- **Caller**: Arts council only
- **Parameter**: `new-amount` must be greater than 0
- **Returns**: `(response uint uint)`

#### `update-showcase-period`
```clarity
(update-showcase-period (new-period uint))
```
Updates the showcase period length in blocks.
- **Caller**: Arts council only
- **Parameter**: `new-period` must be greater than 0
- **Returns**: `(response uint uint)`

### Artist Functions

#### `claim-artist-grant`
```clarity
(claim-artist-grant)
```
Allows approved artists to claim their grants.
- **Caller**: Any approved artist
- **Requirements**:
  - Exhibition season must be active
  - Artist must be approved
  - Grant not previously claimed
  - Sufficient funds available
- **Returns**: `(response uint uint)`

### Administrative Functions

#### `redistribute-unclaimed-grants`
```clarity
(redistribute-unclaimed-grants)
```
Burns unclaimed grants after the showcase period ends.
- **Caller**: Arts council only
- **Requirements**: Showcase period must have ended
- **Returns**: `(response uint uint)`

## Read-Only Functions

### Status Queries
- `get-exhibition-season-status()` - Returns exhibition season status
- `is-artist-approved(artist-address)` - Checks artist approval status
- `has-artist-claimed-grant(artist-address)` - Checks if artist claimed grant
- `get-artist-grant-amount(artist-address)` - Returns artist's grant amount
- `get-total-grants-awarded()` - Returns total grants distributed
- `get-grant-amount-per-artist()` - Returns current grant amount per artist
- `get-showcase-period()` - Returns showcase period length
- `get-exhibition-season-start-block()` - Returns season start block
- `get-exhibition-event(event-id)` - Returns specific event details

## Usage Examples

### For Arts Councils

```clarity
;; Approve a single artist
(contract-call? .exhibition-grants approve-exhibition-artist 'SP1ABC...)

;; Bulk approve multiple artists
(contract-call? .exhibition-grants bulk-approve-artists 
  (list 'SP1ABC... 'SP2DEF... 'SP3GHI...))

;; Update grant amount to 150 tokens
(contract-call? .exhibition-grants update-grant-amount u150)

;; Redistribute unclaimed grants after showcase period
(contract-call? .exhibition-grants redistribute-unclaimed-grants)
```

### For Artists

```clarity
;; Check approval status
(contract-call? .exhibition-grants is-artist-approved tx-sender)

;; Claim grant
(contract-call? .exhibition-grants claim-artist-grant)

;; Check grant amount received
(contract-call? .exhibition-grants get-artist-grant-amount tx-sender)
```

## Event Tracking

The contract logs various events for transparency:

- `artist-approved` - New artist approved for exhibition
- `approval-revoked` - Artist approval revoked
- `bulk-approval` - Multiple artists approved
- `grant-updated` - Grant amount updated
- `period-updated` - Showcase period updated
- `grant-awarded` - Grant awarded to artist
- `grants-redistributed` - Unclaimed grants redistributed

## Security Features

- **Access Control**: Only arts council can perform administrative functions
- **Duplicate Prevention**: Artists cannot claim grants multiple times
- **Balance Validation**: Ensures sufficient funds before grant distribution
- **Time-based Controls**: Showcase period enforcement for redistribution
- **Input Validation**: Comprehensive parameter checking

## Deployment

1. Deploy the contract to Stacks blockchain
2. The deployer becomes the arts council
3. Initial token supply (1 billion tokens) is minted to arts council
4. Configure grant amounts and showcase periods as needed
5. Begin approving artists and distributing grants

## Configuration

### Default Values
- **Grant per Artist**: 100 tokens
- **Showcase Period**: 10,000 blocks (~69 days)
- **Initial Token Supply**: 1,000,000,000 tokens
- **Exhibition Season**: Active by default

### Recommended Settings
- Adjust showcase period based on exhibition duration
- Set grant amounts according to funding availability
- Use bulk approval for efficiency with large artist cohorts

## Integration

This contract can be integrated with:
- Web3 frontends for artist and arts council dashboards
- Gallery management systems
- NFT marketplaces for exhibition pieces
- Analytics platforms for grant distribution tracking


