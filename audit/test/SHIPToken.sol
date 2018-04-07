pragma solidity ^0.4.18;


import "./StandardToken.sol";
import "./PausableToken.sol";
import "./MintableToken.sol";
import "./CanReclaimToken.sol";
import "./HasNoTokens.sol";

// ----------------------------------------------------------------------------
// Contracts that can have tokens approved, and then a function executed
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


/**
 * @title SHIPToken
 */
 //CanReclaimToken
contract SHIPToken is StandardToken, PausableToken, MintableToken, HasNoTokens {

  string public constant name = "ShipChain SHIP"; 
  string public constant symbol = "SHIP"; 
  uint8 public constant decimals = 18; 

  uint256 public constant INITIAL_SUPPLY = 0 * (10 ** uint256(decimals));

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  function SHIPToken() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    maxSupply = 500000000 * (10 ** uint256(decimals));//Max 500 M Tokens

    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }

  function approveAndCall(address spender, uint _value, bytes data) public returns (bool success) {
    approve(spender, _value);
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, _value, address(this), data);
    return true;
  }
}