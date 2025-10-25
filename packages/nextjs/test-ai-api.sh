#!/bin/bash

# Test script for AI Invoice Generation API
# Make sure the Next.js dev server is running (yarn dev)

echo "🧪 Testing AI Invoice Generation API"
echo "======================================"
echo ""

# Test 1: Simple invoice
echo "Test 1: Simple invoice for one recipient"
curl -X POST http://localhost:3000/api/generate-invoice \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Invoice for web design work, $1000"}' \
  -s | jq '.'
echo ""
echo "---"
echo ""

# Test 2: Invoice with splits
echo "Test 2: Invoice with payment splits"
curl -X POST http://localhost:3000/api/generate-invoice \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Create invoice for mobile app development with John, split 60/40, total $5000"}' \
  -s | jq '.'
echo ""
echo "---"
echo ""

# Test 3: Invoice with multiple recipients
echo "Test 3: Invoice with three recipients"
curl -X POST http://localhost:3000/api/generate-invoice \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Project invoice: $10000 total, split between Alice (50%), Bob (30%), and Charlie (20%)"}' \
  -s | jq '.'
echo ""
echo "---"
echo ""

# Test 4: Invoice with Ethereum addresses
echo "Test 4: Invoice with Ethereum addresses"
curl -X POST http://localhost:3000/api/generate-invoice \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Send 500 USDC to 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb2"}' \
  -s | jq '.'
echo ""
echo "---"
echo ""

# Test 5: Complex scenario
echo "Test 5: Complex freelance project with description"
curl -X POST http://localhost:3000/api/generate-invoice \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Freelance graphic design and frontend development project. Total budget $3500. Designer Sarah gets 40%, developer Mike gets 60%"}' \
  -s | jq '.'
echo ""
echo "---"
echo ""

echo "✅ Testing complete!"
echo ""
echo "Note: If you see errors, make sure:"
echo "1. Next.js dev server is running (yarn dev)"
echo "2. GROQ_API_KEY is set in packages/nextjs/.env.local"
echo "3. jq is installed for JSON formatting (optional)"

