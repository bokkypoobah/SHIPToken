# TestTokenFallback

Source file [../../POC/contracts/token-contract-v5/TestTokenFallback.sol](../../POC/contracts/token-contract-v5/TestTokenFallback.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;

// BK Ok
import "./Ownable.sol";

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
// BK Ok
contract ERC20Interface {
    // BK Next 6 Ok
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    // BK Next 2 Ok - Events
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// Contracts that can have tokens approved, and then a function execute
// ----------------------------------------------------------------------------
// BK Ok - Only for testing
contract TestTokenFallback is Ownable {
    // BK Ok
    bool public requireFlag = true;
    // BK Ok
    bool public successFlag = true;

    // BK Next 2 Ok - Events
    event LogTokenFallback(address indexed msgSender, address indexed from, uint256 amount, bytes data);
    event LogReceiveApproval(address indexed msgSender, uint256 amount, address indexed token, bytes data);

    // BK Ok - Only owner can execute
    function setRequireFlag(bool _requireFlag) public onlyOwner {
        // BK Ok
        requireFlag = _requireFlag;
    }

    // BK Ok - Only owner can execute
    function setSuccessFlag(bool _successFlag) public onlyOwner {
        // BK Ok
        successFlag = _successFlag;
    }

    // BK Ok - Not used
    function tokenFallback(address from, uint256 amount, bytes data) public returns (bool success) {
        // ERC20Interface(token).transferFrom(from, address(this), tokens);
        // BK Ok
        require(requireFlag);
        // BK Ok - Log event
        LogTokenFallback(msg.sender, from, amount, data);
        // BK Ok
        return successFlag;
    }

    // BK Ok
    function receiveApproval(address from, uint256 amount, address token, bytes data) public {
        // BK Ok
        require(requireFlag);
        // BK Ok
        ERC20Interface(token).transferFrom(from, address(this), amount);
        // BK Ok - Log event
        LogReceiveApproval(msg.sender, amount, token, data);
    }
}
```
