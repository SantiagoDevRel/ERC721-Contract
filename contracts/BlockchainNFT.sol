// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BlockchainNFT is ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;
    uint256 public maxSupply = 3;

    bool public publicMintAllow = false;
    bool public privateMintAllow = false;

    mapping(address => bool) public isAllowed;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Blockchain", "BCK") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/";
    }

    //Give allowance to privateMint
    function setAllowance(address _user) public onlyOwner {
        isAllowed[_user] = !isAllowed[_user];
    }

    function getAllowance(address _user) public view returns (bool) {
        return isAllowed[_user];
    }

    //Modify mint state (close or open)
    function editMints(uint _public0private1) external onlyOwner {
        require(
            _public0private1 == 0 || _public0private1 == 1,
            "Wrong command"
        );
        if (_public0private1 == 0) {
            publicMintAllow = !publicMintAllow;
        } else if (_public0private1 == 1) {
            privateMintAllow = !privateMintAllow;
        }
    }

    function withdraw(address _addr) external onlyOwner {
        uint256 balance = address(this).balance; //get balance from this contract
        payable(_addr).transfer(balance); //transfer to _addr
    }

    //Mint for the private list
    function privatetMint() public payable {
        require(getAllowance(msg.sender), "You are not allowed to mint"); //check if msg.sender is part of the privateList
        require(privateMintAllow, "Private mint closed"); //require the mint still open
        require(msg.value >= 0.001 ether, "Not enough funds"); //require the value is 0.001 or more ether
        _mint();
    }

    //Mint for the public
    function publicMint() public payable {
        require(publicMintAllow, "Public mint closed"); //require the mint still open
        require(msg.value >= 0.01 ether, "Not enough funds"); //require the value is 0.01 or more ether
        _mint();
    }

    function _mint() internal {
        require(totalSupply() < maxSupply, "Sold out"); //check if there is still supply
        require(balanceOf(msg.sender) == 0, "You can only have 1 NFT"); //if I just want to allow 1 NFT per user
        uint256 tokenId = _tokenIdCounter.current(); //current state of counter
        _tokenIdCounter.increment(); //increase tokenId (by 1)
        _safeMint(msg.sender, tokenId); //mint
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
