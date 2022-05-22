pragma ton-solidity >= 0.59.5;

import 'Structs.sol';
import 'Interfaces.sol';

contract WeaponStorage is IWeaponStorage {
    // Error codes
	uint256 constant ERROR_SENDER_IS_NOT_OWNER = 101;

    mapping (address=>Weapon[]) public weapons;

    constructor() public {
        require(msg.pubkey() == tvm.pubkey(), ERROR_SENDER_IS_NOT_OWNER);
		tvm.accept();
    }

    function addWeapon(Weapon weapon, address user) external override {
        weapons[user].push(weapon);
    }

    function getMyWeapons(address user) view public returns (Weapon[]) {
        Weapon[] myWeapons = weapons[user];

        return myWeapons;
    }
}