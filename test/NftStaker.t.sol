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
        mint250();
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

    function mint250() public {
        nft.mint(a, 7);
        nft.mint(a, 8);
        nft.mint(a, 9);
        nft.mint(a, 10);
        nft.mint(a, 11);
        nft.mint(a, 12);
        nft.mint(a, 13);
        nft.mint(a, 14);
        nft.mint(a, 15);
        nft.mint(a, 16);
        nft.mint(a, 17);
        nft.mint(a, 18);
        nft.mint(a, 19);
        nft.mint(a, 20);
        nft.mint(a, 21);
        nft.mint(a, 22);
        nft.mint(a, 23);
        nft.mint(a, 24);
        nft.mint(a, 25);
        nft.mint(a, 26);
        nft.mint(a, 27);
        nft.mint(a, 28);
        nft.mint(a, 29);
        nft.mint(a, 30);
        nft.mint(a, 31);
        nft.mint(a, 32);
        nft.mint(a, 33);
        nft.mint(a, 34);
        nft.mint(a, 35);
        nft.mint(a, 36);
        nft.mint(a, 37);
        nft.mint(a, 38);
        nft.mint(a, 39);
        nft.mint(a, 40);
        nft.mint(a, 41);
        nft.mint(a, 42);
        nft.mint(a, 43);
        nft.mint(a, 44);
        nft.mint(a, 45);
        nft.mint(a, 46);
        nft.mint(a, 47);
        nft.mint(a, 48);
        nft.mint(a, 49);
        nft.mint(a, 50);
        nft.mint(a, 51);
        nft.mint(a, 52);
        nft.mint(a, 53);
        nft.mint(a, 54);
        nft.mint(a, 55);
        nft.mint(a, 56);
        nft.mint(a, 57);
        nft.mint(a, 58);
        nft.mint(a, 59);
        nft.mint(a, 60);
        nft.mint(a, 61);
        nft.mint(a, 62);
        nft.mint(a, 63);
        nft.mint(a, 64);
        nft.mint(a, 65);
        nft.mint(a, 66);
        nft.mint(a, 67);
        nft.mint(a, 68);
        nft.mint(a, 69);
        nft.mint(a, 70);
        nft.mint(a, 71);
        nft.mint(a, 72);
        nft.mint(a, 73);
        nft.mint(a, 74);
        nft.mint(a, 75);
        nft.mint(a, 76);
        nft.mint(a, 77);
        nft.mint(a, 78);
        nft.mint(a, 79);
        nft.mint(a, 80);
        nft.mint(a, 81);
        nft.mint(a, 82);
        nft.mint(a, 83);
        nft.mint(a, 84);
        nft.mint(a, 85);
        nft.mint(a, 86);
        nft.mint(a, 87);
        nft.mint(a, 88);
        nft.mint(a, 89);
        nft.mint(a, 90);
        nft.mint(a, 91);
        nft.mint(a, 92);
        nft.mint(a, 93);
        nft.mint(a, 94);
        nft.mint(a, 95);
        nft.mint(a, 96);
        nft.mint(a, 97);
        nft.mint(a, 98);
        nft.mint(a, 99);
        nft.mint(a, 100);
        nft.mint(a, 101);
        nft.mint(a, 102);
        nft.mint(a, 103);
        nft.mint(a, 104);
        nft.mint(a, 105);
        nft.mint(a, 106);
        nft.mint(a, 107);
        nft.mint(a, 108);
        nft.mint(a, 109);
        nft.mint(a, 110);
        nft.mint(a, 111);
        nft.mint(a, 112);
        nft.mint(a, 113);
        nft.mint(a, 114);
        nft.mint(a, 115);
        nft.mint(a, 116);
        nft.mint(a, 117);
        nft.mint(a, 118);
        nft.mint(a, 119);
        nft.mint(a, 120);
        nft.mint(a, 121);
        nft.mint(a, 122);
        nft.mint(a, 123);
        nft.mint(a, 124);
        nft.mint(a, 125);
        nft.mint(a, 126);
        nft.mint(a, 127);
        nft.mint(a, 128);
        nft.mint(a, 129);
        nft.mint(a, 130);
        nft.mint(a, 131);
        nft.mint(a, 132);
        nft.mint(a, 133);
        nft.mint(a, 134);
        nft.mint(a, 135);
        nft.mint(a, 136);
        nft.mint(a, 137);
        nft.mint(a, 138);
        nft.mint(a, 139);
        nft.mint(a, 140);
        nft.mint(a, 141);
        nft.mint(a, 142);
        nft.mint(a, 143);
        nft.mint(a, 144);
        nft.mint(a, 145);
        nft.mint(a, 146);
        nft.mint(a, 147);
        nft.mint(a, 148);
        nft.mint(a, 149);
        nft.mint(a, 150);
        nft.mint(a, 151);
        nft.mint(a, 152);
        nft.mint(a, 153);
        nft.mint(a, 154);
        nft.mint(a, 155);
        nft.mint(a, 156);
        nft.mint(a, 157);
        nft.mint(a, 158);
        nft.mint(a, 159);
        nft.mint(a, 160);
        nft.mint(a, 161);
        nft.mint(a, 162);
        nft.mint(a, 163);
        nft.mint(a, 164);
        nft.mint(a, 165);
        nft.mint(a, 166);
        nft.mint(a, 167);
        nft.mint(a, 168);
        nft.mint(a, 169);
        nft.mint(a, 170);
        nft.mint(a, 171);
        nft.mint(a, 172);
        nft.mint(a, 173);
        nft.mint(a, 174);
        nft.mint(a, 175);
        nft.mint(a, 176);
        nft.mint(a, 177);
        nft.mint(a, 178);
        nft.mint(a, 179);
        nft.mint(a, 180);
        nft.mint(a, 181);
        nft.mint(a, 182);
        nft.mint(a, 183);
        nft.mint(a, 184);
        nft.mint(a, 185);
        nft.mint(a, 186);
        nft.mint(a, 187);
        nft.mint(a, 188);
        nft.mint(a, 189);
        nft.mint(a, 190);
        nft.mint(a, 191);
        nft.mint(a, 192);
        nft.mint(a, 193);
        nft.mint(a, 194);
        nft.mint(a, 195);
        nft.mint(a, 196);
        nft.mint(a, 197);
        nft.mint(a, 198);
        nft.mint(a, 199);
        nft.mint(a, 200);
        nft.mint(a, 201);
        nft.mint(a, 202);
        nft.mint(a, 203);
        nft.mint(a, 204);
        nft.mint(a, 205);
        nft.mint(a, 206);
        nft.mint(a, 207);
        nft.mint(a, 208);
        nft.mint(a, 209);
        nft.mint(a, 210);
        nft.mint(a, 211);
        nft.mint(a, 212);
        nft.mint(a, 213);
        nft.mint(a, 214);
        nft.mint(a, 215);
        nft.mint(a, 216);
        nft.mint(a, 217);
        nft.mint(a, 218);
        nft.mint(a, 219);
        nft.mint(a, 220);
        nft.mint(a, 221);
        nft.mint(a, 222);
        nft.mint(a, 223);
        nft.mint(a, 224);
        nft.mint(a, 225);
        nft.mint(a, 226);
        nft.mint(a, 227);
        nft.mint(a, 228);
        nft.mint(a, 229);
        nft.mint(a, 230);
        nft.mint(a, 231);
        nft.mint(a, 232);
        nft.mint(a, 233);
        nft.mint(a, 234);
        nft.mint(a, 235);
        nft.mint(a, 236);
        nft.mint(a, 237);
        nft.mint(a, 238);
        nft.mint(a, 239);
        nft.mint(a, 240);
        nft.mint(a, 241);
        nft.mint(a, 242);
        nft.mint(a, 243);
        nft.mint(a, 244);
        nft.mint(a, 245);
        nft.mint(a, 246);
        nft.mint(a, 247);
        nft.mint(a, 248);
        nft.mint(a, 249);
        nft.mint(a, 250);
        nft.mint(a, 251);
        nft.mint(a, 252);
        nft.mint(a, 253);
    }

    function testMaxWithdraw() public {
        emit log_uint(nft.balanceOf(a));
        assertEq(nft.balanceOf(a), 250);
        uint256[] memory ids = new uint256[](250);
        ids[0] = 1;
        ids[1] = 2;
        ids[2] = 3;
        ids[3] = 7;
        ids[4] = 8;
        ids[5] = 9;
        ids[6] = 10;
        ids[7] = 11;
        ids[8] = 12;
        ids[9] = 13;
        ids[10] = 14;
        ids[11] = 15;
        ids[12] = 16;
        ids[13] = 17;
        ids[14] = 18;
        ids[15] = 19;
        ids[16] = 20;
        ids[17] = 21;
        ids[18] = 22;
        ids[19] = 23;
        ids[20] = 24;
        ids[21] = 25;
        ids[22] = 26;
        ids[23] = 27;
        ids[24] = 28;
        ids[25] = 29;
        ids[26] = 30;
        ids[27] = 31;
        ids[28] = 32;
        ids[29] = 33;
        ids[30] = 34;
        ids[31] = 35;
        ids[32] = 36;
        ids[33] = 37;
        ids[34] = 38;
        ids[35] = 39;
        ids[36] = 40;
        ids[37] = 41;
        ids[38] = 42;
        ids[39] = 43;
        ids[40] = 44;
        ids[41] = 45;
        ids[42] = 46;
        ids[43] = 47;
        ids[44] = 48;
        ids[45] = 49;
        ids[46] = 50;
        ids[47] = 51;
        ids[48] = 52;
        ids[49] = 53;
        ids[50] = 54;
        ids[51] = 55;
        ids[52] = 56;
        ids[53] = 57;
        ids[54] = 58;
        ids[55] = 59;
        ids[56] = 60;
        ids[57] = 61;
        ids[58] = 62;
        ids[59] = 63;
        ids[60] = 64;
        ids[61] = 65;
        ids[62] = 66;
        ids[63] = 67;
        ids[64] = 68;
        ids[65] = 69;
        ids[66] = 70;
        ids[67] = 71;
        ids[68] = 72;
        ids[69] = 73;
        ids[70] = 74;
        ids[71] = 75;
        ids[72] = 76;
        ids[73] = 77;
        ids[74] = 78;
        ids[75] = 79;
        ids[76] = 80;
        ids[77] = 81;
        ids[78] = 82;
        ids[79] = 83;
        ids[80] = 84;
        ids[81] = 85;
        ids[82] = 86;
        ids[83] = 87;
        ids[84] = 88;
        ids[85] = 89;
        ids[86] = 90;
        ids[87] = 91;
        ids[88] = 92;
        ids[89] = 93;
        ids[90] = 94;
        ids[91] = 95;
        ids[92] = 96;
        ids[93] = 97;
        ids[94] = 98;
        ids[95] = 99;
        ids[96] = 100;
        ids[97] = 101;
        ids[98] = 102;
        ids[99] = 103;
        ids[100] = 104;
        ids[101] = 105;
        ids[102] = 106;
        ids[103] = 107;
        ids[104] = 108;
        ids[105] = 109;
        ids[106] = 110;
        ids[107] = 111;
        ids[108] = 112;
        ids[109] = 113;
        ids[110] = 114;
        ids[111] = 115;
        ids[112] = 116;
        ids[113] = 117;
        ids[114] = 118;
        ids[115] = 119;
        ids[116] = 120;
        ids[117] = 121;
        ids[118] = 122;
        ids[119] = 123;
        ids[120] = 124;
        ids[121] = 125;
        ids[122] = 126;
        ids[123] = 127;
        ids[124] = 128;
        ids[125] = 129;
        ids[126] = 130;
        ids[127] = 131;
        ids[128] = 132;
        ids[129] = 133;
        ids[130] = 134;
        ids[131] = 135;
        ids[132] = 136;
        ids[133] = 137;
        ids[134] = 138;
        ids[135] = 139;
        ids[136] = 140;
        ids[137] = 141;
        ids[138] = 142;
        ids[139] = 143;
        ids[140] = 144;
        ids[141] = 145;
        ids[142] = 146;
        ids[143] = 147;
        ids[144] = 148;
        ids[145] = 149;
        ids[146] = 150;
        ids[147] = 151;
        ids[148] = 152;
        ids[149] = 153;
        ids[150] = 154;
        ids[151] = 155;
        ids[152] = 156;
        ids[153] = 157;
        ids[154] = 158;
        ids[155] = 159;
        ids[156] = 160;
        ids[157] = 161;
        ids[158] = 162;
        ids[159] = 163;
        ids[160] = 164;
        ids[161] = 165;
        ids[162] = 166;
        ids[163] = 167;
        ids[164] = 168;
        ids[165] = 169;
        ids[166] = 170;
        ids[167] = 171;
        ids[168] = 172;
        ids[169] = 173;
        ids[170] = 174;
        ids[171] = 175;
        ids[172] = 176;
        ids[173] = 177;
        ids[174] = 178;
        ids[175] = 179;
        ids[176] = 180;
        ids[177] = 181;
        ids[178] = 182;
        ids[179] = 183;
        ids[180] = 184;
        ids[181] = 185;
        ids[182] = 186;
        ids[183] = 187;
        ids[184] = 188;
        ids[185] = 189;
        ids[186] = 190;
        ids[187] = 191;
        ids[188] = 192;
        ids[189] = 193;
        ids[190] = 194;
        ids[191] = 195;
        ids[192] = 196;
        ids[193] = 197;
        ids[194] = 198;
        ids[195] = 199;
        ids[196] = 200;
        ids[197] = 201;
        ids[198] = 202;
        ids[199] = 203;
        ids[200] = 204;
        ids[201] = 205;
        ids[202] = 206;
        ids[203] = 207;
        ids[204] = 208;
        ids[205] = 209;
        ids[206] = 210;
        ids[207] = 211;
        ids[208] = 212;
        ids[209] = 213;
        ids[210] = 214;
        ids[211] = 215;
        ids[212] = 216;
        ids[213] = 217;
        ids[214] = 218;
        ids[215] = 219;
        ids[216] = 220;
        ids[217] = 221;
        ids[218] = 222;
        ids[219] = 223;
        ids[220] = 224;
        ids[221] = 225;
        ids[222] = 226;
        ids[223] = 227;
        ids[224] = 228;
        ids[225] = 229;
        ids[226] = 230;
        ids[227] = 231;
        ids[228] = 232;
        ids[229] = 233;
        ids[230] = 234;
        ids[231] = 235;
        ids[232] = 236;
        ids[233] = 237;
        ids[234] = 238;
        ids[235] = 239;
        ids[236] = 240;
        ids[237] = 241;
        ids[238] = 242;
        ids[239] = 243;
        ids[240] = 244;
        ids[241] = 245;
        ids[242] = 246;
        ids[243] = 247;
        ids[244] = 248;
        ids[245] = 249;
        ids[246] = 250;
        ids[247] = 251;
        ids[248] = 252;
        ids[249] = 253;
        vm.prank(a);
        nft.setApprovalForAll(address(staker), true);
        vm.prank(a);
        staker.deposit(ids);
        vm.prank(a);
        staker.withdraw(250);
        // staker.withdraw(10);
    }
}
