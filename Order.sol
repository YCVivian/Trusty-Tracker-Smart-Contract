pragma solidity ^0.4.25;

import "./OrderStorage.sol";
import "./Ownable.sol";

contract Order is Ownable {
    
    event DoneCustomerOrder(address indexed salesman, address indexed customerOrderNo, string orderNo, string goodsInfo, uint8 quantity, address customer, uint256 timestamp);
    
    OrderStorage orderStorage;

    constructor(address _address) public {
        orderStorage = OrderStorage(_address);
    }
    
    function addCustomerOrder(string  orderNo,
                              string  goodsInfo,
                              uint8   quantity,
                              address customer) public onlyOwner returns(address) {
                                                       
        address customerOrderNo = orderStorage.setCustomerOrderNo(orderNo,
                                                                  goodsInfo,
                                                                  quantity,
                                                                  customer,
                                                                  msg.sender,
                                                                  now);
    
        emit DoneCustomerOrder(msg.sender, customerOrderNo, orderNo, goodsInfo, quantity, customer, now);
        return customerOrderNo;
    }
    
    function getCustomerOrder(address customerOrderNo) public view returns(string  orderNo,
                                                                           string  goodsInfo,
                                                                           uint8   quantity,
                                                                           address customer,
                                                                           address salesman,
                                                                           uint256 orderDateTime) {
        
        (orderNo,
         goodsInfo,
         quantity, 
         customer,
         salesman,
         orderDateTime) = orderStorage.getCustomerOrder(customerOrderNo);  
        
        return (orderNo,
                goodsInfo, 
                quantity, 
                customer,
                salesman,
                orderDateTime);
    }
}