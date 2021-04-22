pragma solidity ^0.4.25;

import "./VeggieSupplyChainStorage.sol";
import "./Ownable.sol";

contract VeggieSupplyChain is Ownable {
    
    event DonePurchaseBatch(address indexed farmer, address indexed purchaseBatchNo, string goodsInfo, uint8 quantity, string farmerName, string farmLocation, uint256 timestamp);
    event DonePurchase(address indexed unloader, address indexed purchaseBatchNo, uint8 quantity, uint256 timestamp);
    event DoneInspection(address indexed inspector, address indexed purchaseBatchNo, string memoReturn, uint8 quantityReturn, uint8 quantity, uint256 timestamp);
    event DoneWarehouse(address indexed warehouseOfficer, address indexed purchaseBatchNo, string shelfNo, uint8 quantity, uint256 timestamp);
    event DoneShippingBatch(address indexed warehouseOfficer, address indexed shippingBatchNo, address indexed customerOrderNo, address purchaseBatchNo, uint8 quantity, uint256 timestamp); 
    event DoneShipping(address indexed deliveryOfficer, address indexed shippingBatchNo, uint8 quantity, string driver, string truckNo, string destination, uint256 timestamp);
    event DoneConsignment(address indexed customer, address indexed shippingBatchNo, string orderNo, string goodsInfo, uint8 quantity, uint8 defectiveQuantity, uint256 timestamp);
    
    /* Modifier */
    modifier userRoleCheck(string role) {
        
        require(keccak256(veggieSupplyChainStorage.getUserRole(msg.sender)) == keccak256(role));
        _;
    }
    
    modifier userRoleActionCheck(address batchNo, string role, string action) {
        
        require(keccak256(veggieSupplyChainStorage.getUserRole(msg.sender)) == keccak256(role));
        require(keccak256(veggieSupplyChainStorage.getNextAction(batchNo)) == keccak256(action));
        _;
    }
    
    VeggieSupplyChainStorage veggieSupplyChainStorage;

    constructor(address _address) public {
        veggieSupplyChainStorage = VeggieSupplyChainStorage(_address);
    }
    
    /* Get Next Action */    
    function getNextAction(address batchNo) public view returns(string action) {
        action = veggieSupplyChainStorage.getNextAction(batchNo);
        return action;
    }
    
    /* Generate purchase batch */
    function addBatchPurchase(string goodsInfo,
                              uint8  quantity,
                              string farmerName,
                              string farmLocation) public userRoleCheck('Farmer') returns(address) {
                                                         
        /* Call Storage Contract */
        address purchaseBatchNo = veggieSupplyChainStorage.setPurchaseBatchNo(goodsInfo,
                                                                              quantity,
                                                                              farmerName,
                                                                              farmLocation,
                                                                              msg.sender,
                                                                              now);
    
        emit DonePurchaseBatch(msg.sender, purchaseBatchNo, goodsInfo, quantity, farmerName, farmLocation, now);
        return purchaseBatchNo;
    }
    
    function getBatchPurchaseData(address purchaseBatchNo) public view returns(uint256 deliveryDateTime,
                                                                               uint8   quantity,
                                                                               string  goodsInfo,
                                                                               string  farmerName,
                                                                               string  farmLocation,
                                                                               address farmer) {
        
        /* Call Storage Contract */
        (deliveryDateTime,
         quantity,
         goodsInfo,
         farmerName,
         farmLocation,
         farmer) = veggieSupplyChainStorage.getPurchaseBatchData(purchaseBatchNo);  
        
        return (deliveryDateTime, quantity, goodsInfo, farmerName, farmLocation, farmer);
    }
    
    /* Perform unloading */
    function updatePurchaseData(address purchaseBatchNo,
                                uint8   quantity) public userRoleActionCheck(purchaseBatchNo, 'Unloader', 'PURCHASE') returns(bool) {
                                    
        /* Call Storage Contract */
        bool status = veggieSupplyChainStorage.setPurchaseData(purchaseBatchNo, 
                                                               quantity,
                                                               msg.sender,
                                                               now);
        
        emit DonePurchase(msg.sender, purchaseBatchNo, quantity, now);
        return status;                                                        
    }                                                        
                                                             
    function getPurchaseData(address purchaseBatchNo) public view returns(uint256 arrivalDateTime,
                                                                          uint8   quantity,
                                                                          address unloader) {
                                                                    
        /* Call Storage Contract */
        (arrivalDateTime,
         quantity,
         unloader) = veggieSupplyChainStorage.getPurchaseData(purchaseBatchNo);  
         
        return (arrivalDateTime, quantity, unloader);
    }
    
    /* Perform inspection */
    function updateInspectionData(address purchaseBatchNo,
                                  string  memoReturn,
                                  uint8   quantityReturn,
                                  uint8   quantity) public userRoleActionCheck(purchaseBatchNo, 'Inspector', 'INSPECTION') returns(bool) {
        
        /* Call Storage Contract */
        bool status = veggieSupplyChainStorage.setInspectionData(purchaseBatchNo,
                                                                 memoReturn,
                                                                 quantityReturn,
                                                                 quantity,
                                                                 msg.sender,
                                                                 now);  
        
        emit DoneInspection(msg.sender, purchaseBatchNo, memoReturn, quantityReturn, quantity, now);
        return status;
    }
    
    function getInspectionData(address purchaseBatchNo) public view returns(uint256 inspectionDateTime,
                                                                            uint8   quantityReturn,
                                                                            uint8   quantity,
                                                                            string  memoReturn,
                                                                            address inspector) {
        
        /* Call Storage Contract */
        (inspectionDateTime,
         quantityReturn,   
         quantity,
         memoReturn,
         inspector) = veggieSupplyChainStorage.getInspectionData(purchaseBatchNo);  
        
        return (inspectionDateTime, quantityReturn, quantity, memoReturn, inspector);
    }
    
    /* Perform warehouse-in */
    function updateWarehouseData(address purchaseBatchNo,
                                 string  shelfNo,
                                 uint8   quantity) public userRoleActionCheck(purchaseBatchNo, 'WarehouseOfficer', 'WAREHOUSE') returns(bool) {
                                    
        /* Call Storage Contract */
        bool status = veggieSupplyChainStorage.setWarehouseData(purchaseBatchNo,
                                                                shelfNo,
                                                                quantity,
                                                                msg.sender,
                                                                now);  
        
        emit DoneWarehouse(msg.sender, purchaseBatchNo, shelfNo, quantity, now);
        return status;
    }
    
    function getWarehouseData(address purchaseBatchNo) public view returns(uint256 stackDateTime,
                                                                           uint8   quantity,
                                                                           string  shelfNo,
                                                                           address warehouseOfficer) {
        
        /* Call Storage Contract */
        (stackDateTime,
         quantity,
         shelfNo,
         warehouseOfficer) =  veggieSupplyChainStorage.getWarehouseData(purchaseBatchNo);  
        
        return (stackDateTime, quantity, shelfNo, warehouseOfficer);
    }
    
    /* Generate shipping batch */
    function addBatchShipping(address customerOrderNo,
                              address purchaseBatchNo,
                              uint8   quantity) public userRoleActionCheck(purchaseBatchNo, 'WarehouseOfficer', 'SALES') returns(address) {
                                                        
        /* Call Storage Contract */
        address shippingBatchNo = veggieSupplyChainStorage.setShippingBatchNo(customerOrderNo,
                                                                              purchaseBatchNo,
                                                                              quantity,
                                                                              msg.sender,
                                                                              now);
        
        emit DoneShippingBatch(msg.sender, shippingBatchNo, customerOrderNo, purchaseBatchNo, quantity, now); 
        return shippingBatchNo;
    }
    
    function getBatchShippingData(address shippingBatchNo) public view returns(uint256 pickingDateTime,
                                                                               uint8   quantity,
                                                                               address customerOrderNo,
                                                                               address purchaseBatchNo,
                                                                               address warehouseOfficer) {
         
        /* Call Storage Contract */
        (pickingDateTime,
         quantity,
         customerOrderNo,
         purchaseBatchNo,
         warehouseOfficer) = veggieSupplyChainStorage.getShippingBatchData(shippingBatchNo);  
         
        return (pickingDateTime, quantity, customerOrderNo, purchaseBatchNo, warehouseOfficer);
    }
    
    /* Perform shipping */
    function updateShippingData(address shippingBatchNo,
                                uint8   quantity,
                                string  driver,
                                string  truckNo,
                                string  destination) public userRoleActionCheck(shippingBatchNo, 'DeliveryOfficer','SHIPPING') returns(bool) {
                                
        /* Call Storage Contract */
        bool status = veggieSupplyChainStorage.setShippingData(shippingBatchNo,
                                                               quantity,
                                                               driver, 
                                                               truckNo,
                                                               destination,
                                                               msg.sender,
                                                               now);  
        
        emit DoneShipping(msg.sender, shippingBatchNo, quantity, driver, truckNo, destination, now);
        return status;
    }
    
    function getShippingData(address shippingBatchNo) public view returns(uint256 shippingDateTime,
                                                                          uint8   quantity,
                                                                          string  driver,
                                                                          string  truckNo, 
                                                                          string  destination,
                                                                          address deliveryOfficer) {
         
        /* Call Storage Contract */
        (shippingDateTime,
         quantity,
         driver,
         truckNo, 
         destination,
         deliveryOfficer) = veggieSupplyChainStorage.getShippingData(shippingBatchNo);  
         
        return (shippingDateTime, quantity, driver, truckNo, destination, deliveryOfficer);
    }
    
    /* Perform consignment */
    function addConsignmentData(address shippingBatchNo,
                                string  orderNo,
                                string  goodsInfo,
                                uint8   quantity,
                                uint8   defectiveQuantity) public userRoleActionCheck(shippingBatchNo, 'Customer', 'CONSIGNMENT') returns(bool) {
                                                                  
        bool status = veggieSupplyChainStorage.setConsignmentData(shippingBatchNo,
                                                                  orderNo,
                                                                  goodsInfo,
                                                                  quantity,
                                                                  defectiveQuantity,
                                                                  msg.sender,
                                                                  now);
    
        emit DoneConsignment(msg.sender, shippingBatchNo, orderNo, goodsInfo, quantity, defectiveQuantity, now);
        return status;
    }
    
    function getConsignmentData(address shippingBatchNo) public view returns(uint256 arrivalDateTime,
                                                                             uint8   quantity,
                                                                             uint8   defectiveQuantity,
                                                                             string  orderNo,
                                                                             string  goodsInfo,
                                                                             address customer) {
        
        (arrivalDateTime,
         quantity,
         defectiveQuantity,
         orderNo,
         goodsInfo,
         customer) = veggieSupplyChainStorage.getConsignmentData(shippingBatchNo);  
        
        return (arrivalDateTime, quantity, defectiveQuantity, orderNo, goodsInfo, customer);
    }
}