//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "./ItemManager.sol";

contract Item {
    uint public priceInWei;
    uint public pricePaid;
    uint public index;

    ItemManager parentContact;

    constructor(ItemManager _parentContact, uint _priceInWei, uint _index) {
        priceInWei=_priceInWei;
        index=_index;
        parentContact = _parentContact;
    }

    receive() external payable {
        require(msg.value == priceInWei, "We don't support partial payments");
        require(pricePaid == 0, "Item is already paid!");
        pricePaid += msg.value;
        (bool success, ) = address(parentContact).call{value:msg.value}(abi.encodeWithSignature("triggerPayment(uint256)", index));
        require(success, "Delivery did not work");
    }
    fallback() external payable{
  
    }
}
