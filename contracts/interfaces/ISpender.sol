// contracts/ISpender.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ISpender {
    function spend(address _delegate, bytes calldata _data) external returns (bool success);
    
    function spendWithFee(address _token, address _feeReceiver, uint256 _fee, address _delegate, bytes calldata _data) external returns (bool success);

    function demolish(address payable _to) external;
}