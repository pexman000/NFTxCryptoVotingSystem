// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {SdvNft} from "../src/SdvNft.sol";

contract DeploySdvNft is Script {

    function run() public returns (SdvNft)   {
        SdvNft sdvNft;
        vm.startBroadcast();
        sdvNft = new SdvNft();
        vm.stopBroadcast();
        return sdvNft;
    }
}