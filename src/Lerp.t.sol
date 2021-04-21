pragma solidity ^0.6.12;

import "ds-test/test.sol";

import "./Lerp.sol";
import "./LerpFactory.sol";

interface Hevm {
    function warp(uint256) external;
    function store(address,bytes32,bytes32) external;
}

contract TestContract {

    // --- Auth ---
    mapping (address => uint256) public wards;
    function rely(address usr) external auth { wards[usr] = 1; }
    function deny(address usr) external auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    uint256 public value;
    uint256 public ilkvalue;

    constructor() public {
        wards[msg.sender] = 1;
    }

    function file(bytes32 what, uint256 data) public auth {
        value = data;
    }

    function file(bytes32 ilk, bytes32 what, uint256 data) public auth {
        ilkvalue = data;
    }

}

contract DssLerpTest is DSTest {

    Hevm hevm;

    TestContract target;
    LerpFactory factory;

    // CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
    bytes20 constant CHEAT_CODE =
        bytes20(uint160(uint256(keccak256('hevm cheat code'))));

    uint256 constant TOLL_ONE_PCT = 10 ** 16;

    function setUp() public {
        hevm = Hevm(address(CHEAT_CODE));

        target = new TestContract();
        factory = new LerpFactory();
    }

    function test_lerp() public {
        Lerp lerp = new Lerp(address(target), "value", block.timestamp, 1 * TOLL_ONE_PCT, 1 * TOLL_ONE_PCT / 10, 9 days);
        assertEq(lerp.what(), "value");
        assertEq(lerp.start(), 1 * TOLL_ONE_PCT);
        assertEq(lerp.end(), 1 * TOLL_ONE_PCT / 10);
        assertEq(lerp.duration(), 9 days);
        assertTrue(!lerp.done());
        assertEq(lerp.startTime(), 0);
        assertEq(target.value(), 0);
        target.rely(address(lerp));
        lerp.tick();
        assertTrue(!lerp.done());
        assertEq(lerp.startTime(), block.timestamp);
        assertEq(target.value(), 1 * TOLL_ONE_PCT);
        hevm.warp(1 days);
        assertEq(target.value(), 1 * TOLL_ONE_PCT);
        lerp.tick();
        assertEq(target.value(), 9 * TOLL_ONE_PCT / 10);    // 0.9%
        hevm.warp(2 days);
        lerp.tick();
        assertEq(target.value(), 8 * TOLL_ONE_PCT / 10);    // 0.8%
        hevm.warp(2 days + 12 hours);
        lerp.tick();
        assertEq(target.value(), 75 * TOLL_ONE_PCT / 100);    // 0.75%
        hevm.warp(12 days);
        assertEq(target.wards(address(lerp)), 1);
        lerp.tick();
        assertEq(target.value(), 1 * TOLL_ONE_PCT / 10);    // 0.1%
        assertTrue(lerp.done());
        assertEq(target.wards(address(lerp)), 0);
    }

    function test_lerp_max_values1() public {
        uint256 start = 10 ** 59;
        uint256 end = 10 ** 59 - 1;
        uint256 duration = 365 days;
        uint256 deltaTime = 365 days - 1;   // This will set t at it's max value just under 1 WAD

        Lerp lerp = new Lerp(address(target), "value", block.timestamp, start, end, duration);
        target.rely(address(lerp));
        hevm.warp(now + deltaTime);
        lerp.tick();
        uint256 value = target.value();
        uint256 low = end > start ? start : end;
        uint256 high = end > start ? end : start;
        assertTrue(value >= low && value <= high);
    }

    function test_lerp_max_values2() public {
        uint256 start = 10 ** 59 - 15;
        uint256 end = 10 ** 59;
        uint256 duration = 365 days;
        uint256 deltaTime = 365 days - 1;   // This will set t at it's max value just under 1 WAD

        Lerp lerp = new Lerp(address(target), "value", block.timestamp, start, end, duration);
        target.rely(address(lerp));
        hevm.warp(now + deltaTime);
        lerp.tick();
        uint256 value = target.value();
        uint256 low = end > start ? start : end;
        uint256 high = end > start ? end : start;
        assertTrue(value >= low && value <= high);
    }

    function test_lerp_short_duration() public {
        uint256 start = 5;
        uint256 end = 10 ** 59;
        uint256 duration = 2;
        uint256 deltaTime = 1;

        Lerp lerp = new Lerp(address(target), "value", block.timestamp, start, end, duration);
        target.rely(address(lerp));
        hevm.warp(now + deltaTime);
        lerp.tick();
        uint256 value = target.value();
        uint256 low = end > start ? start : end;
        uint256 high = end > start ? end : start;
        assertTrue(value >= low && value <= high);
    }

    function test_lerp_bounds_fuzz(uint256 start, uint256 end, uint256 duration, uint256 deltaTime) public {
        // Reduce to reasonable numbers
        start = start % 10 ** 59;
        end = end % 10 ** 59;
        duration = duration % (365 days);
        deltaTime = deltaTime % (500 days);

        // Constructor revert cases
        if (start == end) return;
        if (duration == 0) return;
        if (deltaTime == 0) return;

        Lerp lerp = new Lerp(address(target), "value", block.timestamp, start, end, duration);
        target.rely(address(lerp));
        hevm.warp(now + deltaTime);
        lerp.tick();
        uint256 value = target.value();
        uint256 low = end > start ? start : end;
        uint256 high = end > start ? end : start;
        assertTrue(value >= low && value <= high);
    }

    function test_lerp_factory() public {
        uint256 start = 10 ** 59;
        uint256 end = 2;
        uint256 duration = 40;
        uint256 deltaTime = 3;

        BaseLerp lerp = BaseLerp(factory.newLerp(address(target), "value", block.timestamp, start, end, duration));
        assertEq(factory.count(), 1);
        assertEq(factory.active(0), address(lerp));
        address[1] memory addresses;
        addresses[0] = address(lerp);
        address[] memory raddresses = factory.list();
        assertEq(raddresses[0], addresses[0]);
        assertEq(raddresses.length, addresses.length);
        target.rely(address(lerp));
        hevm.warp(now + deltaTime);
        lerp.tick();
        uint256 value = target.value();
        uint256 low = end > start ? start : end;
        uint256 high = end > start ? end : start;
        assertTrue(value > low && value < high);    // Remove equality to make sure its actually between values
    }

    function test_ilk_lerp_factory() public {
        uint256 start = 10 ** 59;
        uint256 end = 2;
        uint256 duration = 40;
        uint256 deltaTime = 3;

        BaseLerp lerp = BaseLerp(factory.newIlkLerp(address(target), "someIlk", "value", block.timestamp, start, end, duration));
        assertEq(factory.count(), 1);
        assertEq(factory.active(0), address(lerp));
        address[1] memory addresses;
        addresses[0] = address(lerp);
        address[] memory raddresses = factory.list();
        assertEq(raddresses[0], addresses[0]);
        assertEq(raddresses.length, addresses.length);
        target.rely(address(lerp));
        hevm.warp(now + deltaTime);
        factory.tall();
        uint256 value = target.ilkvalue();
        uint256 low = end > start ? start : end;
        uint256 high = end > start ? end : start;
        assertTrue(value > low && value < high);    // Remove equality to make sure its actually between values

        hevm.warp(now + duration);
        factory.tall();
        assertEq(factory.count(), 0);
        assertTrue(lerp.done());
    }

}
