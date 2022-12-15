// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./ERC721A.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Sample is ERC721A, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;

    // CID link
    string public baseTokenURI = "";
    // Whitelist root
    bytes32 public whitelistMerkleRoot = 0xae864387170a03d9457fcf5c21017d276f69925e4e7b4dc08f8ff993f2c9a455;
    bool isAllow;
    uint16 public constant MAX_SUPPLY = 5555;
    uint256 public constant MAX_PER_MINT = 2;
    uint256 public PRICE_PER_NFT = 0.045 ether;
    string public MINT_TYPE = "presale";
    address public DEV_WALLET = 0xb04bb7A6F911d0599543BA8454e2BFF93D95369a;

    constructor() ERC721A("Sample", "DA") {}

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    //  Set the base uri for token
    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    //  Set the merkle tree for whitelist users
    function setWhitelistMerkleRoot(bytes32 _whitelistMerkleRoot)
        public
        onlyOwner
    {
        whitelistMerkleRoot = _whitelistMerkleRoot;
    }
    
    // Allow flag for withdraw
    function setIsAllow(bool _isAllow) public onlyOwner {
        isAllow = _isAllow;
    }

    //  Set the price per NFT
    function setPricePerNft(uint256 _pricePerNft) public onlyOwner {
        PRICE_PER_NFT = _pricePerNft;
    }

    //  Set the mint type
    function setMintType(string memory _mintType) external onlyOwner {
        if (
            keccak256(abi.encodePacked((_mintType))) ==
            keccak256(abi.encodePacked(("presale")))
        ) {
            MINT_TYPE = _mintType;
            setPricePerNft(0.045 ether);
        } else if (
            keccak256(abi.encodePacked((_mintType))) ==
            keccak256(abi.encodePacked(("public")))
        ) {
            MINT_TYPE = _mintType;
            setPricePerNft(0.06 ether);
        } else {
            revert("No valid mint type.");
        }
    }

    // Calculate the price
    function price(uint256 _count) public view returns (uint256) {
        return PRICE_PER_NFT.mul(_count);
    }

    // Get MINT_TYPE
    function getMintType() public view returns (string memory) {
        return MINT_TYPE;
    }

    //  Private sale with whitelist
    function privateMint(bytes32[] calldata _merkleProof, uint256 _count ) public payable {
        bytes memory tempEmptyStringTest = bytes(MINT_TYPE);
        bytes32 leaf;
        leaf = keccak256(abi.encodePacked(msg.sender));
        uint256 totalMinted = _tokenIdTracker.current();

        require(
            keccak256(abi.encodePacked((MINT_TYPE))) !=
                keccak256(abi.encodePacked(("public"))),
            "Public sale period!"
        );
        require(
            msg.sender == tx.origin,
            "Mint from other contract not allowed."
        );
        require(tempEmptyStringTest.length > 0, "Mint type isn't set yet.");
        require(whitelistMerkleRoot.length > 0, "Whitelist isn't provided.");
        require(
            MerkleProof.verify(_merkleProof, whitelistMerkleRoot, leaf),
            "Not whitelisted address."
        );
        require(totalMinted.add(_count) < MAX_SUPPLY, "Not enough NFTs");
        require(
            _count > 0 && _count <= MAX_PER_MINT,
            "Cannot mint specified number of NFTs."
        );
        require(
            msg.value >= PRICE_PER_NFT.mul(_count),
            "Not enough ether to purchase NFTs."
        );
        require(
            keccak256(abi.encodePacked((MINT_TYPE))) ==
                keccak256(abi.encodePacked(("presale"))),
            "Public sale period!."
        );
        require(
            msg.sender == tx.origin,
            "Mint from other contract not allowed."
        );
        for (uint256 i = 0; i < _count; i++) {
            _safeMint(msg.sender, 1);
        }
    }


    //  Public sale without whitelist
    function publicMint(uint256 _count) public payable {
        uint256 totalMinted = _tokenIdTracker.current();

        require(totalMinted.add(_count) < MAX_SUPPLY, "Not enough NFTs");
        require(
            _count > 0 && _count <= MAX_PER_MINT,
            "Cannot mint specified number of NFTs."
        );
        require(
            msg.value >= PRICE_PER_NFT.mul(_count),
            "Not enough ether to purchase NFTs."
        );
        require(
            keccak256(abi.encodePacked((MINT_TYPE))) ==
                keccak256(abi.encodePacked(("public"))),
            "Presale period!."
        );
        require(
            msg.sender == tx.origin,
            "Mint from other contract not allowed."
        );
        for (uint256 i = 0; i < _count; i++) {
            _safeMint(msg.sender, 1);
        }
    }

    // Withdraw money
    function withdraw(address _to) external onlyOwner {
        require(
            isAllow == true,
            "Withdraw is not allowed since nfts are sold out."
        );
        uint256 balance = address(this).balance;

        // Send 1.6 % to developer's wallet address (1.6 = 16 / 1000)
        payable(DEV_WALLET).transfer(balance * 16 / 1000);
        // Send 98.4 % to  "_to" wallet address ( 100 - 1.6 = 98.4 %, 0.984 = 984 / 1000)
        payable(_to).transfer(balance * 984 / 1000 );
    }
}