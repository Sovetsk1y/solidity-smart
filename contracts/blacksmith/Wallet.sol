pragma ton-solidity >= 0.59.5;

import 'Structs.sol';
import 'Shop.sol';

contract Wallet {
    // Error codes
	uint256 constant ERROR_SENDER_IS_NOT_OWNER = 101;

    // Variables

    constructor() public {
        require(msg.pubkey() == tvm.pubkey(), ERROR_SENDER_IS_NOT_OWNER);
		tvm.accept();
    }

    function buyWeapon(uint8 rarity, uint128 amount, address shop) view public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();

        Shop(shop).buyWeapon{value: amount, bounce: true, flag: 64}(rarity);
    }
}