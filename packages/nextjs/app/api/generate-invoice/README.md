# AI Invoice Generation API

Natural language invoice generation powered by [Groq Cloud](https://console.groq.com/) and Llama 3.3 70B.

## Overview

This API endpoint accepts natural language descriptions and converts them into structured invoice data with automatic payment splits.

## Endpoint

```
POST /api/generate-invoice
```

## Request

### Headers
```
Content-Type: application/json
```

### Body
```typescript
{
  "prompt": string  // Natural language description of the invoice
}
```

## Response

### Success (200)
```typescript
{
  "recipients": Array<{
    address?: string;  // Ethereum address (if provided)
    name?: string;     // Recipient name (if provided)
    percentage: number; // Percentage of payment (0-100)
  }>;
  "amount": number;       // Invoice amount
  "currency": string;     // Currency (default: "USDC")
  "description": string;  // Invoice description
}
```

### Error (400/500)
```typescript
{
  "error": string  // Error message
}
```

## Examples

### Example 1: Simple Invoice

**Request:**
```bash
curl -X POST http://localhost:3000/api/generate-invoice \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Invoice for web design work, $1000"}'
```

**Response:**
```json
{
  "recipients": [
    { "percentage": 100 }
  ],
  "amount": 1000,
  "currency": "USDC",
  "description": "Web design work"
}
```

### Example 2: Invoice with Payment Splits

**Request:**
```bash
curl -X POST http://localhost:3000/api/generate-invoice \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Website redesign with Sarah, split 70/30, total $500"}'
```

**Response:**
```json
{
  "recipients": [
    { "name": "Me", "percentage": 70 },
    { "name": "Sarah", "percentage": 30 }
  ],
  "amount": 500,
  "currency": "USDC",
  "description": "Website redesign"
}
```

### Example 3: Multiple Recipients

**Request:**
```bash
curl -X POST http://localhost:3000/api/generate-invoice \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Project invoice: $10000 split between Alice (50%), Bob (30%), and Charlie (20%)"}'
```

**Response:**
```json
{
  "recipients": [
    { "name": "Alice", "percentage": 50 },
    { "name": "Bob", "percentage": 30 },
    { "name": "Charlie", "percentage": 20 }
  ],
  "amount": 10000,
  "currency": "USDC",
  "description": "Project invoice"
}
```

### Example 4: With Ethereum Address

**Request:**
```bash
curl -X POST http://localhost:3000/api/generate-invoice \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Send 500 USDC to 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb2 for consulting work"}'
```

**Response:**
```json
{
  "recipients": [
    {
      "address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb2",
      "percentage": 100
    }
  ],
  "amount": 500,
  "currency": "USDC",
  "description": "Consulting work"
}
```

## Natural Language Patterns

The AI understands various natural language patterns:

### Amount Formats
- `$1000`, `1000 USD`, `1000 USDC`
- `$1,000`, `$1000.00`
- `1k`, `10k`

### Split Patterns
- `split 60/40`
- `split between Alice (60%) and Bob (40%)`
- `50% to Alice, 30% to Bob, 20% to Charlie`
- `Alice gets 60%, Bob gets 40%`

### Descriptions
- `for web design`
- `consulting work`
- `freelance project: mobile app development`

### Recipients
- Names: `with Sarah`, `to Alice and Bob`
- Addresses: `to 0x...`
- Mixed: `Send to Alice (0x...)`

## Error Handling

### Common Errors

**Missing Prompt**
```json
{
  "error": "Prompt is required"
}
```

**Invalid Splits**
```json
{
  "error": "Percentages must add up to 100"
}
```

**Invalid Amount**
```json
{
  "error": "Invalid amount"
}
```

**API Not Configured**
```json
{
  "error": "AI service not configured. Please set GROQ_API_KEY in environment variables."
}
```

## Configuration

### Required Environment Variable

```bash
GROQ_API_KEY=gsk_your_api_key_here
```

Get your free API key from [Groq Console](https://console.groq.com/keys).

### Model Details

- **Model**: `llama-3.3-70b-versatile`
- **Provider**: Groq Cloud
- **Temperature**: 0.3 (for consistent output)
- **Response Format**: JSON (structured)

## Testing

Run the test script:

```bash
cd packages/nextjs
./test-ai-api.sh
```

Or test manually:

```bash
# Start the dev server
yarn dev

# In another terminal
curl -X POST http://localhost:3000/api/generate-invoice \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Your invoice description here"}'
```

## Integration Example

```typescript
// In your React component
async function generateInvoice(prompt: string) {
  const response = await fetch('/api/generate-invoice', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ prompt }),
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error);
  }
  
  return await response.json();
}

// Usage
const invoice = await generateInvoice('Web design with Sarah, split 70/30, $500');
// Use invoice.recipients, invoice.amount, etc.
```

## Performance

- **Average Response Time**: 500ms - 2s
- **Rate Limits**: Depends on Groq Cloud tier
- **Concurrency**: Supports multiple simultaneous requests

## Why Groq?

- ⚡ **Fast**: Extremely low latency inference on LPU hardware
- 🔄 **OpenAI Compatible**: Easy to integrate
- 💰 **Cost-Effective**: Competitive pricing with free tier
- 🎯 **High Quality**: Powered by Llama 3.3 70B model

## Future Enhancements

Potential improvements:
- Support for more currencies (ETH, MATIC, etc.)
- Multi-currency conversions
- Invoice templates
- Historical invoice context
- Batch processing

