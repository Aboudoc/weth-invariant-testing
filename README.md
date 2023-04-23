https://mirror.xyz/horsefacts.eth/Jex2YVaO65dda6zEyfM_-DXlXhOWCAoSpOx5PLocYgw

https://docs.soliditylang.org/en/v0.8.18/types.html#function-types

https://book.getfoundry.sh/forge/invariant-testing#actor-management

## Call summary

```sh
$ forge test -vv -m invariant_callSummary
```

```sh
Running 1 test for test/WETH9.invariants.t.sol:WETH9Invariants
[PASS] invariant_callSummary() (runs: 1000, calls: 15000, reverts: 11)
Logs:
  Call summary:
  deposit 5
  withdraw 7
  sendFallback 3

Test result: ok. 1 passed; 0 failed; finished in 4.42s
```

Although we performed 1000 runs, the summary printed here is a snapshot of calls made during the final run.

The total number of calls in our summary should always be the same as the depth parameter set for invariant tests in foundry.toml

## Reusing actors

```sh
Running 1 test for test/WETH9.invariants.t.sol:WETH9Invariants
[PASS] invariant_callSummary() (runs: 2000, calls: 50000, reverts: 2)
Logs:
  Call summary:
  deposit 5
  withdraw 8
  sendFallback 12
  zero withdrawals 3

```
