// SPDX-License-Identifier: GPLv3
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IJYDFarm {
    function deposit(uint256 _pid, uint256 _amount) external;
}

contract NftStaker is ERC20, Ownable, ReentrancyGuard {
    // mapping from tokenId -> address
    mapping(uint256 => address) public nftToOwner;

    // address of the farm
    // prettier-ignore
    address public constant FARM_ADDRESS = 0x6F49bF04668b28f8e66B9E860D8303b6687f0cA0;
    // address of the staking nft
    address public STAKING_NFT;

    // prettier-ignore
    constructor(string memory _name, string memory _symbol, address _staking ) ERC20(_name, _symbol) {
        STAKING_NFT = _staking;
    }

    function decimals() public view override returns (uint8) {
        return 1;
    }

    //deposit function
    function deposit(uint256[] memory _tokenIds) public nonReentrant {
        // check that all of the tokenIds are owned by the msg.sender, and that nobody has claimed these tokens already
        for (uint256 i; i < _tokenIds.length; i++) {
            require(
                IERC721(STAKING_NFT).ownerOf(_tokenIds[i]) == msg.sender,
                "deposit(), msg.sender not owner of token!"
            );
            require(
                nftToOwner[_tokenIds[i]] == address(0),
                "deposit(), Someone already owns this token!"
            );
            // transfer the nft
            IERC721(STAKING_NFT).transferFrom(
                msg.sender,
                address(this),
                _tokenIds[i]
            );

            // update the tokenId owner to msg.sender
            nftToOwner[_tokenIds[i]] = msg.sender;
        }
        // mint tokens to the user
        _mint(msg.sender, _tokenIds.length);
    }

    //withdraw function
    function withdraw(uint256[] memory _tokenIds) public nonReentrant {
        // check that nftToOwner for all the tokenIds is equal to msg.sender
        for (uint256 i; i < _tokenIds.length; i++) {
            require(
                nftToOwner[_tokenIds[i]] == msg.sender,
                "withdraw(), not owner of token!"
            );
            // update the tokenId owner to address(0) again
            nftToOwner[_tokenIds[i]] = address(0);
        }
        // mint tokens to the user
        _burn(msg.sender, _tokenIds.length);
    }

    //deposit and approve function
    function depositAndApprove(uint256[] memory _tokenIds) public {
        //mint tokens for each nft
        deposit(_tokenIds);
        //approve tokens for deposit
        _approve(msg.sender, FARM_ADDRESS, _tokenIds.length);
    }

    //mint and stake function
    // function mintAndStake(uint256[] memory _tokenIds, uint256 _pid) public {
    //     //mint tokens for each nft
    //     deposit(_tokenIds);
    //     //approve tokens for deposit
    //     _approve(msg.sender, FARM_ADDRESS, _tokenIds.length);
    //     //call the deposit function on the farm
    //     IJYDFarm(FARM_ADDRESS).deposit(_pid, _tokenIds.length);
    // }

    // override transfer function for the safety rails
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        // do something
    }

    // admin tokenMint function
    // for restoring tokens for initial token losses.
    // not a risk because of how we are tracking the owners of each token
    function adminTokenMint(address _recipient, uint256 _amount)
        public
        onlyOwner
    {
        _mint(_recipient, _amount);
    }
}
