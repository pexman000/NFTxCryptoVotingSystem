// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {UsdvToken} from "../src/UsdvToken.sol";

contract DeployUSDV is Script {

    string USDV_NAME = 'USDV';
    string USDV_SYMBOL = 'USDV';
    uint8 DECIMALS = 6;
    uint INIT_SUPPLY = 500000 * 10 ** DECIMALS; 


    function run() public returns (UsdvToken)   {
        UsdvToken usdvToken;
        vm.startBroadcast();
        usdvToken = new UsdvToken(USDV_NAME, USDV_SYMBOL, INIT_SUPPLY);
        vm.stopBroadcast();
        return usdvToken;
    }
}