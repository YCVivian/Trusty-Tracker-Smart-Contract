pragma solidity ^0.4.25;

import "./ConsignmentStorage.sol";
import "./Ownable.sol";

contract Consignment is Ownable {
    
    event DoneConsignment(address indexed customer, address indexed consignmentNo, address indexed shippingBatchNo, string orderNo, string goodsInfo, uint8 quantity, uint8 defectiveQuantity, uint256 timestamp);
    
    ConsignmentStorage consignmentStorage;

    constructor(address _address) public {
        consignmentStorage = ConsignmentStorage(_address);
    }
    
    function addConsignmentData(address shippingBatchNo,
                                string  orderNo,
                                string  goodsInfo,
                                uint8   quantity,
                                uint8   defectiveQuantity) public onlyOwner returns(address) {
                                                                  
        address consignmentNo = consignmentStorage.setConsignmentNo(shippingBatchNo,
                                                                    orderNo,
                                                                    goodsInfo,
                                                                    quantity,
                                                                    defectiveQuantity,
                                                                    msg.sender,
                                                                    now);
    
        emit DoneConsignment(msg.sender, consignmentNo, shippingBatchNo, orderNo, goodsInfo, quantity, defectiveQuantity, now);
        return consignmentNo;
    }
    
    function getConsignmentData(address consignmentNo) public view returns(address shippingBatchNo,
                                                                           string  orderNo,
                                                                           string  goodsInfo,
                                                                           uint8   quantity,
                                                                           uint8   defectiveQuantity,
                                                                           address customer,
                                                                           uint256 arrivalDateTime) {
        
        (shippingBatchNo,
         orderNo,
         goodsInfo,
         quantity,
         defectiveQuantity,
         customer,
         arrivalDateTime) = consignmentStorage.getConsignmentData(consignmentNo);  
        
        return (shippingBatchNo,
                orderNo,
                goodsInfo, 
                quantity, 
                defectiveQuantity,
                customer,
                arrivalDateTime);
    }
}