// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
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
        // assertEq(address(fundMe.getPriceFeed()), 0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function testPriceFeedVersionIsAccurate() public view {
        console.log(fundMe.getVersion());
    }

    function testFundFailWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructures() public {
        vm.prank(USER);
        uint256 funded_amount = 1e18;
        fundMe.fund{value: funded_amount}();
        assertEq(funded_amount, fundMe.getAddressToAmountFunded(USER));
        vm.stopPrank();
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        uint256 funded_amount = 2e18;
        fundMe.fund{value: funded_amount}();
        address[] memory funders = fundMe.getAllFunders();
        // console.log(funders[0]);
        // console.log(USER);

        // uint length = funders.length;
        // console.log(length);
        assertEq(funders[0], USER);
    }

    function testOnlyOwnerCanWithdraw() public {
        uint256 funded_amount = 2e18;
        vm.prank(USER);
        fundMe.fund{value: funded_amount}();

        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testOnlyOwnerCanCheaperWithdraw() public {
        uint256 funded_amount = 2e18;
        vm.prank(USER);
        fundMe.fund{value: funded_amount}();

        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: fund_amount_modifier}();
        _;
    }

    function testOnlyOwnerCanCheaperWithdrawWithModifier() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        // Arrange
        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint endingOwnerBalance = fundMe.getOwner().balance;
        uint endingFundMeBalance = address(fundMe).balance;
        assertEq(startingFundMeBalance, fund_amount_modifier);
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // address can only be created below using uint160
        uint160 totalNumberOfFunders = 100;
        for (uint160 i = 0; i < totalNumberOfFunders; i++) {
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: fund_amount_modifier}();
        }

        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;

        assertEq(
            startingFundMeBalance,
            (totalNumberOfFunders * fund_amount_modifier) + fund_amount_modifier
        ); // + fund_amount_modifier due to modifier being used.

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint endingOwnerBalance = fundMe.getOwner().balance;
        uint endingFundMeBalance = address(fundMe).balance;
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
        assertEq(endingFundMeBalance, 0);
    }

    function testCheaperWithdrawFromMultipleFunders() public funded {
        // address can only be created below using uint160
        uint160 totalNumberOfFunders = 100;
        for (uint160 i = 0; i < totalNumberOfFunders; i++) {
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: fund_amount_modifier}();
        }

        uint startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;

        assertEq(
            startingFundMeBalance,
            (totalNumberOfFunders * fund_amount_modifier) + fund_amount_modifier
        ); // + fund_amount_modifier due to modifier being used.

        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        uint endingOwnerBalance = fundMe.getOwner().balance;
        uint endingFundMeBalance = address(fundMe).balance;
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
        assertEq(endingFundMeBalance, 0);
    }

    function testPriceFeedGetConversionRate() public view {
        // console.log()
    }
}
