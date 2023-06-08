// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "lib/forge-std/src/Test.sol";
import {WnsRegistrar} from "../src/WNSRegistrar.sol";
import {WnsRegistry} from"../src/WNSRegistry.sol";
import {WnsAddresses} from"../src/WNSAddress.sol";
import {WnsErc721} from"../src/WNSERC721.sol";



contract WnsRegistrarTest is Test {
    WnsRegistrar public wnsregistrar;
    WnsRegistry public wnsregistry;
    WnsAddresses public wnsaddress;
    WnsErc721 public wnserc721;

    function setUp() public {
        wnsregistry = new WnsRegistry();
        wnsregistrar = new WnsRegistrar(address(wnsregistry));
        wnsaddress = new WnsAddresses(address(wnsregistry), keccak256("PASSWORD"));
        wnserc721 = new WnsErc721(address(wnsregistry), "aaaaaaaa" , "web3nameservice" , "wns");
    }

    function testisActive() public {
        bool isActive = wnsregistrar.isActive();
        assertEq(isActive,false);
    }
    


    
}
