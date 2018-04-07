# ERC20

Source file [../../POC/contracts/token-contract-v5/ERC20.sol](../../POC/contracts/token-contract-v5/ERC20.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;

// BK Ok
import "./ERC20Basic.sol";



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
 //https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20/ERC20.sol
// BK Ok
contract ERC20 is ERC20Basic {
  // BK Ok
  function allowance(address owner, address spender) public view returns (uint256);
  // BK Ok
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  // BK Ok
  function approve(address spender, uint256 value) public returns (bool);
  // BK Ok - Event
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
```
