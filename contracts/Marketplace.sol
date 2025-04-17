// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Marketplace is ERC721 {
    struct Listing {
        uint256 price;
        address seller;
    }

    uint256 public constant FEE_PERCENTAGE = 10;

    mapping(uint256 => string) private s_tokenURIs;
    mapping(uint256 => Listing) private s_listings;
    uint256 private s_counter;
    address public feeRecipient;

    event NftCreated(uint256 indexed tokenId, string tokenURI, address creator);
    event NftListed(uint256 indexed tokenId, uint256 price, address seller);
    event NftBought(uint256 indexed tokenId, uint256 price, address buyer);
    event ListingCancelled(uint256 indexed tokenId);

    constructor() ERC721("Marketplace", "MP") {
        feeRecipient = msg.sender;
    }

    function createNft(string memory tokenURI_) public {
        _safeMint(msg.sender, s_counter);
        s_tokenURIs[s_counter] = tokenURI_;
        emit NftCreated(s_counter, tokenURI_, msg.sender);
        s_counter += 1;
    }

    function listNft(uint256 tokenId, uint256 price) public {
        require(price > 0, "Price must be greater than 0");
        transferFrom(msg.sender, address(this), tokenId);
        s_listings[tokenId] = Listing(price, msg.sender);
        emit NftListed(tokenId, price, msg.sender);
    }

    function buyNft(uint256 tokenId) public payable {
        Listing memory listing = s_listings[tokenId];
        require(listing.price > 0, "NFT not listed");
        require(msg.value == listing.price, "Incorrect payment amount");

        uint256 fee = (listing.price * FEE_PERCENTAGE) / 100;
        uint256 sellerAmount = listing.price - fee;

        transferFrom(address(this), msg.sender, tokenId);
        payable(feeRecipient).transfer(fee);
        payable(listing.seller).transfer(sellerAmount);
        
        delete s_listings[tokenId];
        emit NftBought(tokenId, listing.price, msg.sender);
    }

    function cancelListing(uint256 tokenId) public {
        Listing memory listing = s_listings[tokenId];
        require(listing.price > 0, "NFT not listed");
        require(listing.seller == msg.sender, "Not the seller");

        transferFrom(address(this), msg.sender, tokenId);
        delete s_listings[tokenId];
        emit ListingCancelled(tokenId);
    }

    function getListing(uint256 tokenId) public view returns (Listing memory) {
        return s_listings[tokenId];
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return s_tokenURIs[tokenId];
    }
}
