# SafeMath

Source file [../../POC/contracts/token-contract-v5/SafeMath.sol](../../POC/contracts/token-contract-v5/SafeMath.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
 //https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
// BK Ok
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  // BK Ok
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // BK Ok
    if (a == 0) {
      return 0;
    }
    // BK Ok
    uint256 c = a * b;
    // BK Ok
    assert(c / a == b);
    // BK Ok
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  // BK Ok
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // BK Ok
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    // BK Ok
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  // BK Ok
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    // BK Ok
    assert(b <= a);
    // BK Ok
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  // BK Ok
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    // BK Ok
    uint256 c = a + b;
    // BK Ok
    assert(c >= a);
    // BK Ok
    return c;
  }
}
```
