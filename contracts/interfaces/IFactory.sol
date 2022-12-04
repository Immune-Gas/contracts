// contracts/ISpender.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IFactory {

    // event Spend(address indexed _from, address indexed _delegate, address indexed feeReceiver, uint256 fee, uint256 salt);

    // event Addr(address indexed _addr, address indexed _sender);

    function gaslessTransfer(address _token, uint256 _salt, address _feeReceiver, uint256 _fee, address _delegate, bytes calldata _callData) external;

    function sendToken(uint256 _salt, address _delegate, bytes calldata _callData) external;

    function getGaslessAddr(address _sender, uint256 salt) view external returns(address);
}