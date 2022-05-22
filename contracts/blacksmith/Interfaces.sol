pragma ever-solidity ^0.59.5;

import 'Structs.sol';

interface IWeaponStorage {
    function addWeapon(Weapon weapon, address user) external;
}