pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./DssLerp.sol";

contract DssLerpTest is DSTest {
    DssLerp lerp;

    function setUp() public {
        lerp = new DssLerp();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
