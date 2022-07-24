// SPDX-License-Identifier: MIT

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

pragma solidity ^0.8.9;



/**
 * @title Airdropped ERC721 Token
 * @author The Gutter Punks team.
 *
 */
contract StonedPunks is ERC721, Ownable {
    using Address for address;
    using Strings for uint256;


    string internal _baseTokenURI;
    string internal _contractURI;

    uint256 internal _totalSupply;
    string public constant TOKEN_URI_EXTENSION = ".json";
    uint256 public constant BASE_OFFSET = 0;
    uint256 public constant MAX_SUPPLY = 1000;
	
	bool internal _finalize = false; 
	address internal _burnAddress = 0x000000000000000000000000000000000000dEaD;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;
	
	address _baseAddress;
    Base721 _baseTarget;


    constructor(address baseAddress_, string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        _baseAddress = baseAddress_;
        _baseTarget = Base721(_baseAddress);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
		
		string memory baseURI = _baseTokenURI;
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString(), TOKEN_URI_EXTENSION))
            : "";
    }

    function setURI(string calldata baseURI) external onlyOwner {
		require(!_finalize, "Cannot edit base URI after finalized."); 
        _baseTokenURI = baseURI;
    }

    function setFinalize(bool finalize) external onlyOwner {
		require(!_finalize, "Cannot change finalize after finalized."); 
        _finalize = finalize;
    }

    function airdrop(address[] calldata recipients) external onlyOwner {
		require(!_finalize, "Cannot airdrop after finalized."); 
        uint256 startingSupply = _totalSupply;
		require(startingSupply + recipients.length <= MAX_SUPPLY, "Cannot airdrop more than max supply.");
		

        // Update the total supply.
        _totalSupply = startingSupply + recipients.length;

        // Note: First token has ID #1.
        for (uint256 i = 0; i < recipients.length; i++) {
            _mint(recipients[i], startingSupply + i + 1);
        }
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal override {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        address approved = _tokenApprovals[tokenId];
        return approved;
    }

    function _exists(uint256 tokenId) internal view override returns (bool) {
		if(tokenId > _totalSupply) { return false; }
		else if(_owners[tokenId] == _burnAddress) { return false; }
		else if(_owners[tokenId] != address(0)) { return true; }
		else { 
			return _baseTarget.ownerOf((tokenId+BASE_OFFSET)) != address(0);
		}
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal override {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view override returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || _tokenApprovals[tokenId] == spender || isApprovedForAll(owner, spender));
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal override {
        _transfer(from, to, tokenId);
        require(checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        require(_ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);
       
        unchecked { 
           _owners[tokenId] = to;
        }

        emit Transfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override {
        address owner = ownerOf(tokenId);
		address burnAddress = _burnAddress;
        require(owner == _msgSender(), "Must own token to burn.");

        _beforeTokenTransfer(owner, burnAddress, tokenId);

        // Clear approvals
        _approve(address(0), tokenId);
		_owners[tokenId] = burnAddress;

        emit Transfer(owner, burnAddress, tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {}

    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function _ownerOf(uint256 tokenId) internal view returns (address) {
        address owner = _owners[tokenId];
        if(owner == address(0) && tokenId <= _totalSupply) {
            try _baseTarget.ownerOf((tokenId+BASE_OFFSET)) returns (address result) { owner = result; } catch { owner = address(0); }
        }
        return owner;
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        uint256 balance = 0;
        for(uint256 i = 1;i <= MAX_SUPPLY;i++) {
           if(_ownerOf(i) == owner) { balance++; }
        }
        return balance;
    }

    function _mint(address to, uint256 tokenId) internal override {
        emit Transfer(address(this), to, tokenId);
    }

    function contractURI() external view returns (string memory) {
        return _contractURI;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
	
	function parentTokenTransferred(address from, address to, uint256 tokenId) public virtual { 
		require(_msgSender() == _baseAddress, "This function must be called by the airdrop token parent.");
		// Only update token owner if current owner is unset
        if(tokenId >= 0 && tokenId <= 1000) {
            tokenId = tokenId - BASE_OFFSET; // offset for base token # if necessary
            if(_owners[tokenId] == address(0)) { _owners[tokenId] = from; }
        }
	}
}

abstract contract Base721 { 
    function ownerOf(uint256 tokenId) public view virtual returns (address);
    function balanceOf(address owner) public view virtual returns (uint256);
    function getApproved(uint256 tokenId) public view virtual returns (address);
    function isApprovedForAll(address owner, address operator) public view virtual returns (bool);
}