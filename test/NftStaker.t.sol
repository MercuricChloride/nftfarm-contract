// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NftStaker.sol";
import "../src/SimpleNft.sol";
import "../src/JYDFarm.sol";

contract NFTStakerTest is Test {
    NftStaker public staker;
    SimpleNft public nft;
    address public a = address(1); // should own 1,2,3
    address public b = address(2); // should own 4,5,6

    function setUp() public {
        nft = new SimpleNft("SIMPLE", "SMPL");
        staker = new NftStaker("NFT_STAKER", "NFTS", address(nft));
        //mint out nfts to a and b
        nft.mint(a, 1);
        nft.mint(a, 2);
        nft.mint(a, 3);
        nft.mint(b, 4);
        nft.mint(b, 5);
        nft.mint(b, 6);
    }

    function depositA() public {
        uint256[] memory _tokens = new uint256[](2);
        _tokens[0] = 1;
        _tokens[1] = 2;
        for (uint256 i; i < _tokens.length; i++) {
            // approve tokens
            vm.prank(a);
            nft.approve(address(staker), _tokens[i]);
        }
        //deposit
        vm.prank(a);
        staker.deposit(_tokens);
    }

    function depositAChecks() public {
        // check the balances are correct at start
        assertEq(nft.balanceOf(a), 3);
        assertEq(staker.balanceOf(a), 0);

        // check no owners of the token ids
        assertEq(staker.nftToOwner(1), address(0));
        assertEq(staker.nftToOwner(2), address(0));

        // run the deposit logic
        depositA();

        // check the nfts are held
        assertEq(nft.balanceOf(a), 1);

        // check the tokens minted
        assertEq(staker.balanceOf(a), 2);

        // check that owner is tracked
        assertEq(staker.nftToOwner(1), a);
        assertEq(staker.nftToOwner(2), a);
    }

    function depositAApproval() public {
        uint256[] memory _tokens = new uint256[](2);
        _tokens[0] = 1;
        _tokens[1] = 2;
        for (uint256 i; i < _tokens.length; i++) {
            // approve tokens
            vm.prank(a);
            nft.approve(address(staker), _tokens[i]);
        }
        //deposit
        vm.prank(a);
        staker.depositAndApprove(_tokens);
    }

    function depositAApprovalChecks() public {
        // check the balances are correct at start
        assertEq(nft.balanceOf(a), 3);
        assertEq(staker.balanceOf(a), 0);

        // check no owners of the token ids
        assertEq(staker.nftToOwner(1), address(0));
        assertEq(staker.nftToOwner(2), address(0));

        // run the deposit logic
        depositAApproval();

        // check the nfts are held
        assertEq(nft.balanceOf(a), 1);

        // check the tokens minted
        assertEq(staker.balanceOf(a), 2);

        // check that owner is tracked
        assertEq(staker.nftToOwner(1), a);
        assertEq(staker.nftToOwner(2), a);

        // check the allowance of the farm contract
        assertEq(staker.allowance(a, staker.FARM_ADDRESS()), 2);
    }

    function testDeposit() public {
        depositAChecks();
    }

    function shouldWithdraw() public {
        // create an array of tokenids
        uint256[] memory _tokens = new uint256[](2);
        _tokens[0] = 1;
        _tokens[1] = 2;
        // attempt to withdraw
        vm.prank(a);
        staker.withdraw(_tokens);
    }

    function shouldFailWithdraw() public {
        // create an array of tokenids
        uint256[] memory _tokens = new uint256[](2);
        _tokens[0] = 1;
        _tokens[1] = 2;
        // attempt to withdraw
        vm.prank(b);
        vm.expectRevert(bytes("withdraw(), not owner of token!"));
        staker.withdraw(_tokens);
    }

    function testWithdraw() public {
        // deposit like we were doing before
        depositAChecks();

        // should fail
        shouldFailWithdraw();

        // should work
        shouldWithdraw();

        // check that the owner of the tokenId was reset
        assertEq(staker.nftToOwner(1), address(0));
        assertEq(staker.nftToOwner(2), address(0));

        // check the new balance of the msg.sender
        assertEq(staker.balanceOf(a), 0);
    }

    function testDepositAndApprove() public {
        depositAApprovalChecks();
    }
}
