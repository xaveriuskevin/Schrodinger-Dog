// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;


// import "../lib/forge-std/src/Base.sol";
// import "../lib/forge-std/src/StdStorage.sol";
import "../lib/forge-std/src/Test.sol";

import {SchrodingerDog} from "../src/SchrodingerDog.sol";
import { ERC721Holder } from "@openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Holder.sol";

contract SchrodingerDogTest is Test,ERC721Holder {
    SchrodingerDog public schrodingerDog;
    //Set Address Public
    address _kevin = address(0x7777);

    //Contract can receive Money
    receive() external payable {}

    function setUp() public {
        //Default Owner Test Deployed Contract
        schrodingerDog = new SchrodingerDog("Schrodinger Dog", "SD-K","https://api.coolcatsnft.com/cat/");

        //Give Public Address Money
        vm.deal(_kevin,10 ether);
    }

    function testSetCost() public {
        schrodingerDog.setCost(0.5 ether);
        uint256 newCost = schrodingerDog.cost();
        uint256 testCost = 0.5 ether;
        vm.startPrank(address(_kevin));
        vm.expectRevert("Ownable: caller is not the owner");
        schrodingerDog.setCost(0.5 ether);
        vm.warp(1688403600);
        vm.expectRevert("insufficient fund");
        schrodingerDog.mint{value: 0.1 ether}(1);
        schrodingerDog.mint{value: 0.9 ether}(1);
        vm.stopPrank();
        assertEq(testCost,newCost);
        assertEq(schrodingerDog.ownerOf(1),_kevin);
    }

    function testSetReleaseDate() public {
        //Test
        uint256 testDate = 1688403600;

        //Public Set Release Date
        vm.startPrank(address(_kevin));
        vm.expectRevert("Ownable: caller is not the owner");
        schrodingerDog.setReleaseDate(1688403600);
        vm.stopPrank();

        //Owner Set Release Date & Free Mint
        schrodingerDog.setReleaseDate(1688403600);
        uint256 todayDate = schrodingerDog.releaseDate();
        vm.warp(1688403600);
        schrodingerDog.freeMint(1);

        //Assert
        assertEq(testDate,todayDate);
        assertEq(schrodingerDog.ownerOf(1),address(this));
    }

    function testSetMaxMintAmount() public {
        //Owner Set
        schrodingerDog.setmaxMintAmount(10);
        uint256 todayMaxMintAmount = schrodingerDog.maxMintAmount();
        //Test 
        uint256 testMaxMintAmount = 10;

        //Public Set
        vm.startPrank(address(_kevin));
        vm.expectRevert("Ownable: caller is not the owner");
        schrodingerDog.setmaxMintAmount(250);
        vm.warp(1688403600);
        //Public Mint with less ether
        vm.expectRevert("insufficient fund");
        schrodingerDog.mint{value:0.004 ether}(10);
        //Public Mint with over the maxmint amount
        vm.expectRevert("Quantity cannot be over the max mint amount");
        schrodingerDog.mint{value: 0.05 ether}(11);
        //Public Success Mint
        schrodingerDog.mint{value: 0.007 ether}(10);
        vm.stopPrank();

        //Assert
        assertEq(testMaxMintAmount,todayMaxMintAmount);
        assertEq(schrodingerDog.ownerOf(7),_kevin);
        assertEq(schrodingerDog.ownerOf(10),_kevin);
    }

    function testSetBaseExtension() public {
        //Test
        string memory testBaseExtension = ".json";
        
        //Public Set
        vm.startPrank(address(_kevin));
        vm.expectRevert("Ownable: caller is not the owner");
        schrodingerDog.setBaseExtension("");
        vm.stopPrank();

        //Owner Set
        schrodingerDog.setBaseExtension("");
        string memory todayBaseExtension = schrodingerDog.baseExtension();

        //Assert
        assertEq(testBaseExtension,todayBaseExtension);
    }

    function testOwner() public {
        assertEq(schrodingerDog.owner(),address(this));
    }

    function testTotalMintedOfOwner() public {
        vm.warp(1688371121);
        //Owner Mint
        schrodingerDog.freeMint(2);

        
        //Public Mint
        vm.startPrank(_kevin);
        schrodingerDog.mint{value: 0.01 ether}(5);
        vm.stopPrank();

        //Assert
        assertEq(schrodingerDog.totalMintedOfOwner(address(this)),2);
        assertEq(schrodingerDog.totalMintedOfOwner(_kevin),5);
        assertEq(schrodingerDog.ownerOf(1),address(this));
        assertEq(schrodingerDog.ownerOf(2),address(this));
        assertEq(schrodingerDog.ownerOf(3),_kevin);
        assertEq(schrodingerDog.ownerOf(4),_kevin);
        assertEq(schrodingerDog.ownerOf(5),_kevin);
    }

    function testFreeMint() public {
        //Owner Mint Before Date
        vm.expectRevert("Havent Release Yet!");
        schrodingerDog.freeMint(2);

        //Owner Free Mint
        vm.warp(1688371121);
        schrodingerDog.freeMint(2);

        //Public Mint
        vm.startPrank(_kevin);
        vm.expectRevert("Ownable: caller is not the owner");
        schrodingerDog.freeMint(2);
        vm.stopPrank();

        //Assert
        assertEq(schrodingerDog.ownerOf(1),address(this));
        assertEq(schrodingerDog.ownerOf(2),address(this));
        assertEq(schrodingerDog.totalMintedOfOwner(address(this)),2);
    }
    
    function testMintNonOwner() public {
        //Public Try Free Mint
        vm.startPrank(_kevin);
        vm.expectRevert("Ownable: caller is not the owner");
        schrodingerDog.freeMint(3);
        vm.expectRevert("Havent Release Yet!");
        schrodingerDog.mint{value: 0.01 ether}(3);
        vm.warp(1688371121);  
        schrodingerDog.mint{value: 0.01 ether}(5);
        vm.stopPrank();

        //Assert
        assertEq(schrodingerDog.ownerOf(1),_kevin);
        assertEq(schrodingerDog.ownerOf(2),_kevin);
        assertEq(schrodingerDog.ownerOf(3),_kevin);
        assertEq(schrodingerDog.totalMintedOfOwner(_kevin),5);
    }

    function testWithdraw() public {
        //Public Mint -> Contract Receive money equal to 1 ether
        vm.startPrank(_kevin);
        vm.warp(1688371121);
        schrodingerDog.mint{value: 1 ether}(3);
        vm.stopPrank();

        //Assert to check if contract receive the money
        assertEq(address(schrodingerDog).balance, 1 ether);

        //Assert to make sure _kevin mint is success
        assertEq(schrodingerDog.totalMintedOfOwner(_kevin),3);
        assertEq(schrodingerDog.ownerOf(3),_kevin);
        
        //Assert to check if owner balance before withdraw
        assertEq(address(this).balance,79228162514.264337593543950335 ether);

        //Withdraw
        schrodingerDog.withdraw(address(this));
        
        //Assert if Owner Balance Increase
        assertEq(address(this).balance,79228162515.264337593543950335 ether);

        //Assert if contract Balance Decrease
        assertEq(address(schrodingerDog).balance, 0 ether);
    }
}