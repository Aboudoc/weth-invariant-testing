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

    function invariant_conservationOfETH() public {
        assertEq(
            handler.ETH_SUPPLY(),
            address(handler).balance + weth.totalSupply()
        );
    }

    function invariant_solvencyDeposits() public {
        assertEq(
            address(weth).balance,
            handler.ghost_depositSum() - handler.ghost_withdrawSum()
        );
    }

    function invariant_solvencyBalances() public {
        uint256 sumOfBalances;
        address[] memory actors = handler.actors();
        for (uint256 i = 0; i < actors.length; ++i) {
            sumOfBalances += weth.balanceOf(actors[i]);
        }
        assertEq(address(weth).balance, sumOfBalances);
    }
}
