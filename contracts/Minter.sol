// contracts/Minter.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/IManager.sol";

contract Minter is AccessControl, ERC2771Context {

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    address public factoryAddress;
    address public tokenFunc;
    address public managerAddr;

    mapping(address => uint256) public mintableTokens;
    mapping(address => bool) public minted;

    event TokenMinted(address indexed token, address referee,  address indexed minter, uint256 value);

    constructor(
        MinimalForwarder _forwarder
    ) ERC2771Context(address(_forwarder)) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setFactoryAddress(
        address _factoryAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        factoryAddress = _factoryAddress;
    }

    function setTokenFunc(
        address _tokenFunc
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        tokenFunc = _tokenFunc;
    }
    
    function managerAddress(
        address _managerAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        managerAddr = _managerAddress;
    }

    function setMintValue(
        address _mintableToken, 
        uint256 _mintValue
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        mintableTokens[_mintableToken] = _mintValue;
    }

    function mint(
        address _mintableToken, 
        address _supportedToken
    ) external {
        uint256 mintableValue = mintableTokens[_mintableToken];
        require(mintableValue > 0, "Token is not mintable");
        require(_supportedToken != address(0), "Invalid supportedToken");

        address _minter =  _msgSender();

        require(!minted[_minter], "Minter has already minted");
        minted[_minter] = true;

        address minterGaslessAddress = IFactory(factoryAddress).getGaslessAddr(_minter, 0);
        uint256 minimumBalance = (IManager(managerAddr).getTokenFee(_supportedToken, tokenFunc) * 2);
        require(minimumBalance > 0, "Invalid supported token");
        IERC20 supportedTokenContract = IERC20(_supportedToken);
        require(supportedTokenContract.balanceOf(minterGaslessAddress) > minimumBalance, "Insufficient supported token balance for minter");
        IERC20 mintableTokenContract = IERC20(_mintableToken);
        mintableTokenContract.transfer(minterGaslessAddress, mintableValue);

        emit TokenMinted(_mintableToken, address(0),  _minter, mintableValue);

    }

    // Referal mint not implemented yet.


    function _msgSender() internal view override(Context, ERC2771Context) returns(address) {
        return ERC2771Context._msgSender();
    } 

    function _msgData() internal view override(Context, ERC2771Context) returns(bytes calldata) 
    {
        return ERC2771Context._msgData();
    }
}