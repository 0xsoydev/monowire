// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/MonadPay.sol";

contract DeployMonadPay is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MonadPay monadPay = new MonadPay();
        console.log("MonadPay deployed at:", address(monadPay));

        vm.stopBroadcast();
    }
}

