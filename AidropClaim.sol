// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract AirdropClaim is Ownable {
    mapping (address => uint256) public balances;

    IERC20 public govToken;

    bool public enabled;

    event Claimed(address recipient, uint256 amount);

    modifier isEnabled {
        require(enabled, "airdrop is not enabled");
        _;
    }

    constructor(address _address) public {
        govToken = IERC20(_address);
    }

    function setAirdrops(address[] memory _recipients, uint256[] memory _amounts) onlyOwner public {
        require(_recipients.length > 0 && _recipients.length == _amounts.length);
        for (uint i = 0; i < _recipients.length; i++) {
            balances[_recipients[i]] += _amounts[i];
        }
    }

    function toggleEnabled() onlyOwner public {
        enabled = !enabled;
    }

    function claimAirdrop() isEnabled public {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No unclaimed tokens");
        balances[msg.sender] = 0;
        govToken.transfer(msg.sender, balance);
        emit Claimed(msg.sender, balance);
    }

    function transferTokens(address _address, uint256 _amount) onlyOwner public {
        govToken.transfer(_address, _amount);
    }
}
