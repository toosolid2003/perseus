// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Escrow is ReentrancyGuard, Ownable {

    enum Status { AWAITING_PAYMENT, FUNDED, RELEASED, DISPUTED, RESOLVED }

    // Variables
    address public provider;
    address public client;
    address public token;   // the token used to make the payment (USDC, EURe, etc)
    uint256 private amount;
    uint256 public releaseDate;
    Status public status;
    address public arbitrator;

    // events definition
    event Deposited(address indexed provider, uint256 amount );
    event Released(address indexed client, uint256 amount);
    event DisputeRaised(address indexed by);
    event Resolved(address indexed winner, uint256 amount);


    constructor(
        address _provider, 
    address _client, 
    uint256 _amount, 
    uint256 _releaseDate,
    address _token,
    address _arbitrator)  Ownable(msg.sender)  {

        require(_provider!=address(0), "Need a provider address");
        require(_client!=address(0), "Need a client address");
        require(_amount > 0, "Amount needs to be positive");
        require(_releaseDate > block.timestamp, "Release date must be in the future");
        require(_token != address(0), "Invalid token");
        require(_arbitrator != address(0), "Invalid arbitrator");

        provider = _provider;
        client = _client;
        amount = _amount;
        releaseDate = _releaseDate;
        token = _token;
        status = Status.AWAITING_PAYMENT;
        arbitrator = _arbitrator;

    }

    // Fund the contract
    function deposit() external nonReentrant {
        require(msg.sender == provider,"The funds have to come from the provider");
        require(status == Status.AWAITING_PAYMENT, "Contract already funded");

        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer failed");

        status = Status.FUNDED;

        emit Deposited(provider, amount);
    }

    // Release the funds
    function release() external nonReentrant {
        require(msg.sender == provider, "Only the provider can release the funds");
        require(status == Status.FUNDED, "Contract not funded");
        require(block.timestamp >= releaseDate, "Funds can only be released after the release date.");

        bool success = IERC20(token).transfer(client, amount);
        require(success, "Failed to pay the client");

        status = Status.RELEASED;

        emit Released(client, amount);
    }

    // escape hatch
    function refund() external {
        require(msg.sender == provider, "Only provider can refund");
        require(status == Status.FUNDED, "No funds on the contract");
        require(block.timestamp < releaseDate, "Refund only allowed before release date");

        bool success = IERC20(token).transfer(provider, amount);
        require(success, "Refund not successful");

        status = Status.AWAITING_PAYMENT;
    }

    // Send for arbitration
    function raiseDispute() external {
        require(msg.sender == provider || msg.sender == client, "Only client or provider can raise a dispute");
        require(status == Status.FUNDED, "Status should be funded");

        status = Status.DISPUTED;

        emit DisputeRaised(msg.sender);
    }

    function resolve(bool releaseToClient) external nonReentrant    {
        require(msg.sender == arbitrator, "Only arbitrator can resolve a dispute");
        require(status == Status.DISPUTED, "No active dispute");

        if (releaseToClient)    {
            bool success = IERC20(token).transfer(client, amount);
            require(success, "Refund to client unsuccessful");
            emit Resolved(client, amount);
        }   else {
            bool success = IERC20(token).transfer(provider, amount);
            require(success, "Refund to provider unsuccessful");
            emit Resolved(provider, amount);
        }

        status = Status.RESOLVED;
    }

    // Get the amount
    function getAmount() public view returns(uint256) {
        return amount;
    }
    // Convert currencies
}
