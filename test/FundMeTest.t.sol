// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testMinimumDollarIsFiveFail() public view {
        assertNotEq(fundMe.MINIMUM_USD(), 6 * 10 ** 18);
    }

    function testOwnerIsMsgSender() public view {
        console.log("fundMe:                    ", fundMe.i_owner());
        console.log("address(deployFundMe):     ", address(deployFundMe));
        console.log("msg.sender:                ", msg.sender);
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedAddress() public view {
        console.log("priceFeed:         ", address(fundMe.getPriceFeed()));
        console.log("address(0):        ", address(0));
        assertEq(
            address(fundMe.getPriceFeed()),
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
    }

    function testPriceFeedVersionIsAccurate() public view {
        console.log(fundMe.getVersion());
    }

    function testPriceFeedGetConversionRate() public view {
        // console.log()
    }
}
