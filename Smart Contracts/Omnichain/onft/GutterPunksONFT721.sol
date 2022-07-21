// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8;

import "./ONFT721.sol";

/// @title Interface of the UniversalONFT standard
contract GutterPunksONFT721 is ONFT721 {
    string private baseURI;

    /// @notice Constructor for the GutterPunksONFT721
    /// @param _layerZeroEndpoint handles message transmission across chains
    constructor(string memory baseURI_, address _layerZeroEndpoint) ONFT721("Gutter Punks", "GP", _layerZeroEndpoint) {
		baseURI = baseURI_;
    }	

    function setBaseURI(string memory URI) external onlyOwner {
        baseURI = URI;
    }

    function donate() external payable {
        // thank you
    }

    // This allows the devs to receive kind donations
    function withdraw(uint256 amt) external onlyOwner {
        (bool sent, ) = payable(owner()).call{value: amt}("");
        require(sent, "Failed to withdraw Ether");
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}