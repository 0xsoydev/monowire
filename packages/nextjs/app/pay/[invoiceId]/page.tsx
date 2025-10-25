"use client";

import { useEffect, useState } from "react";
import { formatUnits } from "viem";
import { useAccount } from "wagmi";
import { Address } from "~~/components/scaffold-eth";
import { useDeployedContractInfo, useScaffoldReadContract, useScaffoldWriteContract } from "~~/hooks/scaffold-eth";
import { notification } from "~~/utils/scaffold-eth";

interface Split {
  recipient: string;
  basisPoints: bigint;
}

export default function PayInvoice({ params }: { params: Promise<{ invoiceId: string }> }) {
  const { address: userAddress } = useAccount();
  const [isPaying, setIsPaying] = useState(false);
  const [isApproving, setIsApproving] = useState(false);
  const [invoiceId, setInvoiceId] = useState<`0x${string}` | undefined>(undefined);

  // Unwrap params in useEffect (Next.js 15 requirement)
  useEffect(() => {
    params.then(p => setInvoiceId(p.invoiceId as `0x${string}`));
  }, [params]);

  // Get MonadPay contract info
  const { data: monadPayContract } = useDeployedContractInfo("MonadPay");

  // Read invoice details
  const { data: invoiceData, isLoading: isLoadingInvoice } = useScaffoldReadContract({
    contractName: "MonadPay",
    functionName: "getInvoice",
    args: [invoiceId],
  });

  const { data: splitsData } = useScaffoldReadContract({
    contractName: "MonadPay",
    functionName: "getInvoiceSplits",
    args: [invoiceId],
  });

  const { writeContractAsync: payInvoice } = useScaffoldWriteContract("MonadPay");

  // USDC approval
  const { writeContractAsync: approveUSDC } = useScaffoldWriteContract("USDC");

  async function handleApprove() {
    if (!invoiceData || !monadPayContract) return;

    setIsApproving(true);
    try {
      const amountToApprove = invoiceData[2]; // amount from getInvoice

      await approveUSDC({
        functionName: "approve",
        args: [monadPayContract.address, amountToApprove],
      });

      notification.success(`Approved ${formatUnits(amountToApprove, 6)} USDC! ✅`);
    } catch (error: any) {
      console.error("Approval error:", error);
      notification.error(error.message || "Failed to approve USDC");
    } finally {
      setIsApproving(false);
    }
  }

  async function handlePay() {
    if (!invoiceData) return;

    setIsPaying(true);
    try {
      await payInvoice({
        functionName: "payInvoice",
        args: [invoiceId],
      });

      notification.success("Payment successful! 🎉");
      // Refresh page to show updated status
      setTimeout(() => window.location.reload(), 2000);
    } catch (error: any) {
      console.error("Payment error:", error);
      notification.error(error.message || "Failed to pay invoice");
    } finally {
      setIsPaying(false);
    }
  }

  if (!invoiceId || isLoadingInvoice) {
    return (
      <div className="container mx-auto p-8 text-center">
        <div className="loading loading-spinner loading-lg"></div>
        <p className="mt-4">Loading invoice...</p>
      </div>
    );
  }

  if (!invoiceData || !invoiceData[0]) {
    return (
      <div className="container mx-auto p-8 text-center">
        <div className="alert alert-error">
          <span>Invoice not found or does not exist</span>
        </div>
      </div>
    );
  }

  const [, creator, amount, , description, paid, createdAt, paidAt, paidBy] = invoiceData;

  const amountFormatted = formatUnits(amount, 6);

  return (
    <div className="container mx-auto p-8 max-w-2xl">
      <div className="card bg-base-100 shadow-xl">
        <div className="card-body">
          {paid ? (
            <div className="alert alert-success mb-4">
              <span>✅ This invoice has been paid!</span>
            </div>
          ) : null}

          <h2 className="card-title text-3xl mb-4">{paid ? "Paid Invoice" : "Pay Invoice"}</h2>

          <div className="space-y-4">
            <div className="bg-primary/10 p-6 rounded-lg">
              <p className="text-sm opacity-70">Amount</p>
              <p className="text-4xl font-bold text-primary">{amountFormatted} USDC</p>
            </div>

            <div className="bg-base-200 p-4 rounded-lg">
              <p className="text-sm opacity-70">Description</p>
              <p className="text-lg">{description}</p>
            </div>

            <div className="bg-base-200 p-4 rounded-lg">
              <p className="text-sm opacity-70 mb-2">Created by</p>
              <Address address={creator} />
              <p className="text-xs opacity-60 mt-2">
                Created on: {new Date(Number(createdAt) * 1000).toLocaleString()}
              </p>
            </div>

            {splitsData && splitsData.length > 0 && (
              <div className="bg-base-200 p-4 rounded-lg">
                <p className="text-sm opacity-70 mb-3 font-bold">Payment will be split to:</p>
                <div className="space-y-2">
                  {splitsData.map((split: Split, index: number) => {
                    const percentage = Number(split.basisPoints) / 100;
                    const splitAmount = (amount * split.basisPoints) / 10000n;
                    return (
                      <div key={index} className="flex justify-between items-center p-2 bg-base-100 rounded">
                        <Address address={split.recipient} />
                        <div className="text-right">
                          <span className="font-bold block">{formatUnits(splitAmount, 6)} USDC</span>
                          <span className="text-xs opacity-70">{percentage}%</span>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            )}

            {paid ? (
              <div className="bg-base-200 p-4 rounded-lg">
                <p className="text-sm opacity-70 mb-2">Paid by</p>
                <Address address={paidBy} />
                <p className="text-sm opacity-70 mt-2">Paid on: {new Date(Number(paidAt) * 1000).toLocaleString()}</p>
              </div>
            ) : null}
          </div>

          {!paid && userAddress ? (
            <div className="mt-6">
              <div className="alert alert-info mb-4">
                <div className="text-sm">
                  <p className="font-bold mb-1">⚠️ Before paying:</p>
                  <p>
                    1. Make sure you have {amountFormatted} USDC in your wallet
                    <br />
                    2. Approve the MonadPay contract to spend your USDC
                    <br />
                    3. Click Pay Now to complete the payment
                  </p>
                </div>
              </div>

              <div className="flex gap-3">
                <button onClick={handleApprove} disabled={isApproving} className="btn btn-secondary flex-1">
                  {isApproving ? (
                    <>
                      <span className="loading loading-spinner loading-sm"></span>
                      Processing...
                    </>
                  ) : (
                    "1️⃣ Approve USDC"
                  )}
                </button>
                <button onClick={handlePay} disabled={isPaying} className="btn btn-primary flex-1">
                  {isPaying ? (
                    <>
                      <span className="loading loading-spinner loading-sm"></span>
                      Paying...
                    </>
                  ) : (
                    "2️⃣ Pay Now"
                  )}
                </button>
              </div>

              <div className="text-xs opacity-60 mt-4 text-center">
                💡 Tip: Click Approve first, then Pay. The approval allows MonadPay to transfer your USDC.
              </div>
            </div>
          ) : !paid && !userAddress ? (
            <div className="alert alert-warning mt-6">
              <span>Please connect your wallet to pay this invoice</span>
            </div>
          ) : null}
        </div>
      </div>

      {!paid && (
        <div className="mt-6 text-center">
          <p className="text-sm opacity-60">
            Invoice ID: <code className="text-xs">{invoiceId}</code>
          </p>
        </div>
      )}
    </div>
  );
}
