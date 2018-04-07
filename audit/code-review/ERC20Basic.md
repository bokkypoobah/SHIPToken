# ERC20Basic

Source file [../../POC/contracts/token-contract-v5/ERC20Basic.sol](../../POC/contracts/token-contract-v5/ERC20Basic.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
 //https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20/ERC20Basic.sol
// BK Ok
contract ERC20Basic {
  // BK Ok
  function totalSupply() public view returns (uint256);
  // BK Ok
  function balanceOf(address who) public view returns (uint256);
  // BK Ok
  function transfer(address to, uint256 value) public returns (bool);
  // BK Ok - Event
  event Transfer(address indexed from, address indexed to, uint256 value);
}
```
