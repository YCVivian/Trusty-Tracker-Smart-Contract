pragma solidity ^0.4.25;

import "./VeggieSupplyChainStorage.sol";
import "./Ownable.sol";

contract VeggieSupplyChainUser is Ownable {
    
    /* Events */ 
    event UserUpdate(address indexed user, string name, string role);
    
    /* Storage Variables */    
    VeggieSupplyChainStorage veggieSupplyChainStorage;
    
    constructor(address _address) public {
        veggieSupplyChainStorage = VeggieSupplyChainStorage(_address);
    }   
    
    /* Create/Update User For Admin */
    function updateUserForAdmin(address userAddress, string name, string role) public onlyOwner returns(bool) {
        
        require(userAddress != address(0), "Address format error!");
        
        /* Call Storage Contract */
        bool status = veggieSupplyChainStorage.setUser(userAddress, name, role);
        
        /* call event */
        emit UserUpdate(userAddress, name, role);
        return status;
    }
    
    /* get User */
    function getUser(address userAddress) public view returns(string name, string role) {
        
        require(userAddress != address(0), "Address format error!");
        
        /* Getting value from struct */
        (name, role) = veggieSupplyChainStorage.getUser(userAddress);
       
        return (name, role);
    }
}