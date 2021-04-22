pragma solidity ^0.4.25;

import "./VeggieSupplyChainStorageOwnable.sol";

contract VeggieSupplyChainStorage is VeggieSupplyChainStorageOwnable {
    
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
    
    /* User Related / Users: Farmer, Unloader, Inspector, WarehouseOfficer, DeliveryOfficer, Customer */
    struct User {
        string name;
    } 
    
    /* Process Related / Processes: PURCHASE, INSPECTION, WAREHOUSE, SALES, SHIPPING, CONSIGNMENT, END */
    struct PurchaseBatch {
        string goodsInfo;
        uint8 quantity;
        string farmerName;
        string farmLocation;
        address farmer;
        uint256 timestamp;
    }

    struct Purchase {
        uint8 quantity;
        address unloader;
        uint256 timestamp;
    }
    
    struct Inspection {
        string memoReturn;
        uint8 quantityReturn;
        uint8 quantity;
        address inspector;
        uint256 timestamp;
    }
    
    struct Warehouse {
        string shelfNo;
        uint8 quantity;
        address warehouseOfficer;
        uint256 timestamp;
    }

    struct ShippingBatch {
        address customerOrderNo;
        address purchaseBatchNo;
        uint8 quantity;
        address warehouseOfficer;
        uint256 timestamp;
    }
    
    struct Shipping { 
        uint8 quantity;
        string driver;
        string truckNo;
        string destination;
        address deliveryOfficer;
        uint256 timestamp;
    }
    
    struct CustomerConsignment {
        string orderNo;
        string goodsInfo;
        uint8 quantity;
        uint8 defectiveQuantity;
        address customer;
        uint256 timestamp;
    }
    
    mapping (address => User) user;
    mapping (address => string) userRole;
    mapping (address => string) nextAction;
    mapping (address => PurchaseBatch) purchaseBatch;
    mapping (address => Purchase) purchase;
    mapping (address => Inspection) inspection;
    mapping (address => Warehouse) warehouse;
    mapping (address => ShippingBatch) shippingBatch;
    mapping (address => Shipping) shipping;
    mapping (address => CustomerConsignment) customerConsignment;
    
    /* Initialize struct pointer */
    User userData;
    PurchaseBatch purchaseBatchData;
    Purchase purchaseData;
    Inspection inspectionData;
    Warehouse warehouseData;
    ShippingBatch shippingBatchData;
    Shipping shippingData;
    CustomerConsignment customerConsignmentData;
    
    /* Get User Role */
    function getUserRole(address _address) public onlyAuthCaller view returns(string) {
        return userRole[_address];
    }
    
    /* Get Next Action */    
    function getNextAction(address _batchNo) public onlyAuthCaller view returns(string) {
        return nextAction[_batchNo];
    }
        
    /* set user details */
    function setUser(address _address,
                     string  _name,
                     string  _role) public onlyAuthCaller returns(bool) {
        
        /*store data into struct*/
        userData.name = _name;
        
        /*store data into mapping*/
        user[_address] = userData;
        userRole[_address] = _role;
        return true;
    }  
    
    /* get user details */
    function getUser(address _address) public onlyAuthCaller view returns(string, 
                                                                          string) {
        
        /*Getting value from struct*/
        User memory data = user[_address];
        
        return (data.name,
                userRole[_address]);
    }
    
    /* generate purchase batch */
    function setPurchaseBatchNo(string  _goodsInfo,
                                uint8   _QTY,
                                string  _farmerName,
                                string  _farmLocation,
                                address _farmer,
                                uint256 _timestamp) public onlyAuthCaller returns(address) {
        
        uint tmpData = uint(keccak256(_farmer, now));
        address _batchNo = address (tmpData);
        
        purchaseBatchData.goodsInfo = _goodsInfo;
        purchaseBatchData.quantity = _QTY;
        purchaseBatchData.farmerName = _farmerName;
        purchaseBatchData.farmLocation = _farmLocation;
        purchaseBatchData.farmer = _farmer;
        purchaseBatchData.timestamp = _timestamp;
       
        purchaseBatch[_batchNo] = purchaseBatchData;
        nextAction[_batchNo] = 'PURCHASE';   
        return _batchNo;
    }
    
    /* get purchase batch data */
    function getPurchaseBatchData(address _batchNo) public onlyAuthCaller view returns(uint256,
                                                                                       uint8,
                                                                                       string,
                                                                                       string,
                                                                                       string,
                                                                                       address) {
            
        PurchaseBatch memory data = purchaseBatch[_batchNo];
        
        return (data.timestamp,
                data.quantity, 
                data.goodsInfo,
                data.farmerName,
                data.farmLocation,
                data.farmer);
    }
    
    /* set purchase data */ 
    function setPurchaseData(address _batchNo,
                             uint8   _QTY,
                             address _unloader,
                             uint256 _timestamp) public onlyAuthCaller returns(bool) {
                             
        purchaseData.quantity = _QTY;
        purchaseData.unloader = _unloader;
        purchaseData.timestamp = _timestamp;
        
        purchase[_batchNo] = purchaseData;
        nextAction[_batchNo] = 'INSPECTION'; 
        return true;
    }
    
    /* get purchase data */ 
    function getPurchaseData(address _batchNo) public onlyAuthCaller view returns(uint256,
                                                                                  uint8,
                                                                                  address) {
                                                                                        
        Purchase memory data = purchase[_batchNo];
        
        return (data.timestamp,
                data.quantity,
                data.unloader);
    }
    
    /* set inspection data */
    function setInspectionData(address _batchNo,
                               string  _memoReturn,
                               uint8   _QTYReturn,
                               uint8   _QTY,
                               address _inspector,
                               uint256 _timestamp) public onlyAuthCaller returns(bool) {
                                   
        Purchase memory data = purchase[_batchNo];
        require(_QTYReturn <= data.quantity, "Quantity shouldn't exceed purchase!");
        require(_QTY == data.quantity - _QTYReturn, "Quantity doesn't match!");
        
        inspectionData.memoReturn = _memoReturn;
        inspectionData.quantityReturn = _QTYReturn;
        inspectionData.quantity = _QTY;
        inspectionData.inspector = _inspector;
        inspectionData.timestamp = _timestamp;
        
        inspection[_batchNo] = inspectionData;
        nextAction[_batchNo] = 'WAREHOUSE'; 
        return true;
    }
    
    /* get inspection data */
    function getInspectionData(address _batchNo) public onlyAuthCaller view returns (uint256,
                                                                                     uint8,    
                                                                                     uint8,
                                                                                     string,
                                                                                     address) {
        
        Inspection memory data = inspection[_batchNo];
        
        return (data.timestamp,
                data.quantityReturn,
                data.quantity,
                data.memoReturn,
                data.inspector);
    }
    
    /* set warehouse-in data */
    function setWarehouseData(address _batchNo, 
                              string  _shelfNo,
                              uint8   _QTY,
                              address _warehouseOfficer,
                              uint256 _timestamp) public onlyAuthCaller returns(bool) {
        
        Inspection memory data = inspection[_batchNo];
        require(_QTY == data.quantity, "Quantity doesn't match!");
        
        warehouseData.shelfNo = _shelfNo;
        warehouseData.quantity = _QTY;
        warehouseData.warehouseOfficer = _warehouseOfficer;
        warehouseData.timestamp = _timestamp;
        
        warehouse[_batchNo] = warehouseData;
        nextAction[_batchNo] = 'SALES'; 
        return true;
    }
    
    /* get warehouse-in data */ 
    function getWarehouseData(address _batchNo) public onlyAuthCaller view returns(uint256,
                                                                                   uint8,
                                                                                   string,
                                                                                   address) {

        Warehouse memory data = warehouse[_batchNo];
        
        return (data.timestamp,
                data.quantity,
                data.shelfNo,
                data.warehouseOfficer);
    }

    /* generate shipping batch */
    function setShippingBatchNo(address _customerOrderNo,
                                address _purchaseBatchNo,
                                uint8   _QTY,
                                address _warehouseOfficer,
                                uint256 _timestamp) public onlyAuthCaller returns(address) {
        
        Warehouse memory data = warehouse[_purchaseBatchNo];
        require(_QTY <= data.quantity, "Stock not enough!");
        uint8 residual = uint8 (data.quantity - _QTY);
        
        warehouseData.shelfNo = data.shelfNo;
        warehouseData.quantity = residual;
        warehouseData.warehouseOfficer = data.warehouseOfficer;
        warehouseData.timestamp = data.timestamp;
        
        warehouse[_purchaseBatchNo] = warehouseData;
                                 
        uint tmpData = uint(keccak256(_warehouseOfficer, now));
        address _batchNo = address (tmpData);
        
        shippingBatchData.customerOrderNo = _customerOrderNo;
        shippingBatchData.purchaseBatchNo = _purchaseBatchNo;
        shippingBatchData.quantity = _QTY;
        shippingBatchData.warehouseOfficer = _warehouseOfficer;
        shippingBatchData.timestamp = _timestamp;
        
        shippingBatch[_batchNo] = shippingBatchData;
        nextAction[_batchNo] = 'SHIPPING';
        return _batchNo;
    }
    
    /* get shipping batch data */
    function getShippingBatchData(address _batchNo) public onlyAuthCaller view returns(uint256,
                                                                                       uint8,
                                                                                       address,
                                                                                       address,
                                                                                       address) {
                                                                                            
        ShippingBatch memory data = shippingBatch[_batchNo];
        
        return (data.timestamp,
                data.quantity,
                data.customerOrderNo,
                data.purchaseBatchNo,
                data.warehouseOfficer);
    }
    
    /* set shipping data */
    function setShippingData(address _batchNo,
                             uint8   _QTY,
                             string  _driver,
                             string  _truckNo,
                             string  _destination,
                             address _deliveryOfficer,
                             uint256 _timestamp) public onlyAuthCaller returns(bool) {
        
        ShippingBatch memory data = shippingBatch[_batchNo];
        require(_QTY == data.quantity, "Quantity doesn't match!");
                             
        shippingData.quantity = _QTY;
        shippingData.driver = _driver;
        shippingData.truckNo = _truckNo;
        shippingData.destination = _destination;
        shippingData.deliveryOfficer = _deliveryOfficer;
        shippingData.timestamp = _timestamp;
        
        shipping[_batchNo] = shippingData;
        nextAction[_batchNo] = 'CONSIGNMENT'; 
        return true;
    }
    
    /* get shipping data */
    function getShippingData(address _batchNo) public onlyAuthCaller view returns(uint256,
                                                                                  uint8,
                                                                                  string,
                                                                                  string,
                                                                                  string,
                                                                                  address) {
                                                                                        
        Shipping memory data = shipping[_batchNo];
        
        return (data.timestamp,
                data.quantity,
                data.driver,
                data.truckNo, 
                data.destination,
                data.deliveryOfficer);
    }
    
    /* generate consignment No */
    function setConsignmentData(address _batchNo,
                                string  _orderNo,
                                string  _goodsInfo,
                                uint8   _quantity,
                                uint8   _defectiveQuantity,
                                address _customer,
                                uint256 _timestamp) public onlyAuthCaller returns(bool) {
        
        customerConsignmentData.orderNo = _orderNo;
        customerConsignmentData.goodsInfo = _goodsInfo;
        customerConsignmentData.quantity = _quantity;
        customerConsignmentData.defectiveQuantity = _defectiveQuantity;
        customerConsignmentData.customer = _customer;
        customerConsignmentData.timestamp = _timestamp;
       
        customerConsignment[_batchNo] = customerConsignmentData;
        nextAction[_batchNo] = 'END';
        return true;
    }
    
    /* get consignment data */
    function getConsignmentData(address _batchNo) public onlyAuthCaller view returns(uint256,
                                                                                     uint8,
                                                                                     uint8,
                                                                                     string,
                                                                                     string,
                                                                                     address) {
        
        CustomerConsignment memory data = customerConsignment[_batchNo];
        
        return (data.timestamp,
                data.quantity,
                data.defectiveQuantity,
                data.orderNo,
                data.goodsInfo,
                data.customer);
    }
}