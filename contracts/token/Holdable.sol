pragma solidity ^0.4.23;

import './IEventListener.sol';
import 'zeppelin-solidity/contracts/token/ERC20/PausableToken.sol';

contract Holdable is PausableToken {
    mapping(address => uint256) holders;
    mapping(address => bool) allowTransfer;

    IEventListener public listener;

    event Hold(address holder, uint256 expired);
    event Unhold(address holder);

    function hold(address _holder, uint256 _expired) public onlyOwner {
        holders[_holder] = _expired;
        Hold(_holder, _expired);
    }

    function isHold(address _holder) public view returns(bool) {
        return holders[_holder] > block.timestamp;
    }

    function unhold() public {
        address holder = msg.sender;
        require(block.timestamp >= holders[holder]);
        delete holders[holder];
        Unhold(holder);
    }

    function unhold(address _holder) public {
        require(block.timestamp >= holders[_holder]);
        delete holders[_holder];
        Unhold(_holder);
    }

    function addAllowTransfer(address _holder) public onlyOwner {
        allowTransfer[_holder] = true;
    }

    function isAllowTransfer(address _holder) public view returns(bool) {
        return allowTransfer[_holder] || (!paused && block.timestamp >= holders[_holder]);
    }

    modifier whenNotPaused() {
        require(isAllowTransfer(msg.sender));
        _;
    }

    function addListener(address _listener) public onlyOwner {
        listener = IEventListener(_listener);
    }

    function isListener() internal view returns(bool) {
        return listener != address(0);
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        super.transferFrom(from, to, value);
        if (isListener()) listener.onTokenTransfer(from, to, value);

        return true;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        super.transfer(to, value);
        if (isListener()) listener.onTokenTransfer(msg.sender, to, value);

        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        super.approve(spender, value);
        if (isListener()) listener.onTokenApproval(msg.sender, spender, value);

        return true;
    }
}
