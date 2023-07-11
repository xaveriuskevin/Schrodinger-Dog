// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import "../lib/forge-std/src/Test.sol";

import {SchrodingerDog} from "../src/SchrodingerDog.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract SchrodingerDogTest is Test,ERC721Holder {
    SchrodingerDog public schrodingerDog;
    //Set Address Public
    //Excluded in whitelist (Testing Purposes)
    address _kevin = address(0x7777);
    address _devin = address(0x1b159de6a5084047220adf1c63e166a18f84f2c9);
    address _valvin = address(0x222Da5f13D800Ff94947C20e8714E103822Ff716);

    //Included in whitelist 
    address _toni = address(0xe3f67c7ad8Af0dFFe5C17b397cAf94582306ec4B);
    address _sori = address(0x409d3543754C0629dCEA5A1DAA7d8edD72AaDdfE);
    address _meri = address(0x818833a439DA3a34253304993A78052644237855);

    

    //Contract can receive Money
    receive() external payable {}

    function setUp() public {
        //Default Owner Test Deployed Contract
        schrodingerDog = new SchrodingerDog("Schrodinger Dog", "SD-K","https://api.coolcatsnft.com/cat/", "8e6478a55ca94f53a5c5dadd988ddb63531f511fae7cb1cbc54619a10f1e0880");

        //Give Public Address Money
        vm.deal(_kevin,10 ether);

        //Give Owner Address Money
        vm.deal(address(this),10 ether);
    }

    function testSetCost() public {
        //Owner Set New Cost
        schrodingerDog.setCost(0.5 ether);
        uint256 newCost = schrodingerDog.cost();

        //Test
        uint256 testCost = 0.5 ether;

        //Public Try Set
        vm.startPrank(address(_kevin));
        vm.expectRevert("Ownable: caller is not the owner");
        schrodingerDog.setCost(0.5 ether);
        vm.warp(1688403600);

        //Public Try mint with new Cost
        vm.expectRevert("insufficient fund");
        schrodingerDog.mint{value: 0.005 ether}(1);
        schrodingerDog.mint{value: 0.9 ether}(1);
        vm.stopPrank();

        //Assert
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
        string memory testBaseExtension = "";
        
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

        //Failed to Mint Because of Mint Status --> Current status (whitelistMint)
        vm.expectRevert("Not Available for public");
        schrodingerDog.mint{value: 0.01 ether}(3);

        //Public Try to Set Status  
        vm.expectRevert("Ownable: caller is not the owner");
        schrodingerDog.setStatus(SchrodingerDog.Status.publicMint);
        vm.stopPrank();

        //Owner Set Status to Public Mint
        schrodingerDog.setStatus(SchrodingerDog.Status.publicMint);

        //Assert New Status
        // assertEq(schrodingerDog.Status(), "publicMint");

        //Public Try to Mint After Status Change
        vm.startPrank(_kevin);
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

        //Assert to check TokenId of Owner
        uint256[] memory tokenId = schrodingerDog.tokensOfOwner(_kevin);
        uint256[] memory testTokenId = new uint256[](3);
        testTokenId[0] = 1;
        testTokenId[1] = 2;
        testTokenId[2] = 3;
        assertEq(tokenId[0],testTokenId[0]);
        
        
        //Assert to check if owner balance before withdraw
        assertEq(address(this).balance,10 ether);

        //Withdraw
        schrodingerDog.withdraw(address(this));
        
        //Assert if Owner Balance Increase
        assertEq(address(this).balance,11 ether);

        //Assert if contract Balance Decrease
        assertEq(address(schrodingerDog).balance, 0 ether);
    }
}