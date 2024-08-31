// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EtherStaking {
    struct Stake {
        uint256 amount;
        uint256 startTime;
    }

    mapping(address => Stake) public stakes;
    mapping(address => uint256) public rewards;
    uint256 public rewardRate;

    event Staked(address indexed user, uint256 amount, uint256 time);

    event Withdrawn(address indexed user, uint256 amount, uint256 reward);

    constructor() payable {
        rewardRate = msg.value;
    }

    function setRewardRate(uint256 _rewardRate) external {
        rewardRate = _rewardRate;
    }

    function stake(uint256 _startTime) external payable {
        require(msg.value > 0, "Cannot stake 0 Ether");

        Stake storage userStake = stakes[msg.sender];
        userStake.amount += msg.value;
        userStake.startTime = _startTime;

        emit Staked(msg.sender, msg.value, _startTime);
    }

    function calculateReward(address user) public view returns (uint256) {
        Stake storage userStake = stakes[user];
        uint256 stakingDuration = block.timestamp - userStake.startTime;
        uint256 reward = userStake.amount * stakingDuration;

        require(reward + userStake.amount > rewardRate, "Insufficient funds");

        return reward;
    }

    function withdraw() external {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No staked Ether");

        uint256 reward = calculateReward(msg.sender);
        uint256 totalAmount = userStake.amount + reward;

        require(
            address(this).balance >= totalAmount,
            "Insufficient contract balance"
        );

        userStake.amount = 0;
        userStake.startTime = 0;

        payable(msg.sender).transfer(totalAmount);

        emit Withdrawn(msg.sender, userStake.amount, reward);
    }

    receive() external payable {}
}
