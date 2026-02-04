// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {SimpleUSDCVault} from "../src/SimpleUSDCVault.sol";

contract DeploySimpleVault is Script {
    function run() external returns (SimpleUSDCVault) {
        vm.startBroadcast();
        
        SimpleUSDCVault vault = new SimpleUSDCVault();
        
        console.log("SimpleUSDCVault deployed to:", address(vault));
        
        vm.stopBroadcast();
        
        return vault;
    }
}
