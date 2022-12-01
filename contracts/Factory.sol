// contracts/Router.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";
import "./Spender.sol";

contract Factory is ERC2771Context, AccessControl {

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    event Spend(address indexed spender, address indexed delegate, address indexed feeReceiver, uint256 fee, uint256 salt);
    event Addr(address indexed spender, uint256 salt);

    constructor(
        MinimalForwarder _forwarder
    ) ERC2771Context(address(_forwarder)) {
    }

    // function setManager(address _manager) external onlyRole(OWNER_ROLE) {
    //    _grantRole(MANAGER_ROLE, _manager); 
    // }

    function gaslessTransfer(
        address _token, 
        uint256 _salt, 
        address _feeReciever, 
        uint256 _fee,
        address _delegate,
        bytes calldata _data
    ) external {
        bytes32 newSalt = keccak256(abi.encode(_msgSender(), _salt));
        Spender spender = new Spender{salt: newSalt}();

        // Include the payment manager
        spender.spendWithFee(_token, _feeReciever, _fee, _delegate, _data);
        spender.demolish(payable(_msgSender()));

        emit Spend(address(spender), _delegate, _feeReciever, _fee, _salt);

    }

    function sentToken(
        uint256 _salt,
        address _delegate,
        bytes calldata _data
    ) external {
        bytes32 newSalt = keccak256(abi.encode(_msgSender(), _salt));
        Spender spender = new Spender{salt: newSalt}();

        spender.spend(_delegate, _data);
        spender.demolish(payable(_msgSender()));

        emit Spend(address(spender), _delegate, address(0), 0, _salt); 
    }

    function getAddr(
        uint256 _salt
    ) external {
        bytes32 newSalt = keccak256(abi.encode(_msgSender(), _salt));
        Spender spender = new Spender{salt: newSalt}();

        emit Addr(address(spender), _salt);
    }

    function _msgSender() internal view override(Context, ERC2771Context) returns(address) {
        return ERC2771Context._msgSender();
    } 

    function _msgData() internal view override(Context, ERC2771Context) returns(bytes calldata) 
    {
        return ERC2771Context._msgData();
    }
}