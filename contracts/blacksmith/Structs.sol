pragma ever-solidity ^0.59.5;

// Enums
enum Rarity {
	common,
	rare,
	epic,
	legendary
}

// Structs
struct Weapon {
	uint128 id;
	Rarity rarity;
	string name;
	uint128 price;
}

struct User {
	Weapon[] weapons;
	uint balance;
}