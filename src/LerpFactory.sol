// SPDX-License-Identifier: AGPL-3.0-or-later
//
/// LerpFactory.sol -- Linear Interpolation creation module
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
pragma solidity ^0.6.12;

import "./Lerp.sol";

contract LerpFactory {

    // --- Auth ---
    function rely(address guy) external auth { wards[guy] = 1; emit Rely(guy); }
    function deny(address guy) external auth { wards[guy] = 0; emit Deny(guy); }
    mapping (address => uint256) public wards;
    modifier auth {
        require(wards[msg.sender] == 1, "LerpFactory/not-authorized");
        _;
    }

    address[] public active;  // Array of active lerps in no particular order

    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event NewLerp(address indexed target_, bytes32 what_, uint256 startTime_, uint256 start_, uint256 end_, uint256 duration_);
    event NewIlkLerp(address indexed target_, bytes32 ilk_, bytes32 what_, uint256 startTime_, uint256 start_, uint256 end_, uint256 duration_);
    event LerpFinished(address indexed lerp);

    constructor() public {
        wards[msg.sender] = 1;
        emit Rely(msg.sender);
    }

    function newLerp(address target_, bytes32 what_, uint256 startTime_, uint256 start_, uint256 end_, uint256 duration_) external auth returns (address lerp) {
        lerp = address(new Lerp(target_, what_, startTime_, start_, end_, duration_));
        active.push(lerp);
        
        emit NewLerp(target_, what_, startTime_, start_, end_, duration_);
    }

    function newIlkLerp(address target_, bytes32 ilk_, bytes32 what_, uint256 startTime_, uint256 start_, uint256 end_, uint256 duration_) external auth returns (address lerp) {
        lerp = address(new IlkLerp(target_, ilk_, what_, startTime_, start_, end_, duration_));
        active.push(lerp);
        
        emit NewIlkLerp(target_, ilk_, what_, startTime_, start_, end_, duration_);
    }

    function remove(uint256 index) internal {
        address lerp = active[index];
        if (index != active.length - 1) {
            active[index] = active[active.length - 1];
        }
        active.pop();
        
        emit LerpFinished(lerp);
    }

    // Tick all active lerps or wipe them if they are done
    function tall() external {
        for (uint256 i = 0; i < active.length; i++) {
            BaseLerp lerp = BaseLerp(active[i]);
            try lerp.tick() {} catch {
                // Stop tracking if this lerp fails
                remove(i);
                i--;
            }
            if (lerp.done()) {
                remove(i);
                i--;
            }
        }
    }

    // The number of active lerps
    function count() external view returns (uint256) {
        return active.length;
    }

    // Return the entire array of active lerps
    function list() external view returns (address[] memory) {
        return active;
    }

}
