pragma ton-solidity >=0.59.5;

// Test addresses
// 0:ece57bcc6c530283becbbd8a3b24d3c5987cdddc3c8b7b33be6e4a6312490415
// 0:b5e9240fc2d2f1ff8cbb1d1dee7fb7cae155e5f6320e585fcc685698994a19a5

contract VestingDistribution {
	// Error codes
	uint256 constant ERROR_SENDER_IS_NOT_OWNER = 101;
	uint256 constant ERROR_LOW_BALANCE = 102;

    // Distribution types
    uint256 constant DISTRIBUTION_TYPE_EQUAL = 0;
    uint256 constant DISTRIBUTION_TYPE_EXPONENTIAL = 1;

    // Variables
    uint128     m_vestingAmount;
    uint8       m_distributionType;         // 0 - equal, 1 - exponential
    address[]   m_users;
    uint32      m_period;
    uint32      m_lastVestingTimestamp;
    uint32      m_timestamp;

	constructor(uint128 sum, address[] users, uint8 distributionType, uint32 period) public {
		require(msg.pubkey() == tvm.pubkey(), ERROR_SENDER_IS_NOT_OWNER);
        require(address(this).balance > sum, ERROR_LOW_BALANCE);
		tvm.accept();

		m_vestingAmount         = sum;
        m_distributionType      = distributionType;
        m_users                 = users;
        m_period                = period;
        m_lastVestingTimestamp  = now;
	}

	modifier onlyOwner() {
		require(msg.pubkey() == tvm.pubkey(), ERROR_SENDER_IS_NOT_OWNER);
		tvm.accept();
		_;
	}

    function stopVesting(address user) public onlyOwner {
        calculateVesting();
        address[] newUsers;
        for (uint i = 0; i < m_users.length; i++) {
            if (m_users[i] != user) {
                newUsers.push(m_users[i]);
            }
        }
        m_users = newUsers;
    }

    function distributeVesting(uint128 vesting) private {
        for (uint i = 0; i < m_users.length; i++) {
            address user = m_users[i];
            user.transfer(vesting, true, 0);
        }
        m_lastVestingTimestamp = now;
    }

    function calculateVesting() public {
        if (m_distributionType == DISTRIBUTION_TYPE_EQUAL) {
            calculateVestingEqual();
        }
    }

    function calculateVestingEqual() public onlyOwner {
        uint128 maxAlloc = m_vestingAmount / uint128(m_users.length);
        uint128 vestingPerSecond = maxAlloc / m_period;
        uint128 currentVesting = (now - m_lastVestingTimestamp) * vestingPerSecond;
        distributeVesting(currentVesting);
    }

    function getCurrentAmount() public view returns (uint128) {
        return m_vestingAmount;
    }

    /*function getCurrentVestingInfo() public {
        
    }*/
}
