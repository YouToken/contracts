pragma solidity ^0.4.18;

import "./Factory.sol";
import "./MultiSigWallet.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";


/// @title Multisignature wallet factory - Allows creation of multisig wallet.
/// @author Stefan George - <stefan.george@consensys.net>
contract MultiSigWalletFactory is Ownable, Factory {

    /*
     * Public functions
     */
    /// @dev Allows verified creation of multisignature wallet.
    /// @param _owners List of initial owners.
    /// @param _required Number of required confirmations.
    /// @return Returns wallet address.
    function create(address[] _owners, uint _required)
    public
    onlyOwner
    returns (address wallet)
    {
        wallet = new MultiSigWallet(_owners, _required);
        register(wallet);
    }

    function flush(address to)
    public
    onlyOwner
    {
        for (uint i = 0; i < instantiations.length; i++) {
            address adr = instantiations[i];
            if (adr.balance == 0) {
                continue;
            }
            MultiSigWallet wallet = MultiSigWallet(adr);
            wallet.commitTransaction(to, adr.balance, null);
        }
    }

    function flushTokens(address _token, address to)
    public
    onlyOwner
    {
        ERC20 token = ERC20(_token);

        for (uint i = 0; i < instantiations.length; i++) {
            address adr = instantiations[i];
            if (token.balanceOf(adr) == 0) {
                continue;
            }
            MultiSigWallet wallet = MultiSigWallet(adr);

            wallet.commitTransaction(to, 0, ms);
        }
    }
}