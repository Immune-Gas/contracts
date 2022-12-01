// contracts/Spender.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/ISpender.sol";

contract Spender is ISpender {

    function spend(
        address _delegate, 
        bytes calldata _data
    ) external override returns (bool success) {
        require(_delegate != address(0), "Delegate address not set");
        (bool _success, ) = _delegate.delegatecall(_data);
        require(_success, "Delegate call failed");
        return true;
    }

    function spendWithFee(
        address _token, 
        address _feeReceiver, 
        uint256 _fee, 
        address _delegate, 
        bytes calldata _data
    ) external returns (bool success) {
        IERC20 token = IERC20(_token);
        token.transfer(_feeReceiver, _fee);
        return this.spend(_delegate, _data);
    }

    function demolish(address payable _to) external override {
        selfdestruct(_to);
    }
}