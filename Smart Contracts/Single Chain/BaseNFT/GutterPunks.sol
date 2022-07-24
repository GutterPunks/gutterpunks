
// SPDX-License-Identifier: MIT

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import './ERC721A.sol';

/**

                               , &@@@@@@@/  @@@@@   *@@@@@@@@       @@@@@@@&  @@@/ (@@@   *                             
                  @@@, %@@@@@@@@ &/ %@@&    @@@     .@@@  @@@      /@@&  @@@  @@@  @@@*  (@@@ .@@@   @@@.               
      ..     @@@/ .@@@     @@@       @@@    @@@@@*   @@@@@@,       %@@@@@@@&  @@@  @@@   @@@@ @@@&  *@@@  @@@@ .@@@/    
  ,@@@@@@@(   @@@  @@@,    *@@@      @@@    #@@#     @@@  @@@      @@@/..    /@@@ ,@@@   @@@@@@@@   @@@(@@@.  @@@@%@@@# 
  ,@@@  &.    (@@@  @@@     @@@      &@@/   .@@@./#  @@@  @@@      @@@.      %@@/ &@@.  %@@@(@@@&  *@@@@@     @@@@  /@  
   &@@@ @@@@   @@@  @@@.    #@@#      @@@    @@@@@&  #(/  ***      /#%        *@@@@@.   @@@  @@@   @@@ @@@      .@@@#   
    @@@, #@@@   @@@@@@@                                                                      #@&  (@@%  @@@ @@@   %@@(  
     @@@@@@@@                                                                                            ,%* @@@@@@@@   
                                                          *@@@@@#                                                       
                                                  .@@@@@@@@@@@@@@@@@@@@&                                                
                                               @@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                            
                                            @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#                                         
                                          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(                                       
                                        ,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                      
                                       *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                     
                                       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&                                    
                                      #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                    
                                        . &@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                                    
                                          &&&&&&&&&&&&&&&&#  &&&&%  &&&&( *&&&&  &                                      
                                          ,&&&&&&&&&&&&&&&&&.  ,   &&&&&&&,  .  &&& .                                   
                                      &&&&&&&&&&&&&&&&&&&&&&&&%   &&&&&&&&&&    &&&.                                    
                                     o/ & &&&&&&&&&&&&&&&&&&&#  &.  &&&&&&&  &&#  /#                                    
                                    . ( /&  &&&(&&&&&&&&&&&&   &&&&&  &&&& *&&&&&&&#                                    
                                         %(*,(*.(%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&.                                    
                                     .%#&  #, *(((((%&&&&&&&&&&&&&&&&&&&&&&&,  #&&( .                                   
                                      .*(( &&&  ((((((((&&&&&&&&&&&&&&&&&&&  .   .                                      
                                .    *&@@% *&&&&  .(#(#(#(#(##%&&&&&&&&&&%((##   @@#                                    
                            *@@@@@@@@@@@@@   *&&&&&  .((((((((((#((((((((((((#  .     /@@,                              
                          @@ .@@* @@@@. @@@@@@@           (#((((#((((((((#/                , .                          
                         @@ #@@@@@.  %@@@. @@@@@#      .                   /@@@                                         
                        @@@ &@@@@@  %@(    #@@@@@  @@@@@@   ,@@@@@@@@@@@@# *@@@@                                        
                       (.   (@@@   @@       @@@@@@     ,*   ,.           .  ,@@@@                                       
                             @@   @@        @@@@@@ @@@@@@   @@@@@@@@@@@@@@@  &@@@(                                      
                             /   #@         @@@@@@ .*%@@@  %@@@@&(,..,/%&@@   @@@@                                      
                                                                                                                       

*/

pragma solidity ^0.8.9;


/**
 * @title Gutter Punks contract.
 * @author The Gutter Punks team.
 *
 * @notice Implements a fair and random NFT distribution.
 *
 *  Additional features include:
 *   - Merkle-tree whitelist with customizable number of mints per address.
 *   - On-chain support for a pre-reveal placeholder image.
 *   - Contract-level metadata.
 *   - Finalization of metadata to prevent further changes.
 */
contract GutterPunks is ERC721A, Ownable {
    using Strings for uint256;

    event SetPresaleMerkleRoot(bytes32 root);
    event SetProvenanceHash(string provenanceHash);
    event SetPresaleIsActive(bool presaleIsActive);
    event SetSaleIsActive(bool saleIsActive);
    event SetIsRevealed(bool isRevealed);
    event Finalized();
    event SetCurrentPrice(uint256 currentPrice);
    event SetRoyaltyInfo(address royaltyRecipient, uint256 royaltyAmountNumerator);
    event SetBaseURI(string baseURI);
    event SetPlaceholderURI(string placeholderURI);
    event SetContractURI(string contractURI);
    event Withdrew(uint256 balance);

    uint256 public constant MAX_SUPPLY = 9999;
    uint256 public constant RESERVED_SUPPLY = 225;
	uint256 public _presaleExtras = 3000;
    string public constant TOKEN_URI_EXTENSION = ".json";
    uint256 public constant ROYALTY_AMOUNT_DENOMINATOR = 1e18;
    bytes4 private constant INTERFACE_ID_ERC2981 = 0x2a55205a;

    /// @notice The root of the Merkle tree with addresses allowed to mint in the presale.
    bytes32 public _presaleMerkleRoot;

    /// @notice Hash which commits to the content, metadata, and original sequence of the NFTs.
    string public _provenanceHash;

    /// @notice The current price to mint one Gutter Punk
    uint256 public _currentPrice = 0.050 ether;

    /// @notice Controls whether minting is allowed via the presale mint function.
    bool public _presaleIsActive = false;

    /// @notice Controls whether minting is allowed via the regular mint function.
    bool public _saleIsActive = false;

    /// @notice Whether the placeholder URI should be returned for all tokens.
    bool public _isRevealed = false;

    /// @notice Whether further changes to the token URI have been disabled.
    bool public _isFinalized = false;

    /// @notice The recipient of ERC-2981 royalties.
    address public _royaltyRecipient;

    /// @notice The royalty rate for ERC-2981 royalties, as a fraction of ROYALTY_AMOUNT_DENOMINATOR.
    uint256 public _royaltyAmountNumerator;

    /// @notice The number of presale mints completed by address.
    mapping(address => uint256) public _numPresaleMints;

    /// @notice Array of contract addresses to be notified when base-token is transferred.
    address[] public airdrops;

    /// @notice Whether the address used the voucher amount specified in the Merkle tree.
    ///  Note that we assume each address is only included once in the Merkle tree.
    mapping(address => bool) public _usedVoucher;

    string internal _baseTokenURI;
    string internal _placeholderURI;
    string internal _contractURI;

    modifier notFinalized() {
        require(
            !_isFinalized,
            "Metadata is finalized"
        );
        _;
    }

    constructor(
        string memory placeholderURI
    ) ERC721A("Gutter Punks", "GP") {
        _placeholderURI = placeholderURI;
    }
	
    function _startTokenId() internal view override virtual returns (uint256) {
        return 1;
    }

    function setPresaleMerkleRoot(bytes32 root) external onlyOwner {
        _presaleMerkleRoot = root;
        emit SetPresaleMerkleRoot(root);
    }

    function setProvenanceHash(string calldata provenanceHash) external onlyOwner notFinalized {
        _provenanceHash = provenanceHash;
        emit SetProvenanceHash(provenanceHash);
    }

    function setPresaleIsActive(bool presaleIsActive) external onlyOwner {
        _presaleIsActive = presaleIsActive;
        emit SetPresaleIsActive(presaleIsActive);
    }

    function setSaleIsActive(bool saleIsActive) external onlyOwner {
        _saleIsActive = saleIsActive;
        emit SetSaleIsActive(saleIsActive);
    }

    function setCurrentPrice(uint256 currentPrice) external onlyOwner {
        _currentPrice = currentPrice;
        emit SetCurrentPrice(currentPrice);
    }

    function setIsRevealed(bool isRevealed) external onlyOwner notFinalized {
        _isRevealed = isRevealed;
        emit SetIsRevealed(isRevealed);
    }

    function setPresaleExtras(uint256 presaleExtras) external onlyOwner {
		_presaleExtras = presaleExtras;
    }

    function finalize() external onlyOwner notFinalized {
        require(
            _isRevealed,
            "Must be revealed to finalize"
        );
        _isFinalized = true;
        emit Finalized();
    }

    function setRoyaltyInfo(address royaltyRecipient, uint256 royaltyAmountNumerator) external onlyOwner {
        _royaltyRecipient = royaltyRecipient;
        _royaltyAmountNumerator = royaltyAmountNumerator;
        emit SetRoyaltyInfo(royaltyRecipient, royaltyAmountNumerator);
    }

    function setBaseURI(string calldata baseURI) external onlyOwner notFinalized {
        _baseTokenURI = baseURI;
        emit SetBaseURI(baseURI);
    }

    function setPlaceholderURI(string calldata placeholderURI) external onlyOwner {
        _placeholderURI = placeholderURI;
        emit SetPlaceholderURI(placeholderURI);
    }

    function setContractURI(string calldata newContractURI) external onlyOwner {
        _contractURI = newContractURI;
        emit SetContractURI(newContractURI);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
        emit Withdrew(balance);
    }

    function mintReservedTokens(address recipient, uint256 numToMint) external onlyOwner {
        require(
            _totalMinted() + numToMint <= RESERVED_SUPPLY,
            "Mint would exceed reserved supply"
        );

        _mint(recipient, numToMint);
    }

    /**
     * @notice Called by users to mint from the presale.
     */
    function mintPresale(
        uint256 numToMint,
        uint256 maxMints,
        uint256 voucherAmount,
        bytes32[] calldata merkleProof
    ) external payable {
        require(
            _presaleIsActive,
            "Presale not active"
        );

        // The Merkle tree node contains: (address account, uint256 maxMints, uint256 voucherAmount)
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, maxMints, voucherAmount));

        // Verify the mint params are part of the Merkle tree, given the Merkle proof.
        require(
            MerkleProof.verify(merkleProof, _presaleMerkleRoot, leaf),
            "Invalid Merkle proof"
        );

        // Require that the minter does not exceed their max allocation given by the Merkle tree.
        uint256 newNumPresaleMints = _numPresaleMints[msg.sender] + numToMint;
		uint256 presaleExtrasNeeded = 0;
		if(newNumPresaleMints > maxMints) { 
			presaleExtrasNeeded = newNumPresaleMints - maxMints;
			require(
				presaleExtrasNeeded <= _presaleExtras,
				"Presale mints exceeded"
			);
		}

        // Use the voucher amount if it wasn't previously used.
        uint256 remainingVoucherAmount = 0;
        if (voucherAmount != 0 && !_usedVoucher[msg.sender]) {
            remainingVoucherAmount = voucherAmount;
            _usedVoucher[msg.sender] = true;
        }

        // Update storage (do this before minting as mint recipients may have callbacks).
        _numPresaleMints[msg.sender] = newNumPresaleMints;
		if(presaleExtrasNeeded > 0) { _presaleExtras -= presaleExtrasNeeded; }

        // Mint tokens, checking for sufficient payment and supply.
        _mintInner(numToMint, remainingVoucherAmount);
    }

    /**
     * @notice Called by users to mint from the main sale.
     */
    function mint(uint256 numToMint) external payable {
        require(
            _saleIsActive,
            "Sale not active"
        );

        // Mint tokens, checking for sufficient payment and supply.
        _mintInner(numToMint, 0);
    }

    /**
     * @notice Implements ERC-2981 royalty info interface.
     */
    function royaltyInfo(uint256 /* tokenId */, uint256 salePrice) external view returns (address, uint256) {
        return (_royaltyRecipient, salePrice * _royaltyAmountNumerator / ROYALTY_AMOUNT_DENOMINATOR);
    }

    function contractURI() external view returns (string memory) {
        return _contractURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (!_isRevealed) {
            return _placeholderURI;
        }

        string memory baseURI = _baseTokenURI;
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString(), TOKEN_URI_EXTENSION))
            : "";
    }
    
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return (
            interfaceId == INTERFACE_ID_ERC2981 ||
            super.supportsInterface(interfaceId)
        );
    }

    function getCurrentPrice() public view returns (uint256) {
        return _currentPrice;
    }

    function getCost(uint256 numToMint) public view returns (uint256) {
        return numToMint * getCurrentPrice();
    }

    /**
     * @dev Mints `numToMint` tokens to msg.sender.
     *
     *  Reverts if the max supply would be exceeded.
     *  Reverts if the payment amount (`msg.value`) is insufficient.
     */
    function _mintInner(uint256 numToMint, uint256 voucherAmount) internal {
        require(
            _totalMinted() + numToMint <= MAX_SUPPLY,
            "Mint would exceed max supply"
        );
        require(
            getCost(numToMint) <= msg.value + voucherAmount,
            "Insufficient payment"
        );

        _mint(msg.sender, numToMint);
    }


    function addAirdropContract(address contAddress) external onlyOwner { 
        for(uint256 i = 0;i < airdrops.length;i++) {
            if(airdrops[i] == contAddress) return;
        }
        airdrops.push(contAddress);
    }

    function removeAirdropContract(address contAddress) external onlyOwner {
        uint256 contIndex = 0;
        bool found = false;
        for(uint256 i = 0;i < airdrops.length;i++) {
            if(airdrops[i] == contAddress) {
                found = true;
                contIndex = i;
                break;
            }
        }
        require(found, "Airdrop contract not in list.");
        if(contIndex != (airdrops.length - 1)) {
            airdrops[contIndex] = airdrops[airdrops.length - 1];
        }
        airdrops.pop();
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal override {
        for(uint256 i = 0;i < airdrops.length;i++) {
            AirdropToken adt = AirdropToken(airdrops[i]);
            for(uint256 j = 0;j < quantity;j++) {
                adt.parentTokenTransferred(from, to, startTokenId + j);
            }
        }
    }
}

abstract contract AirdropToken {
    function parentTokenTransferred(address from, address to, uint256 tokenId) virtual public;
}