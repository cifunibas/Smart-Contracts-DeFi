// SPDX-License-Identifier: MIT

// Warning: For educational purposes only. Do not use with real funds.

pragma solidity ^0.8.9;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.2/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Hasoshi is ERC721Enumerable {
    using Strings for uint256;

    uint internal tokenCount;
    string internal baseURI;
    mapping(uint => uint) public tokenVariant; // Map tokenId to the tokenVariant

    constructor() ERC721("Hasoshi", "HAS") {
        baseURI = "https://raw.githubusercontent.com/cifunibas/Smart-Contracts-DeFi/main/assets/hasoshi/json/";
    }

    function mint() public {
        // Determine which of the 10 variants is minted
        // 1% chance for variant 10, equal chance for variants 1-9
        uint d100 = block.timestamp % 100; // "random" number from 0-99
        uint variant = d100 % 10 + 1;
        if (variant == 10) {
            variant = d100 / 10 + 1;
        }
        uint tokenId = ++tokenCount;
        tokenVariant[tokenId] = variant;
        _safeMint(msg.sender, tokenId);
    }

    function tokenURI(uint tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);
        uint variant = tokenVariant[tokenId];
        return string(
            abi.encodePacked(
                baseURI,
                variant.toString(),
                ".json"
            )
        );
    }

}
