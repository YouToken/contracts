pragma solidity ^0.4.23;

import './IEventListener.sol';
import 'zeppelin-solidity/contracts/token/ERC20/MintableToken.sol';

contract EventToken is MintableToken {
    mapping(address => bool) addedListeners;
    IEventListener[] listeners;

    function addListener(address _listener) public onlyOwner {
        require(!addedListeners[_listener]);

        listeners.push(IEventListener(_listener));
        addedListeners[_listener] = true;
    }

    function emitTokenTransfer(address from, address to, uint256 value) internal {
        if (listeners.length == 0) return;

        for (uint256 i = 0; i < listeners.length; i++) {
            listeners[i].onTokenTransfer(from, to, value);
        }
    }

    function emitTokenApproval(address from, address to, uint256 value) internal {
        if (listeners.length == 0) return;

        for (uint256 i = 0; i < listeners.length; i++) {
            listeners[i].onTokenApproval(from, to, value);
        }
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        super.transferFrom(from, to, value);
        emitTokenTransfer(from, to, value);
        return true;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        super.transfer(to, value);
        emitTokenTransfer(msg.sender, to, value);
        return true;
    }

    function mint(address to, uint256 value) public returns (bool) {
        super.mint(to, value);
        emitTokenTransfer(address(0), to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        super.approve(spender, value);
        emitTokenApproval(msg.sender, spender, value);
        return true;
    }
}
