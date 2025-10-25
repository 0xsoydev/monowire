// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/MonadPay.sol";

contract DeployMonadPay is Script {
    function run() external {
        // Read private key as string to handle both with and without 0x prefix
        string memory pkString = vm.envString("DEPLOYER_PRIVATE_KEY");
        
        // Convert to uint256 - vm.parseBytes32 handles both formats
        uint256 deployerPrivateKey;
        
        // Check if the key starts with 0x
        bytes memory pkBytes = bytes(pkString);
        if (pkBytes.length >= 2 && pkBytes[0] == "0" && pkBytes[1] == "x") {
            // Has 0x prefix, parse as is
            deployerPrivateKey = vm.parseUint(pkString);
        } else {
            // No prefix, add it
            deployerPrivateKey = vm.parseUint(string.concat("0x", pkString));
        }
        
        vm.startBroadcast(deployerPrivateKey);

        MonadPay monadPay = new MonadPay();
        console.log("MonadPay deployed at:", address(monadPay));

        vm.stopBroadcast();
    }
}

