pragma solidity ^0.4.18;

interface IEventListener {
    function onTokenTransfer(address _from, address _to, uint256 _value) public;
    function onTokenApproval(address _from, address _to, uint256 _value) public;
}
