// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";


error AboveMaxSupply();

contract UsdvToken is ERC20, Ownable {

    uint constant INIT_SUPPLY = 500000 * 10 ** 6;
    uint public immutable MAX_SUPPLY;
    constructor (string memory _name, string memory _symbol, uint maxSupply) ERC20 (_name,_symbol) Ownable(msg.sender){
        MAX_SUPPLY = maxSupply;
        _mint(msg.sender, totalSupply());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        if (totalSupply() + amount > MAX_SUPPLY) revert AboveMaxSupply();
        // require(totalSupply() + amount <= MAX_SUPPLY, "ERC20: minting would exceed max supply");
        _mint(to,amount);
    }

    function decimals() public pure override returns (uint8) {  
        return 6;
    }


}