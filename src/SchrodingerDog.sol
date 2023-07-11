// SPDX-License-Identifier: MIT

import {ERC721A} from "ERC721A/ERC721A.sol";
import {ERC721AQueryable} from "ERC721A/extensions/ERC721AQueryable.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


pragma solidity >=0.8.19;

contract SchrodingerDog is ERC721A , ERC721AQueryable, Ownable {
  using Strings for uint256;

  string baseURI;
  string public baseExtension = "";
  uint256 public cost = 0.0005 ether;
  uint256 public maxSupply = 10000;
  uint256 public maxMintAmount = 200;
  uint256 public releaseDate = 1688169600; // Unix  Timestamp July 1st 2023
  bytes32 public immutable merkleRoot;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    bytes32 _merkleRoot
  ) ERC721A(_name, _symbol) {
    setBaseURI(_initBaseURI);
    merkleRoot = _merkleRoot;
  }

  enum Status {
    whitelistMint,
    publicMint
  }

  Status public status;

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // Public Mint
  function mint(uint256 quantity) external payable {
    uint256 supply = _totalMinted();
    require(status == Status.publicMint,"Not Available for public");
    require(quantity > 0,"Quantity couldn't be 0");
    require(quantity <= maxMintAmount,"cannot be over the max mint amount");
    require(supply + quantity <= maxSupply);
    require(msg.value >= cost * quantity,"insufficient fund");

    _mint(msg.sender, quantity);

  }

  // Whitelist Mint
  function whitelistMint(uint256 quantity, bytes32[] memory proof) external payable {
    
    require(status == Status.whitelistMint, "Not Available For Whtielist");
    require(MerkleProof.verify(proof,merkleRoot,keccak256(
            abi.encodePacked(msg.sender)
        )), "Failed Verification");

    _mint(msg.sender, quantity);

  }

  // Owner Mint
  function freeMint(uint256 quantity) external onlyOwner {
    uint256 supply = _totalMinted();
    require(block.timestamp >= releaseDate,"Havent Release Yet!");
    require(quantity > 0,"Quantity couldn't be 0");
    require(quantity <= maxMintAmount,"Quantity cannot be over the max mint amount");
    require(supply + quantity <= maxSupply);

    _mint(msg.sender, quantity);
  }

  function totalMintedOfOwner(address _owner)
    external
    view
    returns (uint256)
  {
    uint256 tokenIds = _numberMinted(_owner);
    
    return tokenIds;
  }

  //only owner

  function setReleaseDate(uint256 _releaseDate) external onlyOwner {
    releaseDate = _releaseDate;
  }

  function setCost(uint256 _newCost) external onlyOwner {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) external onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) external onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function setStatus(Status _newStatus) external onlyOwner{
    status = _newStatus;
  }
 
  function withdraw(address to) external onlyOwner {
    (bool success, ) = payable(to).call{value: address(this).balance}("");
    require(success);
  }

  //Override Function
  function _startTokenId() internal pure override returns(uint256) {
    return 1;
  }
}