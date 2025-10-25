# MonadPay Frontend Setup Guide

## Environment Variables

To run the MonadPay frontend, you need to configure the following environment variables:

### 1. Create `.env.local` file

In the `packages/nextjs` directory, create a file named `.env.local`:

```bash
cd packages/nextjs
cp .env.example .env.local
```

### 2. Configure Groq API Key

MonadPay uses [Groq Cloud](https://console.groq.com/) for AI-powered invoice generation.

**Get your Groq API key:**

1. Visit [https://console.groq.com/](https://console.groq.com/)
2. Sign up or log in
3. Navigate to [API Keys](https://console.groq.com/keys)
4. Click "Create API Key"
5. Copy your API key

**Add to `.env.local`:**

```bash
GROQ_API_KEY=gsk_your_api_key_here
```

### 3. Other Environment Variables (Optional)

If you want to use custom RPC providers:

```bash
NEXT_PUBLIC_ALCHEMY_API_KEY=your_alchemy_key
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_walletconnect_id
```

## Why Groq?

Groq Cloud provides:
- ✅ **Extremely fast inference** (built on LPU hardware)
- ✅ **OpenAI-compatible API** (easy to integrate)
- ✅ **Cost-effective** pricing
- ✅ **Free tier** available for development
- ✅ **High-quality models** (Llama 3.3 70B and more)

Perfect for real-time AI invoice generation!

## Testing the AI Invoice Generator

Once configured, you can test the AI invoice generation:

```bash
curl -X POST http://localhost:3000/api/generate-invoice \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Create invoice for web design work with Sarah, split 70/30, total $500"}'
```

Expected response:
```json
{
  "recipients": [
    { "name": "Me", "percentage": 70 },
    { "name": "Sarah", "percentage": 30 }
  ],
  "amount": 500,
  "currency": "USDC",
  "description": "Web design work"
}
```

## Running the Frontend

```bash
# From project root
yarn start

# Or from packages/nextjs
yarn dev
```

The app will be available at [http://localhost:3000](http://localhost:3000)

## Troubleshooting

### "AI service not configured"

Make sure your `GROQ_API_KEY` is set in `.env.local`:

```bash
# Check if the file exists
cat packages/nextjs/.env.local | grep GROQ

# Should output: GROQ_API_KEY=gsk_...
```

### "Failed to generate invoice"

- Check that your Groq API key is valid
- Ensure you haven't exceeded rate limits
- Try a simpler prompt

### Need Help?

- [Groq Documentation](https://console.groq.com/docs/overview)
- [Groq API Reference](https://console.groq.com/docs/api-reference)
- [Create an issue](https://github.com/yourusername/monowire/issues)

