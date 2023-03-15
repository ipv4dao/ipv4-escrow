
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract IPv4Escrow is ChainlinkClient {
address public buyer;
address public seller;
address public broker;
uint256 public dealAmount;
uint256 public brokerFee;
uint256 public dealActivationTimeout;
uint256 public transferTimeout;
uint256 public dealActivatedTime;
string public ipv4Subnet;
string public sellerOrgId;
string public buyerOrgId;
enum DealStatus { Created, Activated, Success, Failure }
DealStatus public dealStatus;

event DealActivated();
event DealSuccessful();
event DealFailed();
event Withdrawn(address indexed payee, uint256 amount);
event Refunded(address indexed payee, uint256 amount);

modifier onlyBuyer() {
    require(msg.sender == buyer, "Only the buyer can perform this action");
    _;
}

modifier onlySeller() {
    require(msg.sender == seller, "Only the seller can perform this action");
    _;
}

modifier onlyBroker() {
    require(msg.sender == broker, "Only the broker can perform this action");
    _;
}

constructor(
    address _buyer,
    address _seller,
    address _broker,
    uint256 _dealAmount,
    uint256 _brokerFee,
    uint256 _dealActivationTimeout,
    uint256 _transferTimeout,
    string memory _ipv4Subnet,
    string memory _sellerOrgId,
    string memory _buyerOrgId,
    address _linkTokenAddress
) {
    buyer = _buyer;
    seller = _seller;
    broker = _broker;
    dealAmount = _dealAmount;
    brokerFee = _brokerFee;
    dealActivationTimeout = _dealActivationTimeout;
    transferTimeout = _transferTimeout;
    ipv4Subnet = _ipv4Subnet;
    sellerOrgId = _sellerOrgId;
    buyerOrgId = _buyerOrgId;
    dealStatus = DealStatus.Created;
    setChainlinkToken(_linkTokenAddress);
}

function deposit() external payable onlyBuyer {
    require(dealStatus == DealStatus.Created, "Deal must be in Created status");
    require(msg.value == dealAmount, "Deposited amount must be equal to the deal amount");
}

function activateDeal() external onlySeller {
    require(dealStatus == DealStatus.Created, "Deal must be in Created status");
    require(block.timestamp < dealActivationTimeout, "Deal activation timeout has passed");
    dealStatus = DealStatus.Activated;
    dealActivatedTime = block.timestamp;
    emit DealActivated();
}

function checkStatus() internal returns (bool) {
    // Chainlink Decentralized Oracle Network implementation to check subnet transfer status
    // Returns true if subnet transfer is successful
}

function withdraw() external onlySeller {
    require(dealStatus == DealStatus.Activated, "Deal must be in Activated status");
    require(block.timestamp < dealActivatedTime + transferTimeout, "Transfer timeout has passed");
    require(checkStatus(), "Subnet transfer is not successful");

    dealStatus = DealStatus.Success;
    uint256 amountToWithdraw = dealAmount - brokerFee;
    payable(seller).transfer(amountToWithdraw);
    payable(broker).transfer(brokerFee);

    emit Withdrawn(seller, amountToWithdraw);
    emit DealSuccessful();
}

function refund() external {
    require(dealStatus == DealStatus.Activated, "Deal must be in Activated status");
require(block.timestamp >= dealActivatedTime + transferTimeout, "Transfer timeout has not passed yet");
    dealStatus = DealStatus.Failure;
    uint256 amountToRefund = dealAmount - brokerFee;
    payable(buyer).transfer(amountToRefund);
    payable(broker).transfer(brokerFee);

    emit Refunded(buyer, amountToRefund);
    emit DealFailed();
}

function forceDealSuccess() external onlyBroker {
    require(dealStatus == DealStatus.Activated, "Deal must be in Activated status");

    dealStatus = DealStatus.Success;
    uint256 amountToWithdraw = dealAmount - brokerFee;
    payable(seller).transfer(amountToWithdraw);
    payable(broker).transfer(brokerFee);

    emit Withdrawn(seller, amountToWithdraw);
    emit DealSuccessful();
}

function forceDealFailure() external onlyBroker {
    require(dealStatus == DealStatus.Activated, "Deal must be in Activated status");

    dealStatus = DealStatus.Failure;
    uint256 amountToRefund = dealAmount - brokerFee;
    payable(buyer).transfer(amountToRefund);
    payable(broker).transfer(brokerFee);

    emit Refunded(buyer, amountToRefund);
    emit DealFailed();
}

function getContractBalance() external view returns(uint256) {
    return address(this).balance;
}

function getStatus() external view returns(string memory) {
    if (dealStatus == DealStatus.Created) {
        return "Created";
    } else if (dealStatus == DealStatus.Activated) {
        return "Activated";
    } else if (dealStatus == DealStatus.Success) {
        return "Success";
    } else if (dealStatus == DealStatus.Failure) {
        return "Failure";
    } else {
        return "Unknown";
    }
}
}
