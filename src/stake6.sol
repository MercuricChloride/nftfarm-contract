// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface TokenPool {
        function distributePool(address) external;
}

contract StakeNFT {

    //State variabble
    TokenPool poolAddress;
    address nftStakingAddress;

    //constructor
    constructor() {}

    //enumerator
    enum StakingStatus {Active, Claimable, Claimed, Cancelled}

    //structs
    struct Staking {
        address staker;    
        address token;
        uint tokenId;
        uint releaseTime;
        StakingStatus status;
    }

    struct UserInfo {
      uint256[] stakedTokens;
    }


    //mapping
    mapping(uint => Staking) private _StakedItem;
    // maps address for token id's per user
    mapping(address => UserInfo) user;
    // maps tokenId to stake for a wallet address

    //event
    event tokenStaked(address indexed staker, address indexed token, uint token_id, StakingStatus status);
    event tokenClaimStatus(address indexed token, uint indexed token_id, StakingStatus indexed status);
    event tokenCancelComplete(address indexed token, uint indexed token_id, StakingStatus indexed status);

    //function to call another function
    function callStakeToken(address token, uint _tokenID) public {
        require(token == 0xDfe3AC769b2d8E382cB86143E0b0B497E1ED5447, "incorrect NFT to stake"); // hardcode the NFT smart contract to allow only specific NFT into staking, assume 0xd2...d005 as NFT contract address
        _stakeToken(token, _tokenID);
    }

    function multiStakeToken(address token, uint[] calldata _tokenIds) public {
        require(token == 0xDfe3AC769b2d8E382cB86143E0b0B497E1ED5447, "incorrect NFT to stake"); // hardcode the NFT smart contract to allow only specific NFT into staking, assume 0xd2...d005 as NFT contract address
        for (uint i = 0; i < _tokenIds.length; i++) {
            _stakeToken(token, _tokenIds[i]);
        }
    }

    //function to transfer NFT from user to contract
    function _stakeToken(address token, uint tokenId) private returns(Staking memory) {
        IERC721(token).transferFrom(msg.sender, address(this), tokenId); // User must approve() this contract address via the NFT ERC721 contract before NFT can be transfered
        uint256 numberOfMinutes = 5; //hardcoded as 5 minutes
        uint releaseTime = block.timestamp + (numberOfMinutes * 1 minutes);

        Staking memory staking = Staking(msg.sender, token, tokenId, releaseTime, StakingStatus.Active);
        

        _StakedItem[tokenId] = staking;

        emit tokenStaked(msg.sender, staking.token, staking.tokenId, staking.status);
        user[msg.sender].stakedTokens.push(tokenId);
        return _StakedItem[tokenId];
    }

    //function to view staked NFT
    function viewStake(uint tokenId) public view returns (Staking memory) {
        return _StakedItem[tokenId];
    }

    //function to check NFT stake duration status 
    function checkStake(uint tokenId, address staker) public returns (Staking memory) {
        Staking storage staking = _StakedItem[tokenId];
        
        require(staker == msg.sender, "You cannot check this staking as it is not listed under this address");
        require(staking.status == StakingStatus.Active, "Staking is not active or claimed");
        if (block.timestamp >= staking.releaseTime) {
            staking.status = StakingStatus.Claimable;
        }

        emit tokenClaimStatus(staking.token, staking.tokenId, staking.status);
        return _StakedItem[tokenId];
    }

    //function to cancel NFT stake
    function cancelStake(uint tokenId) private {
        Staking storage staking = _StakedItem[tokenId];
        require(staking.staker == msg.sender, "You cannot cancel this staking as it is not listed under this address");
        require(staking.status == StakingStatus.Active, "Staking is either not active (Cancelled or in claiming process)");
        
        staking.status = StakingStatus.Cancelled;
        IERC721(staking.token).transferFrom(address(this), msg.sender, staking.tokenId);

        emit tokenCancelComplete(staking.token, staking.tokenId, staking.status);

        delete _StakedItem[tokenId];
        deleteStakedToken(msg.sender, tokenId);
    }

    function cancelMultiStakes(uint[] calldata tokenIds) public {
        for (uint i = 0; i < tokenIds.length; i++) {
            cancelStake(tokenIds[i]);
        }
    }

    function getStakedTokens(address _wallet) public view returns (uint256[] memory) {
      return user[_wallet].stakedTokens;
  }

    function deleteStakedToken(address _user, uint256 _tokenId) private {
    for (uint256 index = 0; index < user[_user].stakedTokens.length; index++) {
        if(user[_user].stakedTokens[index] == _tokenId) {
                deleteStakedTokenFromUserByIndex(index);
        }
    }
  }
  /** * Deletes the token id based on the index value of the struct array */ 
  function deleteStakedTokenFromUserByIndex(uint _index) private returns(bool) { 
      for (uint i = _index; i < user[msg.sender].stakedTokens.length - 1; i++) { 
          user[msg.sender].stakedTokens[i] = user[msg.sender].stakedTokens[i + 1]; 
      } 
      user[msg.sender].stakedTokens.pop(); 
      return true; 
    }
}