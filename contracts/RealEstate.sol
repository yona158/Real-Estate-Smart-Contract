// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RealEstate {
    struct Property {
        uint256 id;
        string location;
        uint256 price;
        address owner;
        bool isForSale;
        bool isbooked;
        bool exists;
    }

    address public government;
    address public ministryOfFinance;
    uint256 public constant TAX_PERCENTAGE = 2; // 2% tax

    mapping(uint256 => Property) public properties;
    mapping(address => uint256[]) public userProperties;
    mapping(uint256 => address) public propertyToBuyer;
    mapping(address => bool) public registeredUsers;
    mapping(address => bytes32) public userHashedNationalId; // Store hashed national ID

    uint256 public totalProperties; // Total number of properties
    uint256 public totalPropertiesForSale; // Total number of properties listed for sale
    uint256 public totalPropertiesBooked; // Total number of properties booked
    uint256 public users; // Total number of users

    event PropertyRegistered(uint256 id, string location, uint256 price, address owner);
    event PropertyForSale(uint256 id, bool isForSale);
    event PropertyPriceChanged(uint256 id, uint256 newPrice);
    event PropertySold(uint256 id, address buyer, uint256 price);
    event SaleApproved(uint256 id, address buyer);
    event SaleRejected(uint256 id, address buyer);

    modifier onlyGovernment() {
        require(msg.sender == government, "Only government can call this function");
        _;
    }

    modifier onlyPropertyOwner(uint256 id) {
        require(properties[id].owner == msg.sender, "Only property owner can call this function");
        _;
    }

    // modifier onlyOwner(address owner) {
    //     require(owner == msg.sender, "Only property owner can call this function");
    //     _;
    // }

    modifier onlyRegisteredUser() {
        require(registeredUsers[msg.sender], "User is not registered");
        _;
    }

    constructor(address _ministryOfFinance) {
        government = msg.sender;
        ministryOfFinance = _ministryOfFinance;
    }

    // Register a user with hashed national ID
    function registerUser(address user, uint256 nationalId) public onlyGovernment {
        // Convert the integer to bytes
        bytes memory nationalIdBytes = abi.encodePacked(nationalId);        
        bytes32 hashedNationalId = keccak256(nationalIdBytes); // Hash the national ID
        registeredUsers[user] = true;
        userHashedNationalId[user] = hashedNationalId;
        users++;
    }

    // Register a new property
    function registerProperty(uint256 id, address owner, string memory location, uint256 price) public onlyGovernment {
        require(!properties[id].exists, "Property already exists");
        properties[id] = Property(id, location, price, owner, false,false, true);
        userProperties[owner].push(id);
        totalProperties++; // Increase total number of properties
        emit PropertyRegistered(id, location, price, owner);
    }

    // List a property for sale or cancel the listing
    function listPropertyForSale(uint256 id, bool isForSale) public onlyPropertyOwner(id) {
        if (isForSale && !properties[id].isForSale) {
            totalPropertiesForSale++; // Increase number of properties listed for sale
        } else if (!isForSale && properties[id].isForSale) {
            totalPropertiesForSale--; // Decrease number of properties listed for sale
        }
        properties[id].isForSale = isForSale;
        emit PropertyForSale(id, isForSale);
    }

    // Change the price of a property
    function changePropertyPrice(uint256 id, uint256 newPrice) public onlyPropertyOwner(id) {
        properties[id].price = newPrice;
        emit PropertyPriceChanged(id, newPrice);
    }

    // Buy a property (requires government approval)
    function buyProperty(uint256 id) public payable onlyRegisteredUser {
        require(properties[id].isForSale, "Property is not for sale");
        require(properties[id].owner != msg.sender, "Cannot buy your own property");
        require(msg.value >= properties[id].price, "Incorrect payment amount");

        // Refund excess Ether
        if (msg.value > properties[id].price) {
            uint256 excessAmount = msg.value - properties[id].price;
            payable(msg.sender).transfer(excessAmount);
        }

        propertyToBuyer[id] = msg.sender;

        // Remove the property from the list of properties for sale
        properties[id].isForSale = false;
        properties[id].isbooked = true;
        totalPropertiesForSale--;
        // totalPropertiesBooked++;


        emit PropertySold(id, msg.sender, properties[id].price);
    }

    // Government approves the sale
    function approveSale(uint256 id) public onlyGovernment {
        address buyer = propertyToBuyer[id];
        require(buyer != address(0), "No buyer for this property");
        uint256 price = properties[id].price;
        uint256 tax = (price * TAX_PERCENTAGE) / 100;
        uint256 netAmount = price - tax;

        // Transfer tax to the government
        payable(ministryOfFinance).transfer(tax);

        // Transfer net amount to the property owner
        payable(properties[id].owner).transfer(netAmount);

        // Update property ownership
        properties[id].owner = buyer;
        properties[id].isbooked = false;
        propertyToBuyer[id] = address(0);

        emit SaleApproved(id, buyer);
    }

    // Government rejects the sale
    function rejectSale(uint256 id) public onlyGovernment {
        address buyer = propertyToBuyer[id];
        require(buyer != address(0), "No buyer for this property");

        // Re-add the property to the list of properties for sale
        properties[id].isForSale = true;
        properties[id].isbooked = false;
        totalPropertiesForSale++;

        // Refund the buyer
        payable(buyer).transfer(properties[id].price);

        // Reset the buyer for this property
        propertyToBuyer[id] = address(0);

        emit SaleRejected(id, buyer);
    }

    // Get properties owned by a specific user
    function getPropertiesByOwner() public view returns (uint256[] memory) {
        return userProperties[msg.sender];
    }

    // Get details of a specific property
    function getPropertyDetails(uint256 id) public view returns (Property memory) {
        Property memory property = properties[id];
        require(property.exists, "Property does not exist");
        return property;
    }

    // Get all properties listed for sale
    function getAllPropertiesForSale() public view returns (Property[] memory) {
        Property[] memory forSale = new Property[](totalPropertiesForSale);
        uint256 index = 0;
        for (uint256 i = 0; i < totalProperties; i++) {
            if (properties[i].exists && properties[i].isForSale) {
                forSale[index] = properties[i];
                index++;
            }
        }
        return forSale;
    }
}