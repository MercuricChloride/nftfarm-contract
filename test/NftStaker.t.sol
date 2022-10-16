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
        vm.prank(a);
        staker.withdraw(2);
    }

    function shouldFailWithdraw() public {
        // attempt to withdraw
        vm.prank(b);
        vm.expectRevert();
        staker.withdraw(2);
    }

    function testWithdraw() public {
        // check the balances are correct at start
        assertEq(nft.balanceOf(a), 3);

        // run the deposit logic
        depositA();

        // check the nfts are held
        assertEq(nft.balanceOf(a), 1);
        assertEq(nft.balanceOf(address(staker)), 2);

        // check the tokens minted
        assertEq(staker.balanceOf(a), 2);

        // check that owner is tracked
        assertEq(staker.nftToOwner(1), a);
        assertEq(staker.nftToOwner(2), a);

        //run the failing withdraw
        shouldFailWithdraw();

        // run the withdraw logic
        shouldWithdraw();

        // check the nfts are held
        assertEq(nft.balanceOf(a), 3);
        assertEq(nft.balanceOf(address(staker)), 0);

        // check the tokens burned
        assertEq(staker.balanceOf(a), 0);
    }

    function testDepositAndApprove() public {
        depositAApprovalChecks();
    }

    function testAdminMinting() public {
        // check the owner
        assertEq(staker.owner(), address(this));

        // deposit tokens as account A
        depositA();

        // send those tokens somewhere else
        vm.prank(a);
        staker.transfer(address(3), 2);

        // assert balance is 0
        assertEq(staker.balanceOf(a), 0);

        // expect withdraw to fail
        uint256[] memory _tokenIds = new uint256[](2);
        _tokenIds[0] = 1;
        _tokenIds[1] = 2;
        vm.prank(a);
        vm.expectRevert(bytes("ERC20: burn amount exceeds balance"));
        staker.withdraw(2);

        // minting tokens should fail if the caller is not the owner
        vm.prank(address(69));
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        staker.adminTokenMint(a, 69);

        // mint tokens to a
        staker.adminTokenMint(a, 2);

        // check the new balance
        assertEq(staker.balanceOf(a), 2);

        // expect withdraw to succeed
        vm.prank(a);
        staker.withdraw(2);
    }
}
