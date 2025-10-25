/**
 * Important contract addresses on Monad Testnet
 *
 * These addresses are referenced throughout the MonadPay application
 */

export const MONAD_TESTNET_ADDRESSES = {
  // USDC contract on Monad Testnet (from Monad resources)
  USDC: "0xf817257ed378db8d94729d51756917d3168cb558",

  // Kuru DEX addresses (to be added during integration)
  KURU_ROUTER: "", // TODO: Get from Kuru docs
  KURU_SWAP: "", // TODO: Get from Kuru docs

  // Chainlink CCIP addresses (to be added during integration)
  CCIP_ROUTER: "", // TODO: Get from Chainlink docs for Monad

  // Other token addresses (to be added as needed)
  WETH: "", // TODO: Get from Monad docs
  WBTC: "", // TODO: Get from Monad docs
  WRAPPED_MONAD: "", // TODO: Get from Monad docs
} as const;

export const MONAD_TESTNET_INFO = {
  CHAIN_ID: 41143,
  RPC_URL: "https://testnet-rpc.monad.xyz",
  EXPLORER_URL: "https://testnet.monadexplorer.com",
  FAUCET_URL: "https://testnet.monad.xyz", // From plan resources
} as const;
