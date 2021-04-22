pragma solidity ^0.4.25;

import "./OrderStorageOwnable.sol";

contract OrderStorage is OrderStorageOwnable {
    
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
    
    struct CustomerOrder {
        string orderNo;//from customers
        string goodsInfo;
        uint8 quantity;
        address customer;
        address salesman;
        uint256 timestamp;
    }
    
    mapping (address => CustomerOrder) customerOrder;
    
    CustomerOrder customerOrderData;
    
    function setCustomerOrderNo(string  _orderNo,
                                string  _goodsInfo,
                                uint8   _quantity,
                                address _customer,
                                address _salesman,
                                uint256 _timestamp) public onlyAuthCaller returns(address) {
        
        uint tmpData = uint(keccak256(_salesman, now));
        address _customerOrderNo = address (tmpData);
        
        customerOrderData.orderNo = _orderNo;
        customerOrderData.goodsInfo = _goodsInfo;
        customerOrderData.quantity = _quantity;
        customerOrderData.customer = _customer;
        customerOrderData.salesman = _salesman;
        customerOrderData.timestamp = _timestamp;
       
        customerOrder[_customerOrderNo] = customerOrderData;
        return _customerOrderNo;
    }
    
    function getCustomerOrder(address _customerOrderNo) public onlyAuthCaller view returns(string,
                                                                                           string,
                                                                                           uint8,
                                                                                           address,
                                                                                           address,
                                                                                           uint256) {
        
        CustomerOrder memory tmpData = customerOrder[_customerOrderNo];
        
        return (tmpData.orderNo,
                tmpData.goodsInfo, 
                tmpData.quantity,
                tmpData.customer,
                tmpData.salesman,
                tmpData.timestamp);
    }
}