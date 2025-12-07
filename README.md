# Ethereum Smart Contract Showcase

This repository contains two Solidity contracts that explore secure, condition-based payment flows on Ethereum. The accompanying documentation explains how to deploy, test, and interact with the contracts using Remix IDE or Hardhat.

## Contracts

### `SepoliaMultiApprovalPayout`
A multi-signature style payout contract where three designated approvers must unanimously authorize a release of funds to a recipient.

**Key features**
- Stores three approver addresses and a payable recipient.
- Tracks approvals in a mapping and exposes an `isConsensusReached` helper.
- Emits events for approvals, deposits, and successful execution.
- Releases the entire contract balance to the recipient once all approvals are recorded and execution is triggered by any approver.

**Core functions**
- `approve()`: Marks the caller (must be an approver) as approved and emits `Approved`.
- `isConsensusReached()`: Returns `true` only when all three approvers have called `approve`.
- `executeAction()`: After consensus, transfers the contract balance to the recipient and emits `Executed`; callable only once.
- `receive()` / `fallback()`: Accept ETH deposits and emit `Deposited`.

### `SecureMilestonePayment`
A milestone-based escrow that models pre-delivery and post-delivery windows with payment adjustments for lateness.

**Key features**
- Maintains buyer and seller addresses, a base price (in finney), and time windows before and after delivery confirmation.
- Allows the seller to verify delivery within a deadline; flags late delivery automatically.
- Lets the buyer approve delivery and pays the seller, applying penalties if delivery or post-delivery confirmation is late.
- Provides countdown helpers to track remaining time in each phase.

**Core functions**
- `DeliveryVerified()`: Seller marks delivery as initiated; records timestamp and marks lateness if the pre-delivery window expired.
- `approveDelivery()`: Buyer approves delivery, calculates payment with applicable penalties, and transfers funds to the seller.
- `getPaymentAmount()`: Computes payout based on lateness (5% deduction after post-delivery deadline; 3% deduction if seller was late to start delivery).
- `payBackToBuyer()`: Buyer withdraws any remaining balance after payment completion.
- `getCountdownStatus()`: Returns whether pre/post-delivery windows are active and their remaining seconds.

## Prerequisites
- [Node.js](https://nodejs.org/) and [npm](https://www.npmjs.com/) for local tooling (optional if you only use Remix).
- A wallet with test ETH (e.g., from the Sepolia faucet) if deploying to testnets.
- Basic familiarity with Solidity and Remix IDE.

## Running in Remix IDE
1. Open [Remix](https://remix.ethereum.org/) and create two files under `contracts/`:
   - `Trustless_Coordination_in_Open_Networks.sol`
   - `Vulnerability_in_Smart_Contract_Logic.sol`
2. Paste the corresponding contract code from `src/contracts/` into each file.
3. Compile with Solidity ^0.8.0.
4. In the **Deploy & Run** tab, select an environment (e.g., JavaScript VM or an injected provider pointing to Sepolia).
5. Deploy contracts using constructor parameters:
   - `SepoliaMultiApprovalPayout(address A, address B, address C, address recipient)`
   - `SecureMilestonePayment(address buyer, address seller, uint priceInFinney, uint durationBeforeMinutes, uint durationAfterMinutes)`
6. Use the Remix UI to call functions, send ETH to the contract address, and observe emitted events.

## Hardhat Quickstart (optional)
While this repository is optimized for Remix, you can test locally with Hardhat:
1. Install dependencies:
   ```bash
   npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
   ```
2. Initialize Hardhat:
   ```bash
   npx hardhat init
   ```
3. Copy the contracts from `src/contracts/` into your Hardhat `contracts/` folder.
4. Add a sample test in `test/` to deploy and interact with the contracts (e.g., using `ethers` to call `approve()` and `executeAction()`).
5. Run the tests:
   ```bash
   npx hardhat test
   ```

## Deployment tips
- Always fund the contract address with enough ETH before triggering payout functions.
- For `SepoliaMultiApprovalPayout`, each approver must call `approve()` before `executeAction()` succeeds.
- For `SecureMilestonePayment`, ensure `approveDelivery()` is called only after `DeliveryVerified()`; payments depend on the timing of these calls relative to the configured windows.

## Repository structure
```
README.md                 # Project overview and usage
src/contracts/            # Solidity contracts for multi-approval payout and milestone escrow
src/.prettierrc.json      # Formatting settings for Solidity files
```

## License
MIT
