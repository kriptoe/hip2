// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol"; // To use the Strings library

contract HIP2_NFT is ERC721, Ownable {
    using Strings for uint256; // To convert uint256 to string
    uint256 public rolling_price = .001 ether;
    uint256 public currentTokenId;             // This tracks the total number of minted NFTs
    uint256 public lastSalePrice;
    string public scrollMessage = "Chameleon Club - onchain NFT with hyperlquidity";
    // Constructor now includes the owner address
    constructor() ERC721("Klubb Kameleon", "A Hip2 NFT") Ownable(msg.sender) {}

    function mint() public payable  {
        require(msg.value == rolling_price, "Incorrect mint price");
        lastSalePrice = rolling_price;
        increasePrice();
        currentTokenId++;
        _mint(msg.sender, currentTokenId);
    }

    // Function to increase price by 0.003%
    function increasePrice() internal {
        rolling_price = rolling_price * 100003 / 100000; // Increase price by 0.003%
    }

    // Function to decrease price by 0.003%
    function decreasePrice() internal {
        rolling_price = rolling_price * 100000 / 100003; // Reverse the increase
    }

    // Function to increase price by 0.003% on each sale
    function getPrice() public view returns (uint256){
        return rolling_price ; // Increase price by 0.003%
    }

    // Function to increase price by 0.003% on each sale
    function getSalePrice() public view returns (uint256){
        return (rolling_price * 100000 / 100003 ); // Increase price by 0.003%
    }

    // Function to sell and burn an NFT and reimburse the owner
    function sellNFT(uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(owner == msg.sender, "You must own the NFT to burn it");
        decreasePrice();
        _burn(tokenId); // Burn the NFT  
        // Reimburse the owner with the current price
        payable(owner).transfer(rolling_price);
}


    function tokenURI(uint256 tokenId) public view override returns (string memory) {

        string memory svg = generateSVG(tokenId, scrollMessage, address(this).balance/ 1 ether);
        string memory image = string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(bytes(svg))));

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "SVG NFT #', 
                        tokenId.toString(),  // Convert tokenId to string using the Strings library
                        '", "description": "An on-chain SVG NFT", "image": "', 
                        image, 
                        '"}'
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

function generateSVG(uint256 tokenId, string memory scrMessage, uint bal) internal pure returns (string memory) {
    string memory svg = string(
        abi.encodePacked(
            "<svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' height='400' width='400'>",
            "<rect x='0' y='0' width='100%' height='100%' fill='#000000' rx='25' ry='25'/>", // Black background
            "<text x='50%' y='20%' dominant-baseline='middle' text-anchor='middle' fill='#00FFFF' font-size='30' font-family='Arial'>",
            "Chameleon Klubb", // Heading text
            "</text>",
            "<text x='50%' y='35%' dominant-baseline='middle' text-anchor='middle' fill='#FFFFFF' font-size='16' font-family='Arial'>",
            "A pretty good NFT", // Subheading text
            "</text>",
            "<text x='50%' y='50%' dominant-baseline='middle' text-anchor='middle' fill='#FFFFFF' font-size='12' font-family='Arial'>",
            "NFT #", tokenId.toString(), // Display token ID at the bottom
            "</text>",
           "<text x='50%' y='60%' dominant-baseline='middle' text-anchor='middle' fill='#FFFFFF' font-size='12' font-family='Arial'>",
            "Contract Balance : ", bal.toString(), // Display token ID at the bottom
            " hype</text>"
            // Scrolling text message
            "<text x='0%' y='75%' fill='#FF00FF' font-size='20' font-family='Arial'>",
            scrMessage,
            "<animateTransform attributeName='transform' type='translate' from='500 0' to='-500 0' dur='10s' repeatCount='indefinite' />",
            "</text>",
            "</svg>"
        )
    );

    return svg;
}


        // Function to allow the owner to withdraw the collected funds
    function setMessage(string memory str) public onlyOwner {
        scrollMessage= str;
    }

        // Function to allow the owner to withdraw the collected funds
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner()).transfer(balance);
    }

    // Function to accept Ether transfers directly to the contract
    receive() external payable {
    // The contract can receive Ether, and the Ether will be stored in its balance.
}

}

