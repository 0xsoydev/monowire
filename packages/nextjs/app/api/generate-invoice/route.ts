import { NextRequest, NextResponse } from "next/server";
import OpenAI from "openai";

// Using Groq Cloud (OpenAI-compatible API)
const groq = new OpenAI({
  apiKey: process.env.GROQ_API_KEY,
  baseURL: "https://api.groq.com/openai/v1",
});

interface InvoiceParsed {
  recipients: Array<{
    address?: string;
    name?: string;
    percentage: number;
  }>;
  amount: number;
  currency: string;
  description: string;
}

export async function POST(req: NextRequest) {
  try {
    const { prompt } = await req.json();

    if (!prompt) {
      return NextResponse.json({ error: "Prompt is required" }, { status: 400 });
    }

    const response = await groq.chat.completions.create({
      model: "llama-3.3-70b-versatile", // Fast and powerful Groq model
      messages: [
        {
          role: "system",
          content: `You are an AI that extracts invoice details from natural language.
          
Rules:
- Extract recipient addresses (or names if addresses not provided)
- Extract amount and currency
- Extract description
- If splits mentioned (e.g., "split 60/40"), calculate percentages
- If no split mentioned, assume 100% to single recipient
- Currency should be USDC unless specified
- For addresses, only include if they look like Ethereum addresses (0x...)
- If only names are provided, leave address field empty

Return JSON in this exact format:
{
  "recipients": [
    { "address": "0x..." (optional), "name": "Alice" (optional), "percentage": 60 },
    { "address": "0x..." (optional), "name": "Bob" (optional), "percentage": 40 }
  ],
  "amount": 1000,
  "currency": "USDC",
  "description": "Website design project"
}

Percentages must add up to 100.
Always return valid JSON without any markdown formatting or code blocks.`,
        },
        {
          role: "user",
          content: prompt,
        },
      ],
      temperature: 0.3,
      response_format: { type: "json_object" }, // Enforce JSON output
    });

    const content = response.choices[0].message.content;
    if (!content) {
      return NextResponse.json({ error: "No response from AI" }, { status: 500 });
    }

    const parsed: InvoiceParsed = JSON.parse(content);

    // Validate
    if (!parsed.recipients || parsed.recipients.length === 0) {
      return NextResponse.json({ error: "No recipients found in the invoice" }, { status: 400 });
    }

    const totalPercentage = parsed.recipients.reduce((sum, r) => sum + r.percentage, 0);
    if (Math.abs(totalPercentage - 100) > 0.01) {
      // Allow small floating point errors
      return NextResponse.json({ error: "Percentages must add up to 100" }, { status: 400 });
    }

    if (!parsed.amount || parsed.amount <= 0) {
      return NextResponse.json({ error: "Invalid amount" }, { status: 400 });
    }

    return NextResponse.json(parsed);
  } catch (error: any) {
    console.error("AI generation error:", error);

    // Handle specific error types
    if (error.message?.includes("API key")) {
      return NextResponse.json(
        { error: "AI service not configured. Please set GROQ_API_KEY in environment variables." },
        { status: 500 },
      );
    }

    if (error.message?.includes("JSON")) {
      return NextResponse.json(
        { error: "Failed to parse AI response. Please try rephrasing your request." },
        { status: 500 },
      );
    }

    return NextResponse.json({ error: error.message || "Failed to generate invoice" }, { status: 500 });
  }
}
