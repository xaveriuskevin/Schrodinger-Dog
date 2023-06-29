// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;


// import "../lib/forge-std/src/Base.sol";
// import "../lib/forge-std/src/StdStorage.sol";
import "../lib/forge-std/src/Test.sol";

import {SchrodingerDog} from "../src/SchrodingerDog.sol";

contract SchrodingerDogTest is Test {
    SchrodingerDog public schrodingerDog;
    

    function setUp() public {
        schrodingerDog = new SchrodingerDog("Schrodinger Dog", "SD-K","https://api.coolcatsnft.com/cat/");
    }

    function testSetCost() public {
        schrodingerDog.setCost(0.005 ether);
        uint256 testCost = 0.05 ether;
        uint256 newCost = schrodingerDog.cost();
        assertEq(testCost,newCost);
    }

    function testSetReleaseDate() public {
        schrodingerDog.setReleaseDate(1688403600);
        uint256 todayDate = schrodingerDog.releaseDate();
        uint256 testDate = 1688403600;
        assertEq(testDate,todayDate);
    }

    function testSetMaxMintAmount() public {
        schrodingerDog.setmaxMintAmount(250);
        uint256 todayMaxMintAmount = schrodingerDog.maxMintAmount();
        uint256 testMaxMintAmount = 200;
        assertEq(testMaxMintAmount,todayMaxMintAmount);
    }

    // function testSetBaseUri() public {
    //     schrodingerDog.setBaseURI("ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/");
    //     string memory todayBaseUri = schrodingerDog.baseURI();
    //     string memory testBaseUri = "https://api.coolcatsnft.com/cat/";
    //     assertEq(todayBaseUri,testBaseUri);
    // }

    function testSetBaseExtension() public {
        schrodingerDog.setBaseExtension("");
        string memory todayBaseExtension = schrodingerDog.baseExtension();
        string memory testBaseExtension = ".json";
        assertEq(testBaseExtension,todayBaseExtension);
    }

    
}
