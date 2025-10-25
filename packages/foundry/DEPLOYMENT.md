# MonadPay Deployment Guide

## Prerequisites

Before deploying MonadPay to Monad testnet, you need:

1. **Monad Testnet Tokens (MON)**
   - Visit the Monad faucet: https://testnet.monad.xyz
   - Get testnet MON for gas fees

2. **Private Key Setup**
   - Run `yarn generate` in the project root to create a new wallet
   - Or import an existing wallet with testnet MON

## Deployment Steps

### 1. Get Testnet Funds

```bash
# Visit Monad faucet
open https://testnet.monad.xyz

# Request testnet MON for your wallet address
# Check your balance on: https://testnet.monadexplorer.com
```

### 2. Deploy MonadPay Contract

```bash
# Navigate to foundry directory
cd packages/foundry

# Deploy to Monad Testnet
forge script script/DeployMonadPay.s.sol:DeployMonadPay \
  --rpc-url monadTestnet \
  --broadcast \
  --verify

# Or deploy without verification
forge script script/DeployMonadPay.s.sol:DeployMonadPay \
  --rpc-url monadTestnet \
  --broadcast
```

### 3. Verify Deployment

After deployment, you should see output like:

```
MonadPay deployed at: 0x...
```

Save this contract address! You'll need it to:
- Update `packages/nextjs/contracts/deployedContracts.ts`
- Update `packages/nextjs/monad-addresses.ts`

### 4. Update Contract Address

```bash
# From project root, regenerate TypeScript types
cd packages/foundry
node scripts-js/generateTsAbis.js
```

Then manually update `packages/nextjs/contracts/deployedContracts.ts` with your deployed address:

```typescript
import { GenericContractsDeclaration } from "~~/utils/scaffold-eth/contract";

const deployedContracts = {
  41143: {  // Monad Testnet chain ID
    MonadPay: {
      address: "YOUR_DEPLOYED_CONTRACT_ADDRESS",
      abi: [...] // ABI will be auto-generated
    },
  },
} as const;

export default deployedContracts satisfies GenericContractsDeclaration;
```

### 5. Test the Deployment

You can test the deployment using cast:

```bash
# Read contract (check if it exists)
cast code YOUR_CONTRACT_ADDRESS --rpc-url monadTestnet

# Test creating an invoice (from your wallet)
cast send YOUR_CONTRACT_ADDRESS \
  "createInvoice(uint256,address,string,(address,uint256)[])" \
  1000000 \
  "0xf817257ed378db8d94729d51756917d3168cb558" \
  "Test Invoice" \
  "[(0xYOUR_ADDRESS,10000)]" \
  --rpc-url monadTestnet \
  --private-key $DEPLOYER_PRIVATE_KEY
```

## Important Addresses

- **Monad Testnet RPC**: https://testnet-rpc.monad.xyz
- **Monad Explorer**: https://testnet.monadexplorer.com
- **USDC on Monad**: 0xf817257ed378db8d94729d51756917d3168cb558
- **Chain ID**: 41143

## Troubleshooting

### "Insufficient funds for gas"
- Make sure you have MON tokens from the faucet
- Check your balance: `cast balance YOUR_ADDRESS --rpc-url monadTestnet`

### "Invalid private key"
- Run `yarn generate` to create a new wallet
- Or set DEPLOYER_PRIVATE_KEY in packages/foundry/.env

### "Contract already deployed"
- This is fine! Just use the existing contract address
- Or modify the contract slightly to get a new address

## Next Steps

After successful deployment:

1. ✅ Contract is deployed on Monad testnet
2. ✅ Address is saved in deployedContracts.ts
3. ✅ Frontend can now interact with the contract
4. 🚀 Ready to build the UI!

