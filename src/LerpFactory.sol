pragma solidity ^0.6.11;

import "./Lerp.sol";

contract LerpFactory {

    function newLerp(address target_, bytes32 what_, uint256 start_, uint256 end_, uint256 duration_) external returns (address) {
        return address(new Lerp(target_, what_, start_, end_, duration_));
    }

    function newIlkLerp(address target_, bytes32 ilk_, bytes32 what_, uint256 start_, uint256 end_, uint256 duration_) external returns (address) {
        return address(new IlkLerp(target_, ilk_, what_, start_, end_, duration_));
    }
}
