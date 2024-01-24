// this may help:
// https://sqlite.org/fileformat2.html

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Opcodes.sol";
import "./Types.sol";
import "./BokkyPooBahsRedBlackTreeLibrary.sol";

import "forge-std/console.sol";

bool constant PURGE_STORAGE_ON_DELETE = true;

contract Sqlite {
    using SqliteExecutor for ExecEngine;
    using BokkyPooBahsRedBlackTreeLibrary for Tree;

    mapping (uint256 => Tree) public tables;
    uint256 public countTables;

    // event ResultRow1(uint256 val1);
    // event ResultRow2(uint256 val1, uint256 val2);
    // event ResultRow3(uint256 val1, uint256 val2, uint256 val3);
    // event ResultRow4(uint256 val1, uint256 val2, uint256 val3, uint256 val4);
    // event ResultRowThisWideNotImplemented();

    constructor() {
        // Tree storage table = 
            _makeTable();

        // table.insert(1, 5);
        // table.insert(2, 25);
        // table.insert(3, 125);
        // table.insert(4, 99);

        //table.insert(10001, 345346);

        // uncomment to make conflict in rowid NotExists
        // table.insert(111, 345345);

        
        // Tree storage index =
            _makeTable();
        // uncomment to make conflict in UNIQUE value NoConflict
        //index.insert(333, 345345);

        // index.insert(25, 2);
        // index.insert(125, 3);
        // index.insert(99, 4);
        // index.insert(999, 5);
        // index.insert(1001, 6);
    }

    function _makeTable() internal returns (Tree storage table) {
        table = tables[countTables];
        table.insert(1, 0);
        countTables++;
    }

    function _makeRow(uint256[] memory items, uint256 start, uint256 count) internal returns (uint256 sslot) {
        // hash is probably a bad idea because a single column can be mutated
        // TODO: need to be careful or change from hash, maybe nonce
        require(count > 0, "must have count > 0");
        require(start + count < items.length, "attempt to store more columns than table");

        // TODO: should probably take table index into account, but
        // sqlidity treats tables and indices the same
        // and MakeRecord does not look at the table...
        assembly {
            let hash := keccak256(add(add(items, 0x20), mul(start, 0x20)), mul(count, 0x20))
            sslot := or(shl(248, count), shr(8, hash))
        }
        for (uint256 i = 0; i < count; i++) {
            assembly {
                let base := add(items, 0x20)
                let offset := mul(add(i, start), 0x20)
                let ptr := add(base, offset)
                let val := mload(ptr)
                sstore(add(sslot, i), val)
            }
        }
    }

    function _deleteRow(uint256 sslot) internal {
        // hash is probably a bad idea because a single column can be mutated
        // TODO: need to be careful or change from hash, maybe nonce
        if (!PURGE_STORAGE_ON_DELETE)
            return;

        uint256 count = _rowSize(sslot);
        for (uint256 i = 0; i < count; i++) {
            assembly {
                sstore(add(sslot, i), 0)
            }
        }
    }

    function _rowSize(uint256 sslot) internal pure returns (uint256 size) {
        return (sslot >> 248);
    }

    function _readColumn(uint256 sslot) internal view returns (uint256 value) {
        assembly {
            value := sload(sslot)
        }
        // console.log("### read: %s => %s", sslot, value);
    }

    function _debugPrintRow(uint256 sslot, uint256 count) internal view {
        console.log("[DEBUG: %s]", sslot);
        uint256 value;
        for (uint256 i = 0; i < count; i++) {
            assembly {
                value := sload(sslot)
            }
            console.log("  [#%s] %s", i, value);
        }
    }

    function _readRowColumn(uint256 sslot, uint256 column) internal view returns (uint256 value) {
        assembly {
            value := sload(add(sslot, column))
        }
    }

    function execute(bytes calldata bytecode) public payable {
        ExecEngine memory e;
        uint256 yield_p2;
        
        // allocate dynamically for slicing
        uint256[] memory mem = new uint256[](10);

        // always start with Init opcode
        (e.opcode, e.p1, e.p2) = abi.decode(bytecode[0x00:0x60], (uint256, uint256, uint256));
        require(e.opcode == uint256(Opcode.Init), "must start with Init opcode");
        e.pc = e.p2;
        if (e.pc == 0)
            e.pc = 1;

        // for debugging
        // uint256 count = 0;
        uint256 opcodes_length = bytecode.length / INS_SIZE;
        while (e.pc < opcodes_length) {
            // for debugging
            //require(count++ < 50, "runtime limit");
            require((e.pc + 1) <= opcodes_length, "unexpected bytecode end");

            // ins = abi.decode(bytecode[e.pc * INS_SIZE:(e.pc + 1) * INS_SIZE], (Instruction));
            // (e.opcode, e.p1, e.p2, e.p3, e.p4, e.p5) = abi.decode(
            //     bytecode[e.pc * INS_SIZE:(e.pc + 1) * INS_SIZE],
            //     (uint256, uint256, uint256, uint256, uint256, uint256)
            // );
            e.parseNext(bytecode);
            // DEBUG:
            // console.log("pc: %s, op: %s", e.pc, e.opcode);

            //*** TRANSACTIONS ***//
            if (e.opcode == uint256(Opcode.Transaction)) {
                // TODO: impl. no op for now
                if (DEBUG) console.log("Transaction started (ignored)");
            } else if (e.opcode == uint256(Opcode.OpenRead)) {
                // TODO: if P4 is int, ensure table has at least P4 columns
                e.cursors[e.p1] = Cursor({tbl: e.p2, ptr: 0});
                if (DEBUG) console.log("OpenRead %s <- %s", e.p1, e.p2);
            } else if (e.opcode == uint256(Opcode.OpenWrite)) {
                // TODO: if P4 is int, ensure table has at least P4 columns
                e.cursors[e.p1] = Cursor({tbl: e.p2, ptr: 0});
                if (DEBUG) console.log("OpenWrite %s <- %s", e.p1, e.p2);
            } else if (e.opcode == uint256(Opcode.InitCoroutine)) {
                if (DEBUG) console.log("InitCoroutine %s", e.p3);
                mem[e.p1] = e.p3;
                if (e.p2 != 0) {
                    e.pc = e.p2;
                    continue;
                }
            } else if (e.opcode == uint256(Opcode.EndCoroutine)) {
                e.pc = yield_p2;
                if (DEBUG) console.log("EndCoroutine %s", yield_p2);
                continue;
            } else if (e.opcode == uint256(Opcode.Yield)) {
                uint256 p1 = mem[e.p1];
                if (DEBUG) console.log("Yield %s <-> %s", p1, e.pc + 1);
                mem[e.p1] = e.pc + 1;
                e.pc = p1;
                if (e.p2 > 0)
                    yield_p2 = e.p2;
                continue;
            } else if (e.opcode == uint256(Opcode.Return)) {
                if (DEBUG) console.log("Return");
                yield_p2 = 0;
            }
            //*** CONSTANTS ***//
            else if (e.opcode == uint256(Opcode.Integer)) {
                if (DEBUG) console.log("Integer %s <- %s", e.p2, e.p1);
                mem[e.p2] = e.p1;
            } else if (e.opcode == uint256(Opcode.Real)) {
                // mem[e.p2] = e.p4;
                revert("Real unsupported");
            } else if (e.opcode == uint256(Opcode.String)) {
                // TODO: calc length
                mem[e.p2] = e.p4;
                if (DEBUG) console.log("String not fully implemented");
                //mem[e.p1] = strlen(e.p4);
            } else if (e.opcode == uint256(Opcode.String8)) {
                // TODO: calc length
                mem[e.p2] = e.p4;
                if (DEBUG) console.log("String not fully implemented");
                //mem[e.p1] = strlen(e.p4);
            } else if (e.opcode == uint256(Opcode.Null)) {
                if (DEBUG) console.log("Null");
                mem[e.p2++] = 0;
                while (e.p2 < e.p3)
                    mem[e.p2++] = 0;
            } else if (e.opcode == uint256(Opcode.SoftNull)) {
                // NOTE: normally when doing:
                // INSERT INTO tbl(id) VALUES(NULL)
                // it will auto-increment the id (starting from 1), BUT
                // INSERT INTO tbl(id) VALUES(0)
                // will insert a 0! however, here I'm ignoring NULLs
                // and everything is treated as zero.
                if (DEBUG) console.log("SoftNull (translated as zero)");
                mem[e.p1] = 0;
            }
            //*** COMPARSIONS ***//
            else if (e.opcode == uint256(Opcode.If)) {
                // TODO: edge cases
                if (mem[e.p1] != 0) {
                    if (DEBUG) console.log("If (taken)");
                    e.pc = e.p2;
                    continue;
                } else {
                    if (DEBUG) console.log("If (NOT taken)");
                }
            } else if (e.opcode == uint256(Opcode.IfNot)) {
                // TODO: edge cases
                if (mem[e.p1] == 0) {
                    if (DEBUG) console.log("IfNot (taken)");
                    e.pc = e.p2;
                    continue;
                } else {
                    if (DEBUG) console.log("IfNot (NOT taken)");
                }
            } else if (e.opcode == uint256(Opcode.Eq)) {
                if (DEBUG) console.log("Eq");
                if (mem[e.p3] == mem[e.p1]) {
                    e.pc = e.p2;
                    continue;
                }
            } else if (e.opcode == uint256(Opcode.Ne)) {
                if (DEBUG) console.log("Ne");
                if (mem[e.p3] != mem[e.p1]) {
                    e.pc = e.p2;
                    continue;
                }
            } else if (e.opcode == uint256(Opcode.Lt)) {
                if (DEBUG) console.log("Lt");
                if (mem[e.p3] < mem[e.p1]) {
                    e.pc = e.p2;
                    continue;
                }
            } else if (e.opcode == uint256(Opcode.Le)) {
                if (DEBUG) console.log("Le");
                if (mem[e.p3] <= mem[e.p1]) {
                    e.pc = e.p2;
                    continue;
                }
            } else if (e.opcode == uint256(Opcode.Gt)) {
                if (DEBUG) console.log("Gt");
                if (mem[e.p3] > mem[e.p1]) {
                    e.pc = e.p2;
                    continue;
                }
            } else if (e.opcode == uint256(Opcode.Ge)) {
                if (DEBUG) console.log("Ge");
                if (mem[e.p3] >= mem[e.p1]) {
                    e.pc = e.p2;
                    continue;
                }
            } else if (e.opcode == uint256(Opcode.IsNull)) {
                // TODO: impl. NULL as 0x80..00?
                // doesn't make much sense, but also 0 might not be so good. so maybe ignore nulls?
                if (mem[e.p1] == 0) {
                    if (DEBUG) console.log("IsNull (taken)");
                    e.pc = e.p2;
                    continue;
                } else {
                    if (DEBUG) console.log("IsNull (NOT taken)");
                }
            } else if (e.opcode == uint256(Opcode.NotNull)) {
                // TODO: impl. NULL as 0x80..00?
                // doesn't make much sense, but also 0 might not be so good. so maybe ignore nulls?
                if (mem[e.p1] != 0) {
                    if (DEBUG) console.log("NotNull (taken)");
                    e.pc = e.p2;
                    continue;
                } else {
                    if (DEBUG) console.log("NotNull (NOT taken)");
                }
            } else if (e.opcode == uint256(Opcode.IsTrue)) {
                // TODO: implement booleans as booleans..?
                // TODO: check if implemented correctly
                /*
                (from the docs...)
                The logic is summarized like this:
                If P3==0 and P4==0 then r[P2] := r[P1] IS TRUE
                If P3==1 and P4==1 then r[P2] := r[P1] IS FALSE
                If P3==0 and P4==1 then r[P2] := r[P1] IS NOT TRUE
                If P3==1 and P4==0 then r[P2] := r[P1] IS NOT FALSE
                */
                mem[e.p2] = (mem[e.p1] == 0 ? 0 : 1) ^ (mem[e.p4] == 0 ? 0 : 1);
                if (DEBUG) console.log("IsTrue (NOT taken)");
            } else if (e.opcode == uint256(Opcode.NotExists)) {
                uint256 index = mem[e.p3];
                if (DEBUG) console.log("NotExists; tbl: %s, index: %s, jump: %s", e.p1, index, e.p2);
                if (tables[e.tbl()].exists(index)) {
                    if (DEBUG) console.log("  \\--> key exists.");
                } else {
                    if (DEBUG) console.log("  \\--> key DOES NOT exist.");
                    e.pc = e.p2;
                    continue;
                }
            } else if (e.opcode == uint256(Opcode.Found)) {
                // TODO: Found & NotFound refer to entire row, not column
                uint256 index = mem[e.p3];
                if (DEBUG) console.log("Found; tbl: %s, index: %s, jump: %s", e.p1, index, e.p2);
                if (tables[e.tbl()].exists(index)) {
                    if (DEBUG) console.log("  \\--> key found.");
                } else {
                    if (DEBUG) console.log("  \\--> key NOT found.");
                    e.pc = e.p2;
                    continue;
                }
            } else if (e.opcode == uint256(Opcode.NotFound)) {
                // TODO: Found & NotFound refer to entire row, not column
                uint256 index = mem[e.p3];
                if (DEBUG) console.log("NotFound; tbl: %s, index: %s, jump: %s", e.p1, index, e.p2);
                if (!tables[e.tbl()].exists(index)) {
                    if (DEBUG) console.log("  \\--> key NOT found.");
                } else {
                    if (DEBUG) console.log("  \\--> key found.");
                    e.pc = e.p2;
                    continue;
                }
            } else if (e.opcode == uint256(Opcode.NoConflict)) {
                // TODO: check all P4 arguments (or blob if P4 == 0)
                require(e.p4 != 0, "NoConflict - blob not yet supported.");
                
                uint256 index = mem[e.p3];
                if (DEBUG) console.log("NoConflict; tbl: %s, p3: %s, p4: %s", e.p1, e.p3, e.p4);
                bool conflicted = false;
                // uint256 rsize = _rowSize(sslot);
                // TODO: multiple columns conflict (count should be stored in MakeRecord -> _makeRow -> sslot MSB?)
                for (uint256 i = 0; i < 1/*e.p2*/; i++) {
                    if (tables[e.cursors[e.p1 + i].tbl].exists(index)) {
                        conflicted = true;
                        break;
                    }
                }
                if (conflicted) {
                    if (DEBUG) console.log("  \\--> CONFLICT!");
                } else {
                    // if there is no conflict, jump to p2
                    if (DEBUG) console.log("  \\--> no conflict.");
                    e.pc = e.p2;
                    continue;
                }
            }
            //*** ARITHMETIC ***//
            else if (e.opcode == uint256(Opcode.And)) {
                if (DEBUG) console.log("And %s && %s", mem[e.p2], mem[e.p1]);
                mem[e.p3] = (mem[e.p2] > 0 && mem[e.p1] > 0 ? 1 : 0);
            } else if (e.opcode == uint256(Opcode.Or)) {
                if (DEBUG) console.log("Or %s || %s", mem[e.p2], mem[e.p1]);
                mem[e.p3] = (mem[e.p2] > 0 || mem[e.p1] > 0 ? 1 : 0);
            } else if (e.opcode == uint256(Opcode.Add)) {
                if (DEBUG) console.log("Add %s + %s", mem[e.p2], mem[e.p1]);
                mem[e.p3] = mem[e.p2] + mem[e.p1];
            } else if (e.opcode == uint256(Opcode.Subtract)) {
                if (DEBUG) console.log("Subtract %s - %s", mem[e.p2], mem[e.p1]);
                mem[e.p3] = mem[e.p2] - mem[e.p1];
            } else if (e.opcode == uint256(Opcode.AddImm)) {
                if (DEBUG) console.log("AddImm %s + %s", mem[e.p1], e.p2);
                mem[e.p1] += e.p2;
            } else if (e.opcode == uint256(Opcode.Multiply)) {
                if (DEBUG) console.log("Multiply %s * %s", mem[e.p2], mem[e.p1]);
                mem[e.p3] = mem[e.p2] * mem[e.p1];
            } else if (e.opcode == uint256(Opcode.Divide)) {
                if (DEBUG) console.log("Divide %s / %s", mem[e.p2], mem[e.p1]);
                mem[e.p3] = mem[e.p2] / mem[e.p1];
            } else if (e.opcode == uint256(Opcode.Remainder)) {
                if (DEBUG) console.log("Remainder %s % %s", mem[e.p2], mem[e.p1]);
                mem[e.p3] = mem[e.p2] % mem[e.p1];
            } else if (e.opcode == uint256(Opcode.BitNot)) {
                if (DEBUG) console.log("BitNot ~%s", mem[e.p1]);
                mem[e.p2] = ~mem[e.p1];
            } else if (e.opcode == uint256(Opcode.BitOr)) {
                if (DEBUG) console.log("BitNot %s | %s", mem[e.p2], mem[e.p1]);
                mem[e.p3] = mem[e.p2] | mem[e.p1];
            } else if (e.opcode == uint256(Opcode.BitAnd)) {
                if (DEBUG) console.log("BitAnd %s & %s", mem[e.p2], mem[e.p1]);
                mem[e.p3] = mem[e.p2] & mem[e.p1];
            } else if (e.opcode == uint256(Opcode.ShiftLeft)) {
                if (DEBUG) console.log("ShiftLeft %s << %s", mem[e.p2], mem[e.p1]);
                mem[e.p3] = mem[e.p2] << mem[e.p1];
            } else if (e.opcode == uint256(Opcode.ShiftRight)) {
                if (DEBUG) console.log("ShiftRight %s >> %s", mem[e.p2], mem[e.p1]);
                mem[e.p3] = mem[e.p2] >> mem[e.p1];
            }
            //*** TYPES ***//
            else if (e.opcode == uint256(Opcode.MustBeInt)) {
                if (DEBUG) console.log("MustBeInt (ignored)");
            }
            //*** RECORDS ***//
            else if (e.opcode == uint256(Opcode.Copy)) {
                // TODO: use identity precompile?
                revert("Copy unimplemented");
            } else if (e.opcode == uint256(Opcode.SCopy)) {
                // TODO: check if extra work needed to copy strings and blobs too
                mem[e.p2] = mem[e.p1];
                if (DEBUG) console.log("SCopy %s <- %s", e.p2, mem[e.p1]);
            } else if (e.opcode == uint256(Opcode.IntCopy)) {
                // TODO: validate int?
                if (DEBUG) console.log("IntCopy %s <- %s", e.p2, mem[e.p1]);
                mem[e.p2] = mem[e.p1];
            } else if (e.opcode == uint256(Opcode.Int64)) {
                // TODO: validate int?
                if (DEBUG) console.log("Int64 %s <- %s", e.p2, mem[e.p4]);
                mem[e.p2] = mem[e.p4];
            } else if (e.opcode == uint256(Opcode.NewRowid)) {
                //* Get a new integer record number (a.k.a "rowid") used as the key to a table. The record number is not previously used as a key in the database table that cursor P1 points to. The new record number is written written to register P2.
                if (DEBUG) console.log("NewRowid: %s", mem[e.p2]);
                uint256 last = tables[e.tbl()].last();
                mem[e.p2] = last + 1;
                //* If P3>0 then P3 is a register in the root frame of this VDBE that holds the largest previously generated record number. No new record numbers are allowed to be less than this value. When this value reaches its maximum, an SQLITE_FULL error is generated. The P3 register is updated with the ' generated record number. This P3 mechanism is used to help implement the AUTOINCREMENT feature.
                //if (e.p3 > 0)
                //    mem[e.p3] = last; // "The P3 register is updated with the ' generated record number."
            } else if (e.opcode == uint256(Opcode.Blob)) {
                if (DEBUG) console.log("Blob (partial) | p1: %s, p2: %s, p4: %s", e.p1, e.p2, e.p4);
                if (DEBUG) console.log("  \\--> data: %s", mem[e.p4]);
                mem[e.p2] = mem[e.p4];
            } else if (e.opcode == uint256(Opcode.MakeRecord)) {
                // NOTE: it does not seem to say so in the documentation, but the output is written to p3.
                if (DEBUG) console.log("MakeRecord: %s-%s", e.p1, e.p1 + e.p2 - 1);
                for (uint256 i = 0; i < e.p2; i++) {
                    if (DEBUG) console.log("  %s: %s", e.p1 + i, mem[e.p1 + i]);
                    // mem[e.p3 + i] = mem[e.p1 + i];
                }

                uint256 sslot = _makeRow(mem, e.p1, e.p2);
                if (DEBUG) console.log("  (sslot: %s)", sslot);
                mem[e.p3] = sslot;
            } else if (e.opcode == uint256(Opcode.Insert)) {
                // NOTE: doc is very unclear about flag == 0x08...
                uint256 key = mem[e.p3];
                uint256 sslot = mem[e.p2];
                
                if (DEBUG) console.log("Insert [%s] %s -> %s", e.p1, key, sslot);
                tables[e.tbl()].insert(key, sslot);
            } else if (e.opcode == uint256(Opcode.IdxInsert)) {
                // NOTE: doc is very unclear about flag == 0x08...
                uint256 key = mem[e.p3];
                uint256 sslot = mem[e.p2];

                if (DEBUG) console.log("IdxInsert [%s] %s -> %s", e.p1, key, sslot);
                tables[e.tbl()].insert(key, sslot);
            } else if (e.opcode == uint256(Opcode.Delete)) {
                uint256 key = e.ptr();
                uint256 sslot = tables[e.tbl()].nodes[key].sslot;
                
                require(e.p5 & 2 == 2, "OPFLAG_SAVEPOSITION should be set");
                uint256 ptr = tables[e.tbl()].prev(e.ptr());
                require(ptr != 0, "Should always exits a node at head");
                e.ptr(ptr); // move to the prev node

                if (DEBUG) console.log("Delete [%s] %s -> %s", e.p1, key, sslot);
                tables[e.tbl()].remove(key);
                // TODO: should purge on Delete?
                _deleteRow(sslot);
            } else if (e.opcode == uint256(Opcode.IdxDelete)) {
                uint256 key = mem[e.p2];

                if (DEBUG) console.log("IdxDelete [%s] %s", e.p1, key);
                tables[e.tbl()].remove(key);
                // TODO: should IdxDelete also purge?
                // _deleteRow();
            }

            //*** CURSOR OPERATIONS ***/
             else if (e.opcode == uint256(Opcode.Prev)) {
                // jump if has more rows
                uint256 ptr = tables[e.tbl()].prev(e.ptr());
                if (ptr > 0) {
                    if (DEBUG) console.log("Prev %s", ptr);
                    e.ptr(ptr);
                    e.pc = e.p2;
                    continue;
                } else {
                    if (DEBUG) console.log("Prev (end.)");
                }
            } else if (e.opcode == uint256(Opcode.Next)) {
                uint256 ptr = tables[e.tbl()].next(e.ptr());
                if (ptr > 0) {
                    if (DEBUG) console.log("Next %s", ptr);
                    e.ptr(ptr);
                    e.pc = e.p2;
                    continue;
                } else {
                    if (DEBUG) console.log("Next (end.)");
                }
            }

            //*** CONTROL FLOW ***//
            else if (e.opcode == uint256(Opcode.Goto)) {
                if (DEBUG) console.log("Goto %s", e.p2);
                e.pc = e.p2;
                continue;
            } else if (e.opcode == uint256(Opcode.Halt)) {
                if (e.p1 == 0) {
                    if (DEBUG) console.log("Halt. (success)");
                    break;
                } else {
                    // TODO: don't always revert, check e.p2
                    if (DEBUG) console.log("Halt. (error: %s / %s)", e.p1, e.p2);
                    revert("Halt caused rollback");
                }
            } else if (e.opcode == uint256(Opcode.HaltIfNull)) {
                // TODO: depends if 0 is treated as NULL or else NULL should be ignored?
                if (e.p3 == 0) {
                    if (e.p1 == 0) {
                        if (DEBUG) console.log("HaltIfNull. (success)");
                        break;
                    } else {
                        // TODO: don't always revert, check e.p2
                        if (DEBUG) console.log("HaltIfNull. (error: %s / %s)", e.p1, e.p2);
                        revert("Halt caused rollback");
                    }
                }
            } else if (e.opcode == uint256(Opcode.IfNotZero)) {
                // TODO: edge cases
                if (mem[e.p1] != 0) {
                    if (DEBUG) console.log("IfNotZero (taken)");
                    e.pc = e.p2;
                    continue;
                } else {
                    if (DEBUG) console.log("IfNotZero (NOT taken)");
                    mem[e.p1]--;
                }
            }
            //*** DATABASE **//
            else if (e.opcode == uint256(Opcode.Close)) {
                // TODO: cleanup cursor somehow?
                // e.cursors[e.p1] = Cursor({tbl: 0, ptr: 0});
                if (DEBUG) console.log("Close (ignored)");
            } else if (e.opcode == uint256(Opcode.SeekRowid)) {
                uint256 seek_val = mem[e.p3];
                if (DEBUG) console.log("SeekRowid [%s] %s", e.p1, seek_val);
                uint256 min = tables[e.tbl()].treeMinimum(seek_val);
                if (min != seek_val) {
                    if (DEBUG) console.log("  \\--> not found!");
                    e.pc = e.p2;
                    continue;
                }

                if (DEBUG) console.log("  \\--> found.");
                e.ptr(seek_val);
            } else if (e.opcode == uint256(Opcode.Rowid)) {
                // TODO: is rowid always the key p1?
                uint256 rowid = e.ptr();
                if (DEBUG) console.log("Rowid [%s] => %s", e.p1, rowid);
                mem[e.p2] = rowid;
            } else if (e.opcode == uint256(Opcode.Column)) {
                // TODO: instead of e.pc need to extract p2-th element from table p1 (or null)
                // TODO: must use e.cursors map here...
                uint256 ptr = e.ptr();
                uint256 col = e.p2;
                uint256 sslot = tables[e.tbl()].nodes[ptr].sslot;

                mem[e.p3] = _readColumn(sslot + col);
                if (DEBUG) console.log("Column [%s] %s:%s", e.p1, ptr, col);
                if (DEBUG) console.log("  \\--> %s (%s + %s)", mem[e.p3], sslot, col);
            } else if (e.opcode == uint256(Opcode.ResultRow)) {
                if (DEBUG || true) {
                    console.log("ResultRow output: (%s columns)", e.p2);
                    for (uint256 i = 0; i < e.p2; i++) {
                        console.log("  %s: %s", e.p1 + i, mem[e.p1 + i]);
                    }
                }

                // if (e.p2 == 1) {
                //     console.log("      %s", mem[e.p1]);
                //     emit ResultRow1(mem[e.p1]);
                // } else if (e.p2 == 2) {
                //     console.log("      %s | %s", mem[e.p1], mem[e.p1 + 1]);
                //     emit ResultRow2(mem[e.p1], mem[e.p1 + 1]);
                // } else if (e.p2 == 3) {
                //     console.log("      %s | %s | %s", mem[e.p1], mem[e.p1 + 1], mem[e.p1 + 2]);
                //     emit ResultRow3(mem[e.p1], mem[e.p1 + 1], mem[e.p1 + 2]);
                // } else if (e.p2 == 4) {
                //     emit ResultRow4(mem[e.p1], mem[e.p1 + 1], mem[e.p1 + 3], mem[e.p1 + 4]);
                // } else {
                //     emit ResultRowThisWideNotImplemented();
                // }

                // TODO: emit row as log?
            } else if (e.opcode == uint256(Opcode.Rewind)) {
                Tree storage tbl = tables[e.tbl()];
                require(tbl.size > 0, "Tree size should always bigger than zero");
                
                if (tbl.size == 1) {
                    if (DEBUG) console.log("Rewind [%s] EMPTY TABLE", e.p1);
                    e.pc = e.p2 - 1;
                    return;
                }

                uint256 first = tbl.next(tbl.first());
                e.ptr(first);
                if (DEBUG) console.log("Rewind [%s] %s", e.p1, first);
            } else if (e.opcode == uint256(Opcode.Last)) {
                uint256 ptr = tables[e.tbl()].last();
                e.ptr(ptr);
                if (DEBUG) console.log("Last [%s] %s", e.p1, ptr);
            } else if (e.opcode == uint256(Opcode.Affinity)) {
                if (DEBUG) console.log("Affinity (ignored: %s)", e.p4);
            } else if (e.opcode == uint256(Opcode.ParseSchema)) {
                if (DEBUG) console.log("ParseSchema %s (ignored)", e.p4);
            } else if (e.opcode == uint256(Opcode.ReadCookie)) {
                if (DEBUG) console.log("ReadCookie (emulated)");
                mem[e.p2] = 123;
            } else if (e.opcode == uint256(Opcode.SetCookie)) {
                if (DEBUG) console.log("SetCookie (ignored)");
            } else if (e.opcode == uint256(Opcode.CreateBtree)) {
                if (DEBUG) console.log("CreateBtree (ignored)");
            } else if (e.opcode == uint256(Opcode.Noop)) {
                // no-op
                if (DEBUG) console.log("Noop");
            } else if (e.opcode == uint256(Opcode.AutoCommit)) {
                // no-op
                if (DEBUG) console.log("AutoCommit (ignored)");
            } else if (e.opcode == uint256(Opcode.JournalMode)) {
                // no-op
                if (DEBUG) console.log("JournalMode (ignored)");
            } else if (e.opcode == uint256(Opcode.MaxPgcnt)) {
                // no-op
                if (DEBUG) console.log("MaxPgcnt (ignored)");
            } else if (e.opcode == uint256(Opcode.MemMax)) {
                // no-op
                if (DEBUG) console.log("MemMax (ignored)");
            } else if (e.opcode == uint256(Opcode.Init)) {
                // Init is the first opcode and is processed outside the loop.
                // if there's an Init elsewhere, or more likely a jump to 0 then revert.
                revert("Init unexpected! reverting.");
            } else if (e.opcode == uint256(Opcode.Explain)) {
                // no-op
                // if (DEBUG) console.log("Explain (ignored)");
            } else {
                if (DEBUG) console.log("%s: UNKNOWN OPCODE", uint256(e.opcode));
                revert("unimplemented opcode");
            }
        
            e.pc++;
        }

        if (DEBUG) console.log("\n");
    }
}
