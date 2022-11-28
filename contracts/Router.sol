// contracts/Router.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Router {

    // **** TRANSFER TOKEN ****
    function route(
        address _token, 
        address _to, 
        uint256 _value
    ) external returns (bool success) {
        IERC20 token = IERC20(_token);
        token.transfer(_to, _value);

        return true;
    }

    // **** ENCODE FUNCTION ****  
    function encode(
        address _token,
        address _to,
        uint256 _value
    )  external pure returns (bytes memory data) {
        return abi.encodeWithSignature("route(address,address,uint256", _token, _to, _value);
    }
}