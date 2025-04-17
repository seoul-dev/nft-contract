// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// TODO: Add Events, feeRecipient logic
contract Marketplace is  ERC721, Ownable {
    struct Listing {
        uint256 price;
        address seller;
    }

    mapping(uint256 tokenId => string) private s_tokenURIs;

    mapping(uint256 => Listing) private s_listings;

    address private feeRecipient;

    uint256 private s_counter;

    constructor() ERC721("Marketplace", "MP") Ownable(msg.sender) {

    }

    function createNft(string memory _tokenURI) public {
        _safeMint(msg.sender, s_counter);
        s_tokenURIs[s_counter] = _tokenURI;
        s_counter += 1;
    }

    function listNft(uint256 tokenId, uint256 price) public {
        require(price > 0);
        transferFrom(msg.sender, address(this), tokenId);
        s_listings[tokenId] = Listing(price, msg.sender);
    }

    function buyNft(uint256 tokenId) public payable {
        Listing memory listing = s_listings[tokenId];
        require(listing.price > 0);
        require(msg.value == listing.price);
        transferFrom(address(this), msg.sender, tokenId);
        delete s_listings[tokenId];
    }

    function cancelListing(uint256 tokenId) public {
        Listing memory listing = s_listings[tokenId];
        require(listing.price > 0);
        require(listing.seller == msg.sender);
        transferFrom(address(this), msg.sender, tokenId);
        delete s_listings[tokenId];
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return s_tokenURIs[tokenId];
    }
}
