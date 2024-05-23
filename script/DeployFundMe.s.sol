// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        vm.startBroadcast();
        FundMe fundMe = new FundMe(address(0));
        vm.stopBroadcast();
        return fundMe;
    }
}
