// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Escrow is ReentrancyGuard {

    // Variables
    address public provider;
    address public client;
    address public token;   // the token used to make the payment (USDC, EURe, etc)
    uint256 private amount;
    uint256 public releaseDate;
    bool public isFunded;
    bool public isReleased;


    constructor(
        address _provider, 
    address _client, 
    uint256 _amount, 
    uint256 _releaseDate,
    address _token)    {

        require(_provider!=address(0));
        require(_client!=address(0));

        provider = _provider;
        client = _client;
        amount = _amount;
        releaseDate = _releaseDate;
        isFunded = false;
        isReleased = false;
        token = _token;

    }

    // Fund the contract
    function deposit() public payable {
        require(msg.sender == provider,"The funds have to come from the provider");
        require(!isFunded, "Contract already funded");

        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer failed");

        isFunded = true;


    }

    // Release the funds
    function release() external nonReentrant {
        require(msg.sender == provider, "Only the provider can release the funds");
        require(isFunded, "Contract no funded");
        require(!isReleased, "Funds already released");
        require(block.timestamp >= releaseDate, "Funds can only be released after the release date.");

        bool success = IERC20(token).transfer(client, amount);
        require(success, "Failed to pay the client");

        isReleased = true;


    }

    // Send for arbitration

    // Convert currencies
}
