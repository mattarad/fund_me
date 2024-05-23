// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

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

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        i_owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    function fund() public payable {
        if (msg.value.getConversionRate(priceFeed) >= MINIMUM_USD) {
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
        uint funderLenght = funders.length;

        funders = new address[](0);
        for (uint funderIndex = 0; funderIndex < funderLenght; ) {
            addressToAmountFunded[_funders[funderIndex]] = 0;
            unchecked {
                funderIndex++;
            }
        }
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getAllFunders() public view returns (address[] memory) {
        return funders;
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return priceFeed;
    }
}
