import { GenericContractsDeclaration } from "~~/utils/scaffold-eth/contract";

/**
 * External contracts configuration
 * Includes USDC on Monad Testnet for payment approvals
 */
const externalContracts = {
  10143: {
    // Monad Testnet (Chain ID: 10143 / 0x279f)
    USDC: {
      address: "0xf817257fed379853cDe0fa4F97AB987181B1E5Ea",
      abi: [
        {
          inputs: [
            { name: "spender", type: "address" },
            { name: "amount", type: "uint256" },
          ],
          name: "approve",
          outputs: [{ name: "", type: "bool" }],
          stateMutability: "nonpayable",
          type: "function",
        },
        {
          inputs: [{ name: "account", type: "address" }],
          name: "balanceOf",
          outputs: [{ name: "", type: "uint256" }],
          stateMutability: "view",
          type: "function",
        },
        {
          inputs: [
            { name: "owner", type: "address" },
            { name: "spender", type: "address" },
          ],
          name: "allowance",
          outputs: [{ name: "", type: "uint256" }],
          stateMutability: "view",
          type: "function",
        },
      ],
    },
  },
} as const;

export default externalContracts satisfies GenericContractsDeclaration;
