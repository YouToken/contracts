pragma solidity ^0.4.18;

contract Factory {

    /*
     *  Events
     */
    event ContractInstantiation(address sender, address instantiation);

    /*
     *  Storage
     */
    mapping(address => bool) public isInstantiation;
    address[] public instantiations;

    /*
     * Public functions
     */
    /// @dev Returns number of instantiations.
    /// @return Returns number of instantiations.
    function getInstantiationCount()
    public
    constant
    returns (uint)
    {
        return instantiations.length;
    }

    /*
     * Internal functions
     */
    /// @dev Registers contract in factory registry.
    /// @param instantiation Address of contract instantiation.
    function register(address instantiation)
    internal
    {
        isInstantiation[instantiation] = true;
        instantiations.push(instantiation);
        ContractInstantiation(msg.sender, instantiation);
    }
}