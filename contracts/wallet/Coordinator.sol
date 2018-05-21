pragma solidity ^0.4.18;

import './MultiSigWallet.sol';

contract Coordinator {

    mapping(address => bool) allowWallets;
    address[] wallets;

    function Coordinator(){

    }

    function send(uint amount) onlyOwner {

    }
}
