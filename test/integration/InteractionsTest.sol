// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InterationsTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;

    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 1000e18;
    uint256 fund_amount_modifier = 2e18;
    uint256 constant GAS_PRICE = 10;

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        vm.prank(USER);
        vm.deal(USER, STARTING_BALANCE);
        fundFundMe.fundFundMe(address(fundMe));

        console.log("address(USER)              ", address(USER));
        console.log("address(fundFundMe)        ", address(fundFundMe));
        console.log("address(msg.sender)        ", address(msg.sender));

        address funder = fundMe.getFunder(0);

        console.log("address(funder)            ", address(funder));

        assertEq(funder, address(fundFundMe));
    }

    function testUserCanWithdrawInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
