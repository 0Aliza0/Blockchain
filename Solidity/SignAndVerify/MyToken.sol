// SPDX-License-Identifier: MIT
pragma solidity 0.8.33;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20{
    constructor() ERC20("MyToken","MTK"){
        _mint(msg.sender, 10_000 *10**decimals());
    }
}