# Ownable

Source file [../../POC/contracts/token-contract-v5/Ownable.sol](../../POC/contracts/token-contract-v5/Ownable.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
 //https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
 // BK Ok
contract Ownable {
  // BK Ok
  address public owner;


  // BK Ok - Event
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  // BK Ok - Constructor
  function Ownable() public {
    // BK Ok
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  // BK Ok
  modifier onlyOwner() {
    // BK Ok
    require(msg.sender == owner);
    // BK Ok
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
   //replaced by Claimable
  // function transferOwnership(address newOwner) public onlyOwner {
  //   require(newOwner != address(0));
  //   OwnershipTransferred(owner, newOwner);
  //   owner = newOwner;
  // }

}
```
