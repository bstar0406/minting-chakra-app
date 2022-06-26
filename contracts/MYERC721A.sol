
// SPDX-License-Identifier: GPL-3.0



/*


                                                                                                               
,--------.,--.                  ,---.  ,--.       ,--.             ,-----.,--.   ,--.,--------.,------.        
'--.  .--'|  ,---.  ,---.      /  O  \ |  | ,---. |  ,---.  ,--,--.|  |) /_\  `.'  / '--.  .--'|  .---' ,---.  
   |  |   |  .-.  || .-. :    |  .-.  ||  || .-. ||  .-.  |' ,-.  ||  .-.  \'.    /     |  |   |  `--, (  .-'  
   |  |   |  | |  |\   --.    |  | |  ||  || '-' '|  | |  |\ '-'  ||  '--' /  |  |      |  |   |  `---..-'  `) 
   `--'   `--' `--' `----'    `--' `--'`--'|  |-' `--' `--' `--`--'`------'   `--'      `--'   `------'`----'  
                                           `--'                                                                
,--.                 ,---.                   ,--.  ,--.                                                        
|  |-.,--. ,--.     /  O  \ ,--,--,--.,--.--.`--',-'  '-. ,--,--.                                              
| .-. '\  '  /     |  .-.  ||        ||  .--',--.'-.  .-'' ,-.  |                                              
| `-' | \   '      |  | |  ||  |  |  ||  |   |  |  |  |  \ '-'  |                                              
 `---'.-'  /       `--' `--'`--`--`--'`--'   `--'  `--'   `--`--'                                              
      `---'                                                                                                    

PopElon
WWW..THEALPHABYTES.COM
https://discord.gg/pSBMtAttbJ
www.twitter.com/artbyamrita


*/



// File: contracts/AlphaBytes.sol


pragma solidity >=0.7.0 <0.9.0;

import "./Address.sol";
import "./Context.sol";
import "./ERC165.sol";
import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./IERC165.sol";
import "./IERC721.sol";
import "./IERC721Enumerable.sol";
import "./IERC721Metadata.sol";
import "./IERC721Receiver.sol";
import "./AlphaBytes.sol";
import "./Ownable.sol";
import "./Strings.sol";
import "./ERC20.sol";


contract AlphaBytes is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string public baseURI;
  string public baseExtension = ".json";
  string public notRevealedUri;
  uint256 public cost = 1.0 ether;
  uint256 public maxSupply = 145;
  uint256 public maxMintAmount = 10;
  uint256 public nftPerAddressLimit = 10;
  bool public paused = false;
  bool public revealed = false;
  bool public onlyWhitelisted = true;
  mapping(address => bool) public whitelistedAddresses;
  mapping(address => uint256) public addressMintedBalance;


  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // public
  function mint(uint256 _mintAmount) public payable {
    require(!paused, "the contract is paused");
    uint256 supply = totalSupply();
    require(_mintAmount > 0, "need to mint at least 1 NFT");
    require(_mintAmount <= maxMintAmount, "max mint amount per session exceeded");
    require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

    if (msg.sender != owner()) {
        if(onlyWhitelisted == true) {
            require(isWhitelisted(msg.sender), "user is not whitelisted");
            uint256 ownerMintedCount = addressMintedBalance[msg.sender];
            require(ownerMintedCount + _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");
        }
        require(msg.value >= cost * _mintAmount, "insufficient funds");
    }
    
    for (uint256 i = 1; i <= _mintAmount; i++) {
        addressMintedBalance[msg.sender]++;
      _safeMint(msg.sender, supply + i);
    }
  }
  
  function isWhitelisted(address _user) public view returns (bool) {
    return  whitelistedAddresses[_user];
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    
    if(revealed == false) {
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //only owner
  function reveal() public onlyOwner {
      revealed = true;
  }
  
  function setNftPerAddressLimit(uint256 _limit) public onlyOwner {
    nftPerAddressLimit = _limit;
  }
  
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

//   function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
//     maxMintAmount = _newmaxMintAmount;
//   }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }
  
  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
  
  function setOnlyWhitelisted(bool _state) public onlyOwner {
    onlyWhitelisted = _state;
  }
  
  function whitelistUsers(address[] calldata _users) public onlyOwner {
    for(uint i=0;i<_users.length;i++){
        whitelistedAddresses[_users[i]]=true;
    }
  }
 function whitelistUser(address _user) public onlyOwner {
        whitelistedAddresses[_user]=true;    
  }
  function withdraw() public payable onlyOwner {

    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os);

  }
}
