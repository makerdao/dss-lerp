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
