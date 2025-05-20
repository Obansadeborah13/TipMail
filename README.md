# TipMail Smart Contract

A decentralized messaging system built on Stacks that enables users to send messages with STX-based tips. Recipients can choose to accept or reject messages, while ensuring privacy through message hashing.

## Features

- 📨 Send private messages with STX tips
- 🔒 Message content stored as hashes for privacy
- ✅ Recipients can accept messages to claim tips
- ❌ Recipients can reject messages to return tips
- ⏰ Automatic message expiry after 100 blocks
- 💰 Senders can reclaim tips from expired messages

## Functions

### Public Functions

- `send-message`: Send a new message with a tip
  ```clarity
  (send-message recipient message-id message-hash tip)
  ```

- `accept-message`: Accept a message and receive the tip
  ```clarity
  (accept-message message-id)
  ```

- `reject-message`: Reject a message and return the tip
  ```clarity
  (reject-message message-id)
  ```

- `claim-expired`: Claim back tip from expired message
  ```clarity
  (claim-expired message-id)
  ```

### Read-Only Functions

- `get-message-info`: Get message details
  ```clarity
  (get-message-info message-id)
  ```

## Message States

- `0`: Pending
- `1`: Accepted
- `2`: Rejected
- `3`: Expired

## Error Codes

- `u1`: Invalid tip amount (must be > 0)
- `u2`: Unauthorized operation
- `u3`: Invalid message status
- `u4`: Message not found
- `u5`: Message not expired


### Deployment

```bash
clarinet deploy --testnet
```

