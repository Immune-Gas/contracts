// contracts/ISpender.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IManager {
    function validate(address _token, address _function, address _feeReceiver, uint256 _fee) view external returns (bool);

    function addNewToken(address _token, address _function, uint256 _fee, string memory _funtionName) external returns (bool);

    function removeToken(address _token) external returns (bool);

    function getTokenFee(address _token, address _function) external view returns (uint256 _fee);

    function setTokenFee(address _token, address _function, uint256 _fee, string memory _funtionName) external returns (bool);

    function withdrawToken(address _token, address _to, uint256 _value) external returns (bool);

    function withdraw(address payable _to, uint256 _value) external returns (bool);
}