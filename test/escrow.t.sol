  // SPDX-License-Identifier: UNLICENSED
  pragma solidity ^0.8.28;  

  import "forge-std/Test.sol";
  import "../contracts/escrow.sol";
  import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

    contract MockERC20 is ERC20 {
      constructor() ERC20("Mock USDC", "USDC") {}                               
                                                                                
      function mint(address to, uint256 amount) public {
          _mint(to, amount);                                                    
      }           
  }

  contract EscrowTest is Test   {
    Escrow escrow;
    address provider = makeAddr("provider");
    address client = makeAddr("client");
    address arbitrator = makeAddr("arbitrator");

    uint256 constant AMOUNT = 1000e6; // 1000 USDC
    uint256 releaseDate;
    MockERC20 token;

    function setUp() public {
        token = new MockERC20();
        releaseDate = block.timestamp + 7 days;

        escrow = new Escrow(
            provider, client, AMOUNT, releaseDate, address(token), arbitrator 
        );

        // Fund the provider so that he can deposit
        token.mint(provider, AMOUNT);
        vm.prank(provider);
        token.approve(address(escrow), AMOUNT);

    }

    function test_deposit_success() public  {
        vm.prank(provider);
        escrow.deposit();

        assertEq(uint(escrow.status()), uint(Escrow.Status.FUNDED));
        assertEq(token.balanceOf(address(escrow)), AMOUNT);
    }
  }

  