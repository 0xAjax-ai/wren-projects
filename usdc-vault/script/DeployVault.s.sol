// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {BasicUSDCVault} from "../src/BasicUSDCVault.sol";

contract DeployVault is Script {
    function run() external returns (BasicUSDCVault) {
        vm.startBroadcast();
        
        BasicUSDCVault vault = new BasicUSDCVault();
        
        console.log("BasicUSDCVault deployed to:", address(vault));
        
        vm.stopBroadcast();
        
        return vault;
    }
}
