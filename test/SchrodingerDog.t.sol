// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;


// import "../lib/forge-std/src/Base.sol";
// import "../lib/forge-std/src/StdStorage.sol";
import "../lib/forge-std/src/Test.sol";

import {SchrodingerDog} from "../src/SchrodingerDog.sol";
import { ERC721Holder } from "@openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Holder.sol";

contract SchrodingerDogTest is Test,ERC721Holder {
    SchrodingerDog public schrodingerDog;

    function setUp() public {
        schrodingerDog = new SchrodingerDog("Schrodinger Dog", "SD-K","https://api.coolcatsnft.com/cat/");
    }

    // function testSetCost() public {
    //     uint256 testCost = 6 ether;
    //     vm.startPrank(address(0x23645276));
    //     vm.expectRevert("Ownable: caller is not the owner");
    //     schrodingerDog.setCost(6 ether);
    //     vm.stopPrank();
    //     schrodingerDog.setCost(6 ether);
    //     uint256 newCost = schrodingerDog.cost();
    //     assertEq(testCost,newCost);
    // }

    // function testSetReleaseDate() public {
    //     uint256 testDate = 1688403600;
    //     vm.startPrank(address(0x23645276));
    //     vm.expectRevert("Ownable: caller is not the owner");
    //     schrodingerDog.setReleaseDate(1688403600);
    //     vm.stopPrank();
    //     schrodingerDog.setReleaseDate(1688403600);
    //     uint256 todayDate = schrodingerDog.releaseDate();
    //     assertEq(testDate,todayDate);
    // }

    // function testSetMaxMintAmount() public {
    //     uint256 testMaxMintAmount = 200;
    //     vm.startPrank(address(0x23645276));
    //     vm.expectRevert("Ownable: caller is not the owner");
    //     schrodingerDog.setmaxMintAmount(250);
    //     vm.stopPrank();
    //     schrodingerDog.setmaxMintAmount(250);
    //     uint256 todayMaxMintAmount = schrodingerDog.maxMintAmount();
    //     assertEq(testMaxMintAmount,todayMaxMintAmount);
    // }

    // function testSetBaseExtension() public {
    //     string memory testBaseExtension = ".json";
    //     vm.startPrank(address(0x23645276));
    //     vm.expectRevert("Ownable: caller is not the owner");
    //     schrodingerDog.setBaseExtension("");
    //     vm.stopPrank();
    //     schrodingerDog.setBaseExtension("");
    //     string memory todayBaseExtension = schrodingerDog.baseExtension();
    //     assertEq(testBaseExtension,todayBaseExtension);
    // }
   
    // function testOwner() public {
    //     console.log(schrodingerDog.owner());
    //     console.log(address(this));
    //     assertEq(schrodingerDog.owner(),address(this));
    // }

    // function testWalletOfOwner() public {
    //     //False karena belom mint
    //     assertEq(schrodingerDog.walletOfOwner(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496),2);
    // }

    // function testMintOwner() public {
    //     vm.expectRevert("Havent Release Yet!");
    //     schrodingerDog.mint(2);
    //     vm.warp(1688371121);
    //     schrodingerDog.mint(2);
    //     address owner = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496;
    //     assertEq(schrodingerDog.ownerOf(1),owner);
    // }
}
