// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Staking is Ownable {
    IERC20 public stakingToken;

    uint256 public rewardRate;

    uint256 public totalStaked;

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 reward;
    }

    mapping(address => Stake) public stakes;
    mapping(address => uint256) public rewards;

    event Staked(address indexed user, uint256 amount, uint256 startTime);
    event Withdrawn(address indexed user, uint256 amount, uint256 reward);

    constructor(address _stakingToken, uint256 _rewardRate)
        Ownable(msg.sender)
    {
        stakingToken = IERC20(_stakingToken);
        rewardRate = _rewardRate;
    }

    function setRewardRate(uint256 _rewardRate) external onlyOwner {
        rewardRate = _rewardRate;
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "Cannot stake 0 tokens");

        require(
            stakingToken.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );

        Stake storage userStake = stakes[msg.sender];
        userStake.amount += _amount;
        userStake.startTime = block.timestamp;

        totalStaked += _amount;

        emit Staked(msg.sender, _amount, block.timestamp);
    }

    function calculateReward(address user) public view returns (uint256) {
        Stake storage userStake = stakes[user];

        uint256 stakingDuration = block.timestamp - userStake.startTime;
        uint256 reward = (userStake.amount * stakingDuration * rewardRate) / 1e18;

        return reward;
    }

    function withdraw() external {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No staked tokens");

        uint256 reward = calculateReward(msg.sender);
        uint256 totalAmount = userStake.amount + reward;

        totalStaked -= userStake.amount;
        userStake.amount = 0;
        userStake.startTime = 0;

        require(
            stakingToken.transfer(msg.sender, totalAmount),
            "Transfer failed"
        );

        emit Withdrawn(msg.sender, userStake.amount, reward);
    }
}
