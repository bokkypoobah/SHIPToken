# MintableToken

Source file [../../POC/contracts/token-contract-v5/MintableToken.sol](../../POC/contracts/token-contract-v5/MintableToken.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;

// BK Next 3 Ok
import "./StandardToken.sol";
import "./Ownable.sol";
import "./Claimable.sol";


/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation and update of max supply
 */
 
// BK Ok
contract MintableToken is StandardToken, Ownable, Claimable {
  // BK Next 2 Ok - Events
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  // BK Ok
  bool public mintingFinished = false;
  // BK NOTE - There is a duplicate assignment in SHIPToken.sol
  // BK Ok
  uint public maxSupply = 500000000 * (10 ** 18);//Max 500 M Tokens


  // BK Ok - Modifier
  modifier canMint() {
    // BK Ok
    require(!mintingFinished);
    // BK Ok
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  // BK Ok - Only owner can mint
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    // BK Ok - But have to mint below the maxSupply
    if (maxSupply < totalSupply_.add(_amount) ) {
        // BK Ok
        revert();//Hard cap of 500M mintable tokens
    }

    // BK Ok
    totalSupply_ = totalSupply_.add(_amount);
    // BK Ok
    balances[_to] = balances[_to].add(_amount);
    // BK Ok - Log event
    Mint(_to, _amount);
    // BK Ok - And log transfer
    Transfer(address(0), _to, _amount);
    // BK Ok
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  // BK Ok - Only owner can execute
  function finishMinting() onlyOwner canMint public returns (bool) {
    // BK Ok
    mintingFinished = true;
    // BK Ok - Log event
    MintFinished();
    // BK Ok
    return true;
  }

}
```
