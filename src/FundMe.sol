// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";
import {Test, console} from "forge-std/Test.sol";
error FundMe__NotOwner();
error FundMe__EthBelowMin();

/**
 * @title A sample Funding Contract
 * @author Patrick Collins
 * @notice This contract is for creating a sample funding contract
 * @dev This implements price feeds as our library
 *
 * THIS IS TAKEN FROM CYFRIN FOUNDRY COURSE @ cyfrin.io
 *
 */
contract FundMe {
    using PriceConverter for uint256;

    AggregatorV3Interface private priceFeed;

    address public immutable i_owner;
    uint256 public constant MINIMUM_USD = 5e18;

    // made private for gas optimization
    mapping(address => uint256) private addressToAmountFunded;
    address[] private funders;

    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        i_owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    function fund() public payable {
        console.log(msg.value.getConversionRate(priceFeed));
        console.log(msg.value.getConversionRate(priceFeed) / 1e8);
        if (msg.value.getConversionRate(priceFeed) <= MINIMUM_USD) {
            revert FundMe__EthBelowMin();
        }
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
            unchecked {
                funderIndex++;
            }
        }
        funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!callSuccess) revert();
    }

    function cheaperWithdraw() public onlyOwner {
        address[] memory _funders = funders;
        uint256 funderLenght = funders.length;

        funders = new address[](0);
        for (uint256 funderIndex = 0; funderIndex < funderLenght; ) {
            addressToAmountFunded[_funders[funderIndex]] = 0;
            unchecked {
                funderIndex++;
            }
        }
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    /*
     * View / Pure functions (getters)
     */

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint) {
        return addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint index) external view returns (address) {
        return funders[index];
    }

    function getAllFunders() public view returns (address[] memory) {
        return funders;
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return priceFeed;
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }
}
