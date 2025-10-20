// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract marketPlace {
    struct buyItemsDetails {
        uint id;
        uint quantity;
    }
    struct sellerBasic {
        string name;
        string description;
        string phoneNumber;
        string email;
    }
    struct itemsDetails {
        uint id;
        string name;
        string description;
        uint price;
        uint quantity;
    }
    mapping(address => sellerBasic) allSellers;
    mapping(address => itemsDetails[]) allItems;
    function addItemsBySeller(itemsDetails[] memory items) public {
        sellerBasic memory sellerInfo = allSellers[msg.sender];
        require(bytes(sellerInfo.name).length > 0, "Seller not found");
        require(items.length > 0, "Items missing");
        itemsDetails[] storage sellerItems = allItems[msg.sender];
        for (uint i = 0; i < items.length; i++) {
            items[i].id = sellerItems.length + 1;
            sellerItems.push(items[i]);
        }
    }
    function getSellerBasicInfo() public view returns (sellerBasic memory) {
        return allSellers[msg.sender];
    }
    function getSellerItems() public view returns (itemsDetails[] memory) {
        sellerBasic memory sellerInfo = allSellers[msg.sender];
        require(bytes(sellerInfo.name).length > 0, "Seller not found");
        return allItems[msg.sender];
    }
    function registerSeller(sellerBasic memory seller) public {
        require(bytes(seller.name).length > 0, "Seller name missing");
        require(
            bytes(seller.description).length > 0,
            "Seller description missing"
        );
        require(
            bytes(seller.phoneNumber).length > 0,
            "Seller phone number missing"
        );
        require(bytes(seller.email).length > 0, "Seller email missing");
        sellerBasic memory sellerInfo = allSellers[msg.sender];
        require(
            bytes(sellerInfo.name).length == 0,
            "Seller already registered"
        );
        allSellers[msg.sender] = seller;
    }
    function buyItemsByCustomer(
        address sellerAddress,
        buyItemsDetails[] memory items
    ) public payable {
         sellerBasic memory sellerInfo = allSellers[sellerAddress];
        require(bytes(sellerInfo.name).length > 0, "Seller not found");
        itemsDetails[] memory sellerItems = allItems[sellerAddress];
        require(sellerItems.length > 0, "No items found for this seller");
        uint totalItemsWorth;
        for (uint i = 0; i < items.length; i++) {
            bool itemFound = false;
            buyItemsDetails memory item = items[i];
            for (uint j = 0; j < sellerItems.length; j++) {
                itemsDetails memory sellerItemDetails = sellerItems[j];
                if (sellerItemDetails.id == item.id) {
                    itemFound = true;
                    break;
                }
                require(itemFound, "The Item with details ${id} not found");
                require(
                    sellerItemDetails.quantity > item.quantity,
                    "Out of stock"
                );
                sellerItemDetails.quantity -= item.quantity;
                totalItemsWorth = totalItemsWorth + sellerItemDetails.price * item.quantity;
            }
        }
        require(msg.value <= totalItemsWorth, "Insufficient funds");
        payable(sellerAddress).transfer(msg.value);
    }
}
