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

    mapping (bytes32 => address) public lerps;
    address[] public active;  // Array of active lerps in no particular order

    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event NewLerp(bytes32 name, address indexed target, bytes32 what, uint256 startTime, uint256 start, uint256 end, uint256 duration);
    event NewIlkLerp(bytes32 name, address indexed target, bytes32 ilk, bytes32 what, uint256 startTime, uint256 start, uint256 end, uint256 duration);
    event LerpFinished(address indexed lerp);

    constructor() public {
        wards[msg.sender] = 1;
        emit Rely(msg.sender);
    }

    function newLerp(bytes32 name_, address target_, bytes32 what_, uint256 startTime_, uint256 start_, uint256 end_, uint256 duration_) external auth returns (address lerp) {
        lerp = address(new Lerp(target_, what_, startTime_, start_, end_, duration_));
        lerps[name_] = lerp;
        active.push(lerp);
        
        emit NewLerp(name_, target_, what_, startTime_, start_, end_, duration_);
    }

    function newIlkLerp(bytes32 name_, address target_, bytes32 ilk_, bytes32 what_, uint256 startTime_, uint256 start_, uint256 end_, uint256 duration_) external auth returns (address lerp) {
        lerp = address(new IlkLerp(target_, ilk_, what_, startTime_, start_, end_, duration_));
        lerps[name_] = lerp;
        active.push(lerp);
        
        emit NewIlkLerp(name_, target_, ilk_, what_, startTime_, start_, end_, duration_);
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
            try lerp.tick() {
                if (lerp.done()) {
                    remove(i);
                    i--;
                }
            } catch {
                // Stop tracking if this lerp fails
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
