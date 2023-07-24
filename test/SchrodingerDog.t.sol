// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import {Test} from "../lib/forge-std/src/Test.sol";
import {SchrodingerDog} from "../src/SchrodingerDog.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

//Custom Error
error InsufficientBalance();
error SupplyExceeded();
error InvalidSaleStatus();
error InvalidProof();
error WithdrawFailed();
error WhitelistExceeded();
error WalletLimitExceeded();
error InvalidNewSupply();

contract SchrodingerDogTest is Test,ERC721Holder {
    SchrodingerDog public schrodingerDog;

    //Set Address Public 
    //Excluded in whitelist (Testing Purposes)
    address _kevin = address(0x7777);
    address _devin = address(0x35F6Db157c8f033037E82e8E4A0cC15e2B0B9777);
    address _valvin = address(0x222Da5f13D800Ff94947C20e8714E103822Ff716);

    //Included in whitelist 
    address _sori = address(0xe3f67c7ad8Af0dFFe5C17b397cAf94582306ec4B);
    address _meri = address(0x409d3543754C0629dCEA5A1DAA7d8edD72AaDdfE);
    address _tori = address(0x818833a439DA3a34253304993A78052644237855);

    //Contract can receive Money
    receive() external payable {}

    function setUp() public {
        //Default Owner Test Deployed Contract
        schrodingerDog = new SchrodingerDog("Schrodinger Dog", "SD-K","https://api.coolcatsnft.com/cat/",0x3620b338a696ef6150537fec46cb9f7d0ef2570a31ba034e6726bf0d0cb72fe0 , address(this));

        //Give Public Address Money
        vm.deal(_kevin,10 ether);
        vm.deal(_devin,10 ether);
        vm.deal(_valvin,10 ether);

        vm.deal(_tori,10 ether);
        vm.deal(_sori,10 ether);
        vm.deal(_meri,10 ether);

        //Give Owner Address Money
        vm.deal(address(this),10 ether);
    }

    function testSetPrices() public {
        /*
        ** Information ** 
        whitelistPrice = 0.0005 
        publicPrice = 0.005
        */

        //Owner Set New Cost (uint256 whitelistPrice , uint256 publicPrice)
        schrodingerDog.setPrices(0.005 ether , 0.05 ether);

        //Owner Set Sale Status
        schrodingerDog.setSaleStatus(SchrodingerDog.SaleStatus.PUBLIC);

        // Assert whitelist and public Price
        assertEq(schrodingerDog.whitelistPrice(), 0.005 ether);
        assertEq(schrodingerDog.publicPrice(), 0.05 ether);

        // Public Try Set
        vm.startPrank(address(_kevin));
        vm.expectRevert("Ownable: caller is not the owner");
        schrodingerDog.setPrices(0.0005 ether , 0.005 ether);

        //Public Try mint with new Cost
        vm.expectRevert(InsufficientBalance.selector);
        schrodingerDog.publicMint{value: 0.005 ether}(1);
        schrodingerDog.publicMint{value: 0.05 ether}(1);
        vm.stopPrank();

        //Assert
        assertEq(schrodingerDog.ownerOf(1),_kevin);
    }

    function testSetMaxSupply() public {
        /*
        ** Information ** 
        maxSupply = 10000
        */

        //Owner Set
        vm.expectRevert(InvalidNewSupply.selector);
        schrodingerDog.setMaxSupply(10001);
        schrodingerDog.setMaxSupply(9999);

        //Assert
        assertEq(schrodingerDog.maxSupply(),9999);

        //Public Set
        vm.startPrank(address(_kevin));
        vm.expectRevert("Ownable: caller is not the owner");
        schrodingerDog.setMaxSupply(9998);
    }

    function testOwnerMint() public {
    
        //Set Max Supply to 100 --> Testing
        schrodingerDog.setMaxSupply(100);
        assertEq(schrodingerDog.maxSupply(), 100);
        //Owner Mint
        schrodingerDog.ownerMint(5);
        assertEq(schrodingerDog.ownerOf(1),address(this));
        assertEq(schrodingerDog.ownerOf(2),address(this));
        assertEq(schrodingerDog.ownerOf(3),address(this));
        assertEq(schrodingerDog.ownerOf(4),address(this));
        assertEq(schrodingerDog.ownerOf(5),address(this));
        assertEq(schrodingerDog.totalMintCount(address(this)),5);

        //Public try to use ownerMint
        vm.startPrank(_kevin);
        vm.expectRevert("Ownable: caller is not the owner");
        schrodingerDog.ownerMint(2);
        vm.stopPrank();

        //Owner Mint Over the Max Supply
        vm.expectRevert(SupplyExceeded.selector);
        schrodingerDog.ownerMint(96);
        schrodingerDog.ownerMint(5);
        assertEq(schrodingerDog.ownerOf(6),address(this));
        assertEq(schrodingerDog.ownerOf(7),address(this));
        assertEq(schrodingerDog.ownerOf(8),address(this));
        assertEq(schrodingerDog.ownerOf(9),address(this));
        assertEq(schrodingerDog.ownerOf(10),address(this));
        assertEq(schrodingerDog.totalMintCount(address(this)),10);
    }

    function testSetBaseExtension() public {
        //Test
        string memory testBaseExtension = ".json";
        
        //Public Set
        vm.startPrank(_kevin);
        vm.expectRevert("Ownable: caller is not the owner");
        schrodingerDog.setBaseExtension(".json");
        vm.stopPrank();

        //Owner Set
        schrodingerDog.setBaseExtension(".json");
        string memory todayBaseExtension = schrodingerDog.baseExtension();

        //Assert
        assertEq(testBaseExtension,todayBaseExtension);
    }

    function testMint() public {
        /*
        Test All Whitelist Mint & Public Mint
        Test set Max min per wallet either public or whitelist
        ** Information ** 
        PublicMintsPerWallet = 3
        whitelistMintsPerWallet = 3

        Included in whitelist _sori _meri _tori
        Excluded in whitelist _kevin _devin _valvin
        */

        //Sori
        //Owner Change Sale Status To Whitelist
        schrodingerDog.setSaleStatus(SchrodingerDog.SaleStatus.WHITELIST);

        //Sori Bytes32[] Proof
        bytes32[] memory proofSori = new bytes32[](2);
        proofSori[0] = 0x5073917c7fa2e6661f8b3a5e84cf61ca625bdd1cca68f985ef8378f8114e823c;
        proofSori[1] = 0x37ae62c37e507b5c45eda43e2c8d2d215f4d2fd06c03a15e5f5883d0652388a3;

        //Sori will mint in whitelist
        vm.startPrank(_sori);
        schrodingerDog.whitelistMint{value : 0.0005 ether}(1, proofSori);
        
        //Assert 
        assertEq(schrodingerDog.ownerOf(1), _sori);
        assertEq(schrodingerDog.totalMintCount(_sori),1);
        assertEq(schrodingerDog.whitelistMintCount(_sori),1);
        vm.stopPrank();

        //Owner Set Sale Status to Public
        schrodingerDog.setSaleStatus(SchrodingerDog.SaleStatus.PUBLIC);

        //Sori will Mint in Public
        vm.startPrank(_sori);
        vm.expectRevert(InvalidSaleStatus.selector);
        schrodingerDog.whitelistMint{value : 0.0005 ether}(1, proofSori);
        schrodingerDog.publicMint{value: 0.005 ether}(1);

        //Assert
        assertEq(schrodingerDog.ownerOf(2), _sori);
        assertEq(schrodingerDog.totalMintCount(_sori),2);
        assertEq(schrodingerDog.whitelistMintCount(_sori),1);
        vm.stopPrank();

        //Meri
        //Owner change sale status to whitelist
        schrodingerDog.setSaleStatus(SchrodingerDog.SaleStatus.WHITELIST);

        //Meri bytes32[] proof
        bytes32[] memory proofMeri = new bytes32[](1);
        proofMeri[0] = 0x4dd6bdff102776145654be0750640374e3fa09a00094f14eefd73673e725897c;

        //Meri will mint in whitelist
        vm.startPrank(_meri);
        //Assert
        assertEq(schrodingerDog.whitelistMintCount(_meri), 0);
        vm.expectRevert(WhitelistExceeded.selector);
        schrodingerDog.whitelistMint{value : 0.002 ether}(4, proofMeri);
        vm.expectRevert(InsufficientBalance.selector);
        schrodingerDog.whitelistMint{value: 0.0014 ether}(3, proofMeri);
        schrodingerDog.whitelistMint{value: 0.0015 ether}(3, proofMeri);

        //Assert
        assertEq(schrodingerDog.ownerOf(3), _meri);
        assertEq(schrodingerDog.ownerOf(4), _meri);
        assertEq(schrodingerDog.ownerOf(5), _meri);
        assertEq(schrodingerDog.totalMintCount(_meri),3);
        assertEq(schrodingerDog.whitelistMintCount(_meri),3);
        vm.stopPrank();

        //Owner Set Sale Status to Public
        schrodingerDog.setSaleStatus(SchrodingerDog.SaleStatus.PUBLIC);

        //Meri will Mint in Public
        vm.startPrank(_meri);
        vm.expectRevert(WalletLimitExceeded.selector);
        schrodingerDog.publicMint{value: 0.02 ether}(4);
        vm.expectRevert(InsufficientBalance.selector);
        schrodingerDog.publicMint{value: 0.014 ether}(3);
        schrodingerDog.publicMint{value: 0.015 ether}(3);
        assertEq(schrodingerDog.ownerOf(6), _meri);
        assertEq(schrodingerDog.ownerOf(7), _meri);
        assertEq(schrodingerDog.ownerOf(8), _meri);
        assertEq(schrodingerDog.totalMintCount(_meri),6);
        assertEq(schrodingerDog.whitelistMintCount(_meri),3);
        vm.stopPrank();

        //Tori
        //Owner change sale status to whitelist
        schrodingerDog.setSaleStatus(SchrodingerDog.SaleStatus.WHITELIST);
        //Owner change maximum mint per wallet to 4
        schrodingerDog.setMaxMint(4,5);

        //Assert
        assertEq(schrodingerDog.whitelistMintsPerWallet(), 4);
        assertEq(schrodingerDog.publicMintsPerWallet(), 5);

        //Tori Bytes32[] Proof
        bytes32[] memory proofTori = new bytes32[](2);
        proofTori[0] = 0xf6d476e8cd6d1bcc29b6d92e14b4be1888d9c12af364cd50c588ca7606912f39;
        proofTori[1] = 0x37ae62c37e507b5c45eda43e2c8d2d215f4d2fd06c03a15e5f5883d0652388a3;

        //Tori will Mint with new limit for Whitelist
        vm.startPrank(_tori);
        schrodingerDog.whitelistMint{value: 0.002 ether}(4, proofTori);
        //Assert
        assertEq(schrodingerDog.ownerOf(9), _tori);
        assertEq(schrodingerDog.ownerOf(10), _tori);
        assertEq(schrodingerDog.ownerOf(11), _tori);
        assertEq(schrodingerDog.ownerOf(12), _tori);
        assertEq(schrodingerDog.totalMintCount(_tori),4);
        assertEq(schrodingerDog.whitelistMintCount(_tori),4);
        vm.stopPrank();

        //Owner Set Sale Status to Public
        schrodingerDog.setSaleStatus(SchrodingerDog.SaleStatus.PUBLIC);

        //Tori will Mint in public with new public limit mints
        vm.startPrank(_tori);
        vm.expectRevert(WalletLimitExceeded.selector);
        schrodingerDog.publicMint{value : 0.03 ether}(6);
        schrodingerDog.publicMint{value: 0.025 ether}(5);

        //Assert
        assertEq(schrodingerDog.ownerOf(13), _tori);
        assertEq(schrodingerDog.ownerOf(14), _tori);
        assertEq(schrodingerDog.ownerOf(15), _tori);
        assertEq(schrodingerDog.ownerOf(16), _tori);
        assertEq(schrodingerDog.ownerOf(17), _tori);
        assertEq(schrodingerDog.totalMintCount(_tori),9);
        assertEq(schrodingerDog.whitelistMintCount(_tori),4);
        vm.stopPrank();

        //Devin
        //Owner change sale status to whitelist
        schrodingerDog.setSaleStatus(SchrodingerDog.SaleStatus.WHITELIST);

        vm.startPrank(_devin);
        vm.expectRevert(InvalidProof.selector);
        schrodingerDog.whitelistMint{value: 0.0005 ether}(1, proofSori);
        vm.expectRevert(InvalidProof.selector);
        schrodingerDog.whitelistMint{value: 0.0005 ether}(1, proofTori);
        vm.expectRevert(InvalidProof.selector);
        schrodingerDog.whitelistMint{value: 0.0005 ether}(1, proofMeri);
        vm.stopPrank();

        //Owner Set Sale Status to Public
        schrodingerDog.setSaleStatus(SchrodingerDog.SaleStatus.PUBLIC);

        vm.startPrank(_devin);
        schrodingerDog.publicMint{value : 0.01 ether}(2);

        //Assert
        assertEq(schrodingerDog.ownerOf(18), _devin);
        assertEq(schrodingerDog.ownerOf(19), _devin);
        assertEq(schrodingerDog.totalMintCount(_devin),2);
        assertEq(schrodingerDog.whitelistMintCount(_devin),0);

        vm.expectRevert(WalletLimitExceeded.selector);
        schrodingerDog.publicMint{value: 0.02 ether}(4);
        schrodingerDog.publicMint{value: 0.015 ether}(3);

        //Assert
        assertEq(schrodingerDog.ownerOf(20), _devin);
        assertEq(schrodingerDog.ownerOf(21), _devin);
        assertEq(schrodingerDog.ownerOf(22), _devin);
        assertEq(schrodingerDog.totalMintCount(_devin),5);
        assertEq(schrodingerDog.whitelistMintCount(_devin),0);
        vm.stopPrank();
        

        //Withdraw
        //Assert to check if contract receive the money
        assertEq(address(schrodingerDog).balance, 0.074 ether);

        //Assert to check the owner balance before withdraw
        assertEq(address(this).balance, 10 ether);

        schrodingerDog.withdrawFunds(address(this));

        //Assert to check if the owner balance increase
        assertEq(address(this).balance, 10.074 ether);

        //Assert to check if the contract balance decrease
        assertEq(address(schrodingerDog).balance, 0 ether);

    }
}