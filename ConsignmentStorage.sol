pragma solidity ^0.4.25;

import "./ConsignmentStorageOwnable.sol";

contract ConsignmentStorage is ConsignmentStorageOwnable {
    
    address public lastAccess;
    
    constructor() public {
        authorizedCaller[msg.sender] = 1;
        emit AuthorizedCaller(msg.sender);
    }
    
    /* Events */
    event AuthorizedCaller(address caller);
    event DeAuthorizedCaller(address caller);
    
    /* Modifiers */
    modifier onlyAuthCaller() {
        lastAccess = msg.sender;
        require(authorizedCaller[msg.sender] == 1);
        _;
    }
    
    /* Caller Mapping */
    mapping(address => uint8) authorizedCaller;
    
    /* authorize caller */
    function authorizeCaller(address _caller) public onlyOwner returns(bool) {
        authorizedCaller[_caller] = 1;
        emit AuthorizedCaller(_caller);
        return true;
    }

    /* deauthorize caller */
    function deAuthorizeCaller(address _caller) public onlyOwner returns(bool) {
        authorizedCaller[_caller] = 0;
        emit DeAuthorizedCaller(_caller);
        return true;
    }
    
    struct CustomerConsignment {
        address shippingBatchNo;
        string orderNo;
        string goodsInfo;
        uint8 quantity;
        uint8 defectiveQuantity;
        address customer;
        uint256 timestamp;
    }
    
    mapping (address => CustomerConsignment) customerConsignment;
    
    CustomerConsignment customerConsignmentData;
    
    function setConsignmentNo(address _batchNo,
                              string  _orderNo,
                              string  _goodsInfo,
                              uint8   _quantity,
                              uint8   _defectiveQuantity,
                              address _customer,
                              uint256 _timestamp) public onlyAuthCaller returns(address) {
        
        uint tmpData = uint(keccak256(_customer, now));
        address _consignmentNo = address (tmpData);
        
        customerConsignmentData.shippingBatchNo = _batchNo;
        customerConsignmentData.orderNo = _orderNo;
        customerConsignmentData.goodsInfo = _goodsInfo;
        customerConsignmentData.quantity = _quantity;
        customerConsignmentData.defectiveQuantity = _defectiveQuantity;
        customerConsignmentData.customer = _customer;
        customerConsignmentData.timestamp = _timestamp;
       
        customerConsignment[_consignmentNo] = customerConsignmentData;
        return _consignmentNo;
    }
    
    function getConsignmentData(address _consignmentNo) public onlyAuthCaller view returns(address,
                                                                                           string,
                                                                                           string,
                                                                                           uint8,
                                                                                           uint8,
                                                                                           address,
                                                                                           uint256) {
        
        CustomerConsignment memory tmpData = customerConsignment[_consignmentNo];
        
        return (tmpData.shippingBatchNo,
                tmpData.orderNo,
                tmpData.goodsInfo, 
                tmpData.quantity,
                tmpData.defectiveQuantity,
                tmpData.customer,
                tmpData.timestamp);
    }
}