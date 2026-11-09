// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.7.0
pragma solidity ^0.8.27;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MyERC721NFT is ERC721, Ownable {
    uint256 private _nextTokenId;
    string public newBaseURI;
    bool public metadataFrozen;

    event BaseURIUpdated(string _newBaseURI);
    event MetadataFrozen();

    constructor(address initialOwner) ERC721("MyERC721NFT", "DPNFT") Ownable(initialOwner) {
    }

    function safeMint(address to) public onlyOwner returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        return tokenId;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        require(!metadataFrozen, "Metadata is frozen");
        newBaseURI = _newBaseURI;

        emit BaseURIUpdated(_newBaseURI);
    }

    function freezeMetadata() public onlyOwner {
        require(!metadataFrozen, "Already frozen");
        metadataFrozen = true;

        emit MetadataFrozen();
    }

    function _baseURI() internal view override returns (string memory) {
        return newBaseURI;
    }        
}
