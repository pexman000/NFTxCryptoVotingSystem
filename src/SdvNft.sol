// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";


contract SdvNft is ERC721, Ownable {

    uint public tokenId;
    string NFT_NAME = 'Sup De Vinci Nft';
    string NFT_SYMBOL = 'SdvNft';

    mapping(uint tokenId => string tokenUri) public tokenIdToUri; 

    constructor() ERC721 (NFT_NAME, NFT_SYMBOL) Ownable(msg.sender){
        tokenId = 0;
    }

    function mintNft(address to, string memory tokenUri) public onlyOwner(){
        tokenId++;
        tokenIdToUri[tokenId] = tokenUri;
        _safeMint(to, tokenId);
    }

    function tokenURI(uint tokenId_) public view override returns (string memory) {
        return tokenIdToUri[tokenId_];
    }


}