# Shipchain Token Contract Audit

## Summary

[ShipChain](https://shipchain.io/) intends to deploy a `SHIP` token contract in February or March 2018.

Bok Consulting Pty Ltd was commissioned to perform an audit on ShipChain's Ethereum ERC20 token contract.

This original audit was completed on Feb 24 2018 based on source code in ShipChain's private repository in commits
[aa6a01f](https://github.com/ShipChain/contracts/commit/aa6a01fbff64d62ecb5acbb166f633a942905f20),
[be073ee](https://github.com/ShipChain/contracts/commit/be073eef83f861d61452372c97a0a568964c03dc) and
[4d135f2](https://github.com/ShipChain/contracts/commit/4d135f276c345c5750d5af290a2fd0d595ed16ef).

This audit has now been re-tested and re-checked in ShipChain's public repository in commit
[f8498b6](https://github.com/ShipChain/SHIPToken/commit/f8498b6747bfe4f82957257f90e8c3ff7b9314e2).

No potential vulnerabilities have been identified in the token contract.

Note that SHIPToken is a pausable token contract. The token contract owner can pause and un-pause transfers at any
time in the future. The intention for this functionality is to disable this token contract when and if an upgrade to the
token contract is required in the future.

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
* [Recommendations](#recommendations)
* [Potential Vulnerabilities](#potential-vulnerabilities)
* [Scope](#scope)
* [Limitations](#limitations)
* [Risks](#risks)
* [Testing](#testing)
* [Code Review](#code-review)
* [References](#references)

<br />

<hr />

## Recommendations

* **MEDIUM IMPORTANCE** In `SHIPToken.transferAndCall(...)`,
  `if(!_serviceContractRecipient.call(bytes4(bytes32(keccak256("tokenFallback(address,uint256,bytes)"))), _value, this, _extraData)) {`
  calls `tokenFallback(address,uint256,bytes)`, but the parameters sent are `uint256,address,bytes`
  * [x] `tokenFallback(...)` replaced with `approveAndCall(...)` in [be073ee](https://github.com/ShipChain/contracts/commit/be073eef83f861d61452372c97a0a568964c03dc)
* **MEDIUM IMPORTANCE** `SHIPToken.transferAndCall(...)` does not pass the data to the `tokenFallback(...)` function. See the testing results
  * [x] `tokenFallback(...)` replaced with `approveAndCall(...)` in [be073ee](https://github.com/ShipChain/contracts/commit/be073eef83f861d61452372c97a0a568964c03dc)
* **LOW IMPORTANCE** `maxSupply = 500000000` in *MintableToken.sol* and *SHIPToken.sol* does not take into account the 18 decimal places
  It may be clearer to use a constant like `uint256 public constant MAX_SUPPLY = 500000000 * (10 ** uint256(decimals));`
  * [x] Fixed in [be073ee](https://github.com/ShipChain/contracts/commit/be073eef83f861d61452372c97a0a568964c03dc)
* **LOW IMPORTANCE** Consider using [Claimable](https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/ownership/Claimable.sol)
  as this makes the ownership transfer of the token contract safer
  * [x] Added in [be073ee](https://github.com/ShipChain/contracts/commit/be073eef83f861d61452372c97a0a568964c03dc)
* **LOW IMPORTANCE** Consider using [HasNoTokens](https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/ownership/HasNoTokens.sol)
  that includes [CanReclaimToken](https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/ownership/CanReclaimToken.sol)
  as this reduces the risk of any tokens being accidentally sent to the token contract, and any accidentally sent tokens reclaimable. A
  simple alternative is to add some code like
  [OpenANXToken.sol#L451-L458](https://github.com/openanx/OpenANXToken/blob/master/contracts/OpenANXToken.sol#L451-L458)
  * [x] Added in [be073ee](https://github.com/ShipChain/contracts/commit/be073eef83f861d61452372c97a0a568964c03dc)
* **LOW IMPORTANCE** `MintableToken.setMaxSupply(...)` allows the maximum supply to be increased and not decreased. I would expect this
  function to be reversed - only allow the maxSupply to be decreased and not increased. If the maxSupply can only be increased, this
  restriction has no meaning, as the supply can be increased at anytime. Consider switching the restrictions around
  * [x] `setMaxSupply(...)` removed in [4d135f2](https://github.com/ShipChain/contracts/commit/4d135f276c345c5750d5af290a2fd0d595ed16ef)

<br />

### Some Optional Improvements To The Token Contract

* **VERY LOW IMPORTANCE** Consider using [HasNoEther](https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/ownership/HasNoEther.sol)
  as this reduces the risk of ETH being sent to the token contract. Alternatively add `function () public {}` to *SHIPToken.sol* to explicitly
  reject any incoming ETH. Note that ETH can still be sent to the token contract using the `selfdestruct(...)` function call. By default,
  the token contract without a `function () public payable {...}` will reject any incoming ETH anyway
  * [x] Not required

<br />

<hr />

## Potential Vulnerabilities

No potential vulnerabilities have been identified in the token contract.

<br />

<hr />

## Scope

This audit is into the technical aspects of the token contracts. The primary aim of this audit is to ensure that tokens
maintained by these contracts are not easily attacked or stolen by third parties. The secondary aim of this audit is to
ensure the coded algorithms work as expected. This audit does not guarantee that that the code is bugfree, but intends to
highlight any areas of weaknesses.

<br />

<hr />

## Limitations

This audit makes no statements or warranties about the viability of the ShipChain's business proposition, the individuals
involved in this business or the regulatory regime for the business model.

<br />

<hr />

## Risks

Contracts that implement the `receiveApproval(...)` as part of the `approveAndCall(...)` transfer and execution of tokens
pattern should have a whitelist of token contracts that are permissioned to use the `receiveApproval(...)` feature.

<br />

<hr />

## Testing

Details of the testing environment can be found in [test](test).

The following functions were tested using the script [test/01_test1.sh](test/01_test1.sh) with the summary results saved
in [test/test1results.txt](test/test1results.txt) and the detailed output saved in [test/test1output.txt](test/test1output.txt):

The additional [test/TestTokenFallback.sol](test/TestTokenFallback.sol) was created
to test this token contract.

* [x] Deploy token contract
* [x] Deploy TestTokenFallback contract
* [x] Mint tokens
* [x] `transfer(...)`, `approve(...)` and `transferFrom(...)` for non-0 tokens
* [x] `transfer(...)`, `approve(...)` and `transferFrom(...)` for 0 tokens
* [x] `transfer(...)`, `approve(...)` and `transferFrom(...)` for too many tokens - expecting failure
* [x] Send ETH to token contract - expecting failure
* [x] ~`transferAndCall(...)`~
* [x] Testing `approveAndCall(...)` alternative

<br />

<hr />

## Code Review

* [x] [code-review/SafeMath.md](code-review/SafeMath.md)
  * [x] library SafeMath
* [x] [code-review/Ownable.md](code-review/Ownable.md)
  * [x] contract Ownable
* [x] [code-review/Claimable.md](code-review/Claimable.md)
  * [x] contract Claimable is Ownable
* [x] [code-review/Pausable.md](code-review/Pausable.md)
  * [x] contract Pausable is Ownable
* [x] [code-review/ERC20Basic.md](code-review/ERC20Basic.md)
  * [x] contract ERC20Basic
* [x] [code-review/ERC20.md](code-review/ERC20.md)
  * [x] contract ERC20 is ERC20Basic
* [x] [code-review/SafeERC20.md](code-review/SafeERC20.md)
  * [x] library SafeERC20
* [x] [code-review/BasicToken.md](code-review/BasicToken.md)
  * [x] contract BasicToken is ERC20Basic
  * [x]   using SafeMath for uint256;
* [x] [code-review/StandardToken.md](code-review/StandardToken.md)
  * [x] contract StandardToken is ERC20, BasicToken
* [x] [code-review/PausableToken.md](code-review/PausableToken.md)
  * [x] contract PausableToken is StandardToken, Pausable
* [x] [code-review/MintableToken.md](code-review/MintableToken.md)
  * [x] contract MintableToken is StandardToken, Ownable, Claimable
    * [x] TODO `maxSupply` does not include the decimal places
* [x] [code-review/CanReclaimToken.md](code-review/CanReclaimToken.md)
  * [x] contract CanReclaimToken is Ownable
  * [x]   using SafeERC20 for ERC20Basic;
* [x] [code-review/HasNoTokens.md](code-review/HasNoTokens.md)
  * [x] contract HasNoTokens is CanReclaimToken
* [x] [code-review/SHIPToken.md](code-review/SHIPToken.md)
  * [x] contract SHIPToken is StandardToken, PausableToken, MintableToken, HasNoTokens
    * [x] TODO The `transferAndCall(...)` function is not working as expected
    * [x] TODO `maxSupply` does not include the decimal places
* [x] [code-review/TestTokenFallback.md](code-review/TestTokenFallback.md)
  * [x] contract ERC20Interface
  * [x] contract TestTokenFallback is Ownable

<br />

<hr />

## References

* [ERC-20 Token Standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md)
* [ERC: transferAndCall Token Standard #677](https://github.com/ethereum/EIPs/issues/677)

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for ShipChain - Apr 8 2017. The MIT Licence.