// contracts/Manager.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
// import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";
import "./interfaces/IManager.sol";

contract Manager is AccessControl, IManager {

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    //Consider changing this
    mapping(address => mapping(address => uint256)) public tokenFee;

    mapping(address => bool) public tokens;

    event Validated(address indexed token, uint256 fee);
    event TokenAdded(address indexed token, address functionName, uint256 fee, string name);
    event TokenRemoved(address indexed token);
    event TokenUpdated(address indexed token, address func, uint256 fee, string funtionName);

    constructor () {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    modifier notReciever(address _feeReceiver) {
        require(_feeReceiver == address(this), "Manager cannot be the fee receiver");
        _;
    }

    modifier notSufficient(uint256 _fee, address _token, address _function) {
       require(_fee >= tokenFee[_token][_function], "Fee is not sufficient");
       _;
    }

    modifier notSupported(address _token) {
       require(tokens[_token], "Unsupported token");
       _;
    }

    function validate(
        address _token, 
        address _function, 
        address _feeReceiver, 
        uint256 _fee
    ) view external override 
    notReciever(_feeReceiver) 
    notSufficient(_fee, _token, _function) 
    // notSupported(_token)
    returns (bool success) {
        // require(_feeReceiver == address(this), "PaymentManager is not the fee receiver");
        // require(_fee >= adminTokensFee[_token][_function], "Fee is not sufficient");
        require(tokens[_token], "Unsupported token");

        // emit Validated(_token, _fee);
        return true;
    }

    function addNewToken(
        address _token, 
        address _function, 
        uint256 _fee, 
        string memory _functionName
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) returns (bool success) {
        require(!tokens[_token], "Token already exist");
        tokens[_token] = true;
        tokenFee[_token][_function] = _fee;

        emit TokenAdded(_token, _function, _fee, _functionName);
        return true;
    }
    
    function removeToken(
        address _token
    ) external override onlyRole(DEFAULT_ADMIN_ROLE)  returns (bool success) {
        require(tokens[_token], "Token does not exist");
        tokens[_token] = false;

        emit TokenRemoved(_token);
        return true;
    }

    function getTokenFee(
        address _token, 
        address _function) external view override returns (uint256 _fee) {
        return tokenFee[_token][_function];
    }
    
    function setTokenFee(
        address _token, 
        address _function, 
        uint256 _fee, 
        string memory _funtionName
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) returns (bool success) {
        require(tokens[_token], "Token is not yet supported");
        tokenFee[_token][_function] = _fee;

        emit TokenUpdated(_token, _function, _fee, _funtionName);
        return true;
    }

    function withdrawToken(
        address _token, 
        address _to, 
        uint256 _value
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) returns (bool success){
        IERC20(_token).transfer(_to, _value);
        return true;
    }
    
    function withdraw(
        address payable _to, 
        uint256 _value
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) returns (bool success){
        _to.transfer(_value);
        return true;
    }


    // function _msgSender() internal view override(Context, ERC2771Context) returns(address) {
    //     return ERC2771Context._msgSender();
    // } 

    // function _msgData() internal view override(Context, ERC2771Context) returns(bytes calldata) 
    // {
    //     return ERC2771Context._msgData();
    // }
}