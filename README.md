# dss-lerp

Performs linear interpolation over time on any Maker governance parameter. Normally this is performed out of the executive spell as you require `auth` permissions.

# Usage

```
// Increase the global debt ceiling from 100M to 200M over 7 days
lerpFactory.newLerp(vat, "Line", 100 * MILLION * RAD, 200 * MILLION * RAD, 7 days);

// Increase the ETH-A debt ceiling from 100M to 200M over 7 days
lerpFactory.newIlkLerp(vat, "ETH-A", "line", 100 * MILLION * RAD, 200 * MILLION * RAD, 7 days);
```

# Parameters

Each lerp factory invocation creates a new contract which has the following properties:

`target` - The contract which we are changing an administrative parameter.
`what` - The name of the parameter.
`start` - The starting value of that parameter.
`end` - The ending value of that parameter.
`duration` - How long this lerp is running for.
`done` - Whether this lerp instance is finished or not.
`startTime` - The timestamp that this module started at.

# Executing

The Lerp contract has two methods to call, both are permissionless and can be called by anyone:

`tick()` - Updates the `target` parameter to be whatever value it should be at this moment in time. This will also finish off the lerp and set the parameter to the end value if the elapsed time is longer than the `duration`.
`wipe()` - House-keeping method to clear out the authorization of this module. This is optional as the contract is harmless after it completes execution.
