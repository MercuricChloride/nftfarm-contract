// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SimpleNft is ERC721 {
    //prettier-ignore
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function mint(address _recipient, uint256 _tokenId) public {
        _mint(_recipient, _tokenId);
    }
}
