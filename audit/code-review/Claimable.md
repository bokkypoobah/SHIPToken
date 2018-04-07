# Claimable

Source file [../../POC/contracts/token-contract-v5/Claimable.sol](../../POC/contracts/token-contract-v5/Claimable.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;


// BK Ok
import "./Ownable.sol";


/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
 //https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/ownership/Claimable.sol
// BK Ok
contract Claimable is Ownable {
  // BK Ok
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  // BK Ok
  modifier onlyPendingOwner() {
    // BK Ok
    require(msg.sender == pendingOwner);
    // BK Ok
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  // BK Ok - Only owner can execute
  function transferOwnership(address newOwner) onlyOwner public {
    // BK Ok
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  // BK Ok - Only pending owner can execute
  function claimOwnership() onlyPendingOwner public {
    // BK Ok - Log event
    OwnershipTransferred(owner, pendingOwner);
    // BK Ok
    owner = pendingOwner;
    // BK Ok
    pendingOwner = address(0);
  }
}
```
