# dss-lerp

Performs linear interpolation over time on any Maker governance parameter. Normally this is performed out of the executive spell as you require `auth` permissions.

# Usage

```
// Increase the global debt ceiling from 100M to 200M over 7 days
lerpFactory.newLerp("20210421_VOW_HUMP1", vat, "Line", block.timestamp, 100 * MILLION * RAD, 200 * MILLION * RAD, 7 days);

// Increase the ETH-A debt ceiling from 100M to 200M over 7 days
lerpFactory.newIlkLerp("20210421_VOW_HUMP2", vat, "ETH-A", "line", block.timestamp, 100 * MILLION * RAD, 200 * MILLION * RAD, 7 days);
```

# Parameters

Each lerp factory invocation creates a new contract which has the following properties:

`target` - The contract which we are changing an administrative parameter.
`what` - The name of the parameter.
`startTime` - The starting time of this lerp instance.
`start` - The starting value of that parameter.
`end` - The ending value of that parameter.
`duration` - How long this lerp is running for.
`done` - Whether this lerp instance is finished or not.

# Executing

The Lerp contract has one method to call, which is permissionless and can be called by anyone:

`tick()` - Updates the `target` parameter to be whatever value it should be at this moment in time. This will also finish off the lerp and set the parameter to the end value if the elapsed time is longer than the `duration`.

# LerpFactory

The Lerp Factory (AKA `LERP_FAB`) provides a singleton inteface to keep track of all active lerp instances. It is deployed at the following addresses:

## Latest
Mainnet:  [0x9175561733d138326fdea86cdfdf53e92b588276](https://etherscan.io/address/0x9175561733d138326fdea86cdfdf53e92b588276#code)
Goerli:   [0xe7988b75a19d8690272d65882ab0d07d492f7002](https://goerli.etherscan.io/address/0xe7988b75a19d8690272d65882ab0d07d492f7002#code)

## Deprecated
Mainnet: [0x00B416da876fe42dd02813da435Cc030F0d72434](https://etherscan.io/address/0x00B416da876fe42dd02813da435Cc030F0d72434#code)
Kovan: [0xa6766Ed3574bAFc6114618E74035C7bb5e9a6aa9](https://kovan.etherscan.io/address/0xa6766Ed3574bAFc6114618E74035C7bb5e9a6aa9#code)

You can get a list of all active lerp instances by calling `list()` which returns an array of addresses for active lerps. This list of active lerps is not in any particular order. Alternatively you can query for specific lerps (even ones that are no longer active) by calling `lerps(bytes32)` which returns the address of the lerp or `address(0)` if there isn't a match. For example, calling `lerps("20210421_VOW_HUMP1")` would return the first lerp from the example above.

To `tick()` all active lerps you can use the convenience function `tall()` short for "tick all".
