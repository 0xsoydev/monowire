#!/bin/bash

# Script to update the MonadPay contract address in deployedContracts.ts

if [ -z "$1" ]; then
    echo "❌ Error: Please provide the deployed contract address"
    echo "Usage: ./update-contract-address.sh 0xYourContractAddress"
    exit 1
fi

CONTRACT_ADDRESS=$1

echo "📝 Updating MonadPay contract address..."
echo "Address: $CONTRACT_ADDRESS"

# Update the address in deployedContracts.ts
sed -i "s/address: \"0x0000000000000000000000000000000000000000\"/address: \"$CONTRACT_ADDRESS\"/" \
  packages/nextjs/contracts/deployedContracts.ts

if [ $? -eq 0 ]; then
    echo "✅ Contract address updated successfully!"
    echo ""
    echo "File updated: packages/nextjs/contracts/deployedContracts.ts"
    echo ""
    echo "🔄 Restart your Next.js dev server for changes to take effect:"
    echo "  yarn start"
else
    echo "❌ Failed to update contract address"
    exit 1
fi

