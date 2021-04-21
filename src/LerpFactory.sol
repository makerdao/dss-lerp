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

    address[] public active;  // Array of active lerps in no particular order

    function newLerp(address target_, bytes32 what_, uint256 startTime_, uint256 start_, uint256 end_, uint256 duration_) external returns (address) {
        address lerp = address(new Lerp(target_, what_, startTime_, start_, end_, duration_));
        active.push(lerp);
        return lerp;
    }

    function newIlkLerp(address target_, bytes32 ilk_, bytes32 what_, uint256 startTime_, uint256 start_, uint256 end_, uint256 duration_) external returns (address) {
        address lerp = address(new IlkLerp(target_, ilk_, what_, startTime_, start_, end_, duration_));
        active.push(lerp);
        return lerp;
    }

    function remove(uint256 index) internal {
        if (index != active.length - 1) {
            active[index] = active[active.length - 1];
        }
        active.pop();
    }

    // Tick all active lerps or wipe them if they are done
    function tall() external {
        for (uint256 i = 0; i < active.length; i++) {
            BaseLerp lerp = BaseLerp(active[i]);
            try lerp.tick() {} catch {
                // Stop tracking if this lerp fails
                remove(i);
            }
            if (lerp.done()) {
                remove(i);
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
