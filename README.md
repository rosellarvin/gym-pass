# Gym Pass - Fitness Center Membership Smart Contract

A decentralized subscription service for gym and fitness center memberships built on the Stacks blockchain using Clarity smart contracts. This contract enables recurring membership payments, automated access control, and transparent membership management.

## 🏋️ Features

- **Recurring Subscriptions**: Members can subscribe and renew their gym memberships
- **Automated Access Control**: Time-based membership validation using blockchain timestamps
- **Flexible Pricing**: Configurable membership prices and subscription durations
- **Admin Management**: Multi-level admin system for gym operators
- **Payment Tracking**: Complete payment history and subscription status
- **Secure Fund Management**: Owner-controlled revenue withdrawal system

## 📋 Contract Overview

### Default Settings
- **Membership Price**: 1 STX (1,000,000 microSTX)
- **Subscription Duration**: 1 month (2,629,746 seconds)
- **Payment Token**: STX (Stacks native token)

### Key Components
- **Subscriptions**: Member subscription data with start/end times and payment history
- **Admin System**: Role-based access control for gym staff
- **Payment Processing**: Automated STX transfers and balance management

## 🚀 Getting Started

### Prerequisites
- Stacks wallet (Hiro Wallet, Xverse, etc.)
- STX tokens for membership payments
- Clarity CLI or Stacks development environment

### Deployment

1. **Deploy the Contract**
   ```bash
   clarinet deploy --network testnet
   ```

2. **Initial Setup**
   - The contract deployer automatically becomes the owner
   - Set initial membership price and duration if different from defaults
   - Add gym staff as admins

### Basic Usage

#### For Gym Members

**Subscribe to Membership**
```clarity
(contract-call? .gym-pass subscribe)
```

**Check Membership Status**
```clarity
(contract-call? .gym-pass is-member-active 'SP1234567890ABCDEF)
```

**View Subscription Details**
```clarity
(contract-call? .gym-pass get-subscription 'SP1234567890ABCDEF)
```

**Cancel Subscription**
```clarity
(contract-call? .gym-pass cancel-subscription)
```

#### For Gym Operators

**Add Admin Staff**
```clarity
(contract-call? .gym-pass add-admin 'SP1234567890ABCDEF)
```

**Update Membership Price**
```clarity
(contract-call? .gym-pass set-membership-price u2000000) ;; 2 STX
```

**Revoke Member Access**
```clarity
(contract-call? .gym-pass revoke-member-access 'SP1234567890ABCDEF)
```

**Withdraw Revenue**
```clarity
(contract-call? .gym-pass withdraw-all)
```

## 📊 Contract Functions

### Read-Only Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `get-membership-price` | Current membership price | `uint` |
| `get-subscription-duration` | Subscription duration in seconds | `uint` |
| `get-subscription` | Member's subscription details | `(optional subscription)` |
| `is-member-active` | Check if member has active subscription | `bool` |
| `get-contract-balance` | Contract's STX balance | `uint` |
| `is-admin` | Check if user is an admin | `bool` |

### Public Functions

#### Member Functions
- `subscribe()` - Subscribe or renew membership
- `cancel-subscription()` - Deactivate current subscription

#### Admin Functions
- `set-membership-price(uint)` - Update membership price
- `set-subscription-duration(uint)` - Update subscription duration
- `revoke-member-access(principal)` - Revoke member's access

#### Owner Functions
- `add-admin(principal)` - Add new admin
- `remove-admin(principal)` - Remove admin privileges
- `withdraw(uint)` - Withdraw specific amount
- `withdraw-all()` - Withdraw all contract funds

## 🔒 Security Features

### Access Control
- **Owner Only**: Fund withdrawal, admin management
- **Admin Level**: Pricing, member access control
- **Member Level**: Self-subscription management

### Error Handling
- `u100` - Owner-only function called by non-owner
- `u101` - Insufficient funds for payment
- `u102` - Subscription not found
- `u103` - Subscription expired
- `u104` - Unauthorized access
- `u105` - Invalid amount provided

## 💡 Integration Examples

### Frontend Integration

```javascript
// Check member status
const isMemberActive = await callReadOnlyFunction({
  contractAddress: 'SP123...ABC',
  contractName: 'gym-pass',
  functionName: 'is-member-active',
  functionArgs: [standardPrincipalCV(memberAddress)],
  network: new StacksTestnet()
});

// Subscribe to membership
const subscribeTransaction = await makeContractCall({
  contractAddress: 'SP123...ABC',
  contractName: 'gym-pass',
  functionName: 'subscribe',
  functionArgs: [],
  network: new StacksTestnet(),
  anchorMode: AnchorMode.Any,
  postConditionMode: PostConditionMode.Allow,
});
```

### Access Control System

```javascript
// Gym door access validation
async function validateGymAccess(memberAddress) {
  const isActive = await checkMembershipStatus(memberAddress);
  
  if (isActive) {
    // Grant access to gym facilities
    openDoor();
    logAccess(memberAddress, new Date());
  } else {
    // Deny access and prompt for subscription renewal
    displaySubscriptionPrompt();
  }
}
```

## 🏗️ Development

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd gym-pass-contract
   ```

2. **Install Clarinet**
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.clarinet.io | sh
   ```

3. **Run tests**
   ```bash
   clarinet test
   ```

4. **Local deployment**
   ```bash
   clarinet integrate
   ```

### Testing

The contract includes comprehensive tests for:
- Subscription lifecycle management
- Payment processing
- Access control validation
- Admin privilege management
- Error condition handling

## 📈 Business Model Integration

### Revenue Streams
- **Monthly Subscriptions**: Recurring STX payments from members
- **Multi-tier Memberships**: Different pricing for various access levels
- **Corporate Memberships**: Bulk subscriptions for companies

### Analytics Dashboard
- Track membership growth and churn
- Monitor revenue and payment patterns
- Analyze member engagement and access frequency

## 🔮 Future Enhancements

### Planned Features
- **Multi-tier Memberships**: Basic, Premium, VIP access levels
- **Family Plans**: Shared subscriptions for multiple members
- **Loyalty Rewards**: Token-based reward system for long-term members
- **Class Booking**: Integration with fitness class scheduling
- **NFT Memberships**: Limited edition membership tokens

### Integration Opportunities
- **Fitness Apps**: Connect with popular fitness tracking applications
- **IoT Devices**: Smart gym equipment integration
- **DeFi Protocols**: Yield generation on membership payments
- **Cross-gym Networks**: Reciprocal access agreements
