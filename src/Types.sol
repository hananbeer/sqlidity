// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./BokkyPooBahsRedBlackTreeLibrary.sol";
import "forge-std/console.sol";

bool constant DEBUG = false;

uint256 constant INS_SIZE = 32 * 6;

struct Instruction {
    uint256 opcode;
    uint256 p1;
    uint256 p2;
    uint256 p3;
    uint256 p4;
    uint256 p5;
}

struct Cursor {
    uint256 tbl;
    uint256 ptr;
}

struct ExecEngine {
    uint256 pc;
    uint256 opcode;
    uint256 p1;
    uint256 p2;
    uint256 p3;
    uint256 p4;
    uint256 p5;
    Cursor[4] cursors;
    uint256[10] mem;
}

library SqliteExecutor {
    using SqliteExecutor for ExecEngine;
    using BokkyPooBahsRedBlackTreeLibrary for Tree;

    function parseNext(ExecEngine memory e, bytes calldata bytecode) internal pure {
        (e.opcode, e.p1, e.p2, e.p3, e.p4, e.p5) = abi.decode(
            bytecode[e.pc * INS_SIZE:(e.pc + 1) * INS_SIZE],
            (uint256, uint256, uint256, uint256, uint256, uint256)
        );
    }
    // function _set_pc(ExecEngine memory e, uint256 e.pc) internal {
    //     e.e.pc = e.pc;
    // }

    function getCursor(ExecEngine memory e) internal pure returns (Cursor memory) {
        // TODO: currently cursors are used as-is, but maybe
        // sqlite does some memory ops and move it around,
        // in which case accessing through mem will be necessary
        return e.cursors[e.p1];
    }

    function tbl(ExecEngine memory e) internal pure returns (uint256) {
        return e.cursors[e.p1].tbl;
    }

    function ptr(ExecEngine memory e) internal pure returns (uint256) {
        return e.cursors[e.p1].ptr;
    }

    function ptr(ExecEngine memory e, uint256 val) internal pure {
        e.cursors[e.p1].ptr = val;
    }

    function _op_table(ExecEngine memory e, Tree storage table) internal view {
        if (table.size == 0) {
            if (DEBUG) console.log("Rewind [%s] EMPTY TABLE", e.p1);
            e.pc = e.p2 - 1;
            return;
        }

        uint256 first = table.first();
        // e.cursors() abst: 342761 <-- net bad...
        // direct e.cursors: 342580
        // e.ptr(): 342580 <-- same! I'd say net good since abstraction gud
        e.ptr(first);
        if (DEBUG) console.log("Rewind [%s] %s", e.p1, first);
    }
}


