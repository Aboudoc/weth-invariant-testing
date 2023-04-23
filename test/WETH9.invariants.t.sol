// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {WETH9} from "../src/WETH9.sol";
import {Handler} from "./handlers/Handler.sol";

contract WETH9Invariants is StdInvariant, Test {
    WETH9 public weth;
    Handler public handler;

    function setUp() public {
        weth = new WETH9();
        handler = new Handler(weth);

        // We need to exclude the external func from fuzzing
        // Use the more complex targetSelector helper
        // from forge-std/StdInvariants to specify
        // the exact selectors we want the fuzzer
        // to target and exclude everything else
        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = Handler.deposit.selector;
        selectors[1] = Handler.withdraw.selector;
        selectors[2] = Handler.sendFallback.selector;

        targetSelector(
            FuzzSelector({addr: address(handler), selectors: selectors})
        );

        targetContract(address(handler));
    }

    // function invariant_badInvariantThisShouldFail() public {
    //     assertEq(0, weth.totalSupply());
    // }

    // function test_zeroDeposit() public {
    //     weth.deposit{value: 0}();
    //     assertEq(0, weth.balanceOf(address(this)));
    //     assertEq(0, weth.totalSupply());
    // }

    // function invariant_wethSupplyIsAlwaysZero() public {
    //     assertEq(0, weth.totalSupply());
    // }

    // ETH can only be wrapped into WETH, WETH can only
    // be unwrapped back into ETH. The sum of the Handler's
    // ETH balance plus the WETH totalSupply() should always
    // equal the total ETH_SUPPLY.
    function invariant_conservationOfETH() public {
        assertEq(
            handler.ETH_SUPPLY(),
            address(handler).balance + weth.totalSupply()
        );
    }

    // The WETH contract's Ether balance should always be
    // at least as much as the sum of individual deposits
    function invariant_solvencyDeposits() public {
        assertEq(
            address(weth).balance,
            handler.ghost_depositSum() - handler.ghost_withdrawSum()
        );
    }

    // The WETH contract's Ether balance should always be
    // at least as much as the sum of individual balances

    // function invariant_solvencyBalances() public {
    //     uint256 sumOfBalances;
    //     address[] memory actors = handler.actors();
    //     for (uint256 i = 0; i < actors.length; ++i) {
    //         sumOfBalances += weth.balanceOf(actors[i]);
    //     }
    //     assertEq(address(weth).balance, sumOfBalances);
    // }

    function invariant_solvencyBalances() public {
        uint256 sumOfBalances = handler.reduceActors(0, this.accumulateBalance);
        assertEq(address(weth).balance, sumOfBalances);
    }

    function accumulateBalance(uint256 balance, address caller)
        external
        view
        returns (uint256)
    {
        return balance + weth.balanceOf(caller);
    }
}
