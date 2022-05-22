pragma ton-solidity >=0.59.5;

import "Structs.sol";
import "Interfaces.sol";

contract Shop {
	// Error codes
	uint256 constant ERROR_SENDER_IS_NOT_OWNER = 101;
	uint256 constant ERROR_LOW_BALANCE = 102;
	uint256 constant WEAPONS_ALREADY_INITED = 103;
	uint256 constant INVALID_RARITY_ID = 104;
	uint256 constant EMPTY_WEAPONS = 105;

	// Consts
	uint32 constant COMMON_WEAPON_COUNT = 500;
	uint32 constant RARE_WEAPON_COUNT = 300;
	uint32 constant EPIC_WEAPON_COUNT = 150;
	uint32 constant LEGENDARY_WEAPON_COUNT = 50;

	// Modifiers
	modifier onlyOwnerAndAccept() {
		require(msg.pubkey() == tvm.pubkey(), ERROR_SENDER_IS_NOT_OWNER);
		tvm.accept();
		_;
	}

	modifier possibleRarity(uint8 id) {
		require(id >= 0 && id < 4, INVALID_RARITY_ID);
		_;
	}

	// Variables
	uint8 initialized = 0;

	IWeaponStorage private weaponStorage;

	// Associates rarity with weapons remaining count
	mapping(Rarity => uint256) private weapons;

	// Don't touch it!!!
	uint128 private idGenerator = 0;

	constructor(address storageAddress) public {
		require(msg.pubkey() == tvm.pubkey(), ERROR_SENDER_IS_NOT_OWNER);
		tvm.accept();

		weaponStorage = IWeaponStorage(storageAddress);
	}

	function getRemainingWeaponsCount() public view returns (string) {
		string str = format('Commons in-stock: {} Rares in-stock: {} Epics in-stock: {} Legendaries in-stock: {}',
			weapons[Rarity.common],
			weapons[Rarity.rare],
			weapons[Rarity.epic],
			weapons[Rarity.legendary]
		);
        return str;
	}

	function setWeaponStorage(address storageAddress)
		public
		onlyOwnerAndAccept
	{
		weaponStorage = IWeaponStorage(storageAddress);
	}

	function withdraw(address recipient, uint128 amount)
		public
		pure
		onlyOwnerAndAccept
	{
		require(amount < address(this).balance, ERROR_LOW_BALANCE);

		recipient.transfer(amount, true, 1);
	}

	function buyWeapon(uint8 rarityId) public possibleRarity(rarityId) {
		Rarity rarity = getRarityFrom(rarityId);
		require(weapons[rarity] > 0, EMPTY_WEAPONS);

		Weapon weapon = getNewWeapon(rarity);
		require(address(this).balance > weapon.price, ERROR_LOW_BALANCE);
		weaponStorage.addWeapon(weapon, msg.sender);
	}

	function getRarityFrom(uint8 id) private pure returns (Rarity) {
		if (id == uint8(Rarity.common)) return Rarity.common;
		if (id == uint8(Rarity.rare)) return Rarity.rare;
		if (id == uint256(Rarity.epic)) return Rarity.epic;
		if (id == uint256(Rarity.legendary)) return Rarity.legendary;
	}

	function getNewWeapon(Rarity rarity) private returns (Weapon) {
		require(weapons[rarity] > 0, EMPTY_WEAPONS);

		uint128 id = getNewId();
		string name;
		uint128 price;

		if (rarity == Rarity.common) {
			name = format("AXE #{}", id);
			price = 3000000000;
		}
		if (rarity == Rarity.rare) {
			name = format("SWORD #{}", id);
			price = 10000000000;
		}
		if (rarity == Rarity.epic) {
			name = format("BOW #{}", id);
			price = 80000000000;
		}
		if (rarity == Rarity.legendary) {
			name = format("SCYTHE #{}", id);
			price = 300000000000;
		}
		weapons[rarity] = weapons[rarity] - 1;

		Weapon weapon = Weapon(id, rarity, name, price);
		return weapon;
	}

	function initializeWeapons() public {
		require(initialized == 0, WEAPONS_ALREADY_INITED);
        tvm.accept();
		weapons[Rarity.common] = COMMON_WEAPON_COUNT;
		weapons[Rarity.rare] = RARE_WEAPON_COUNT;
		weapons[Rarity.epic] = EPIC_WEAPON_COUNT;
		weapons[Rarity.legendary] = LEGENDARY_WEAPON_COUNT;
		initialized = 1;
	}

	function getNewId() private returns (uint128) {
		uint128 _id = idGenerator;
		idGenerator++;
		return _id;
	}
}
