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

    //mapping from address -> uint256[] of tokenIds
    mapping(address => uint256[]) public ownerToNfts;

    // deposit event
    // _staker: msg.sender
    // _ids: tokenIds deposited
    event Deposit(address _staker, uint256[] _ids);

    // withdraw event
    // _staker: msg.sender
    // _ids: tokenIds removed
    event Withdraw(address _staker, uint256[] _ids);

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

            //push the token id to the owner's array
            ownerToNfts[msg.sender].push(_tokenIds[i]);
        }
        // mint tokens to the user
        _mint(msg.sender, _tokenIds.length);

        // emit a deposit event
        emit Deposit(msg.sender, _tokenIds);
    }

    //withdraw function
    function withdraw(uint256 _count) public nonReentrant {
        require(
            ownerToNfts[msg.sender].length <= _count,
            "withdraw(), msg.sender does not have enough deposited tokens!"
        );
        for (uint256 i; i < _count; i++) {
            // grab the last deposited token
            uint256 length = ownerToNfts[msg.sender].length;
            uint256 tokenId = ownerToNfts[msg.sender][length - 1];

            // update the tokenId owner to address(0) again
            nftToOwner[tokenId] = address(0);

            // transfer the nft back to the user
            IERC721(STAKING_NFT).transferFrom(
                address(this),
                msg.sender,
                tokenId
            );

            // remove the token id from the owner's array
            ownerToNfts[msg.sender].pop();
        }
        // mint tokens to the user
        _burn(msg.sender, _count);
    }

    //deposit and approve function
    function depositAndApprove(uint256[] memory _tokenIds) public {
        //mint tokens for each nft
        deposit(_tokenIds);
        //approve tokens for deposit
        _approve(msg.sender, FARM_ADDRESS, _tokenIds.length);
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
