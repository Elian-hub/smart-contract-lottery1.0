// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title Mock LINK Token with transferAndCall for Chainlink VRF testing
contract LinkToken {
    string public name = "Chainlink Token";
    string public symbol = "LINK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value, bytes data); // for transferAndCall

    constructor() {
        totalSupply = 1_000_000 ether;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");
        allowance[from][msg.sender] -= value;
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    function mint(address to, uint256 value) external {
        totalSupply += value;
        balanceOf[to] += value;
        emit Transfer(address(0), to, value);
    }

    /// @notice Mimics LINK's transferAndCall functionality
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success) {
        require(transfer(to, value), "Transfer failed");
        emit Transfer(msg.sender, to, value, data);
        if (_isContract(to)) {
            (bool ok,) =
                to.call(abi.encodeWithSignature("onTokenTransfer(address,uint256,bytes)", msg.sender, value, data));
            require(ok, "Callback failed");
        }
        return true;
    }

    function _isContract(address _addr) private view returns (bool hasCode) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}
