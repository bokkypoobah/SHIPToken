# SHIPToken

Source file [../../POC/contracts/token-contract-v5/SHIPToken.sol](../../POC/contracts/token-contract-v5/SHIPToken.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;


// BK Next 5 Ok
import "./StandardToken.sol";
import "./PausableToken.sol";
import "./MintableToken.sol";
import "./CanReclaimToken.sol";
import "./HasNoTokens.sol";

// ----------------------------------------------------------------------------
// Contracts that can have tokens approved, and then a function executed
// ----------------------------------------------------------------------------
// BK Ok
contract ApproveAndCallFallBack {
    // BK Ok
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


/**
 * @title SHIPToken
 */
 //CanReclaimToken
// BK Ok
contract SHIPToken is StandardToken, PausableToken, MintableToken, HasNoTokens {

  // BK Ok
  string public constant name = "ShipChain SHIP";
  // BK Ok 
  string public constant symbol = "SHIP";
  // BK Ok 
  uint8 public constant decimals = 18; 

  // BK Ok - O
  uint256 public constant INITIAL_SUPPLY = 0 * (10 ** uint256(decimals));

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  // BK Ok - Constructor
  function SHIPToken() public {
    // BK Ok
    totalSupply_ = INITIAL_SUPPLY;
    // BK Ok
    balances[msg.sender] = INITIAL_SUPPLY;
    // BK NOTE - There is a duplicate assignment in MintableToken.sol
    maxSupply = 500000000 * (10 ** uint256(decimals));//Max 500 M Tokens

    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }

  // BK Ok
  function approveAndCall(address spender, uint _value, bytes data) public returns (bool success) {
    // BK Ok
    approve(spender, _value);
    // BK Ok
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, _value, address(this), data);
    // BK Ok
    return true;
  }
}
```
