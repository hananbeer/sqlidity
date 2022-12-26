// this may help:
// https://sqlite.org/fileformat2.html

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Opcodes.sol";
import "./BokkyPooBahsRedBlackTreeLibrary.sol";

import "forge-std/console.sol";

contract Sqlite {
    using BokkyPooBahsRedBlackTreeLibrary for Tree;

    struct Instruction {
        uint256 opcode;
        uint256 p1;
        uint256 p2;
        uint256 p3;
        uint256 p4;
        uint256 p5;
    }

    uint256 immutable INS_SIZE = 32 * 6;
    
    // mapping (uint256 => Tree) public trees;
    mapping (uint256 => Tree) public tables;
    // Tree[] public tables;
    uint256 public countTables;

    constructor() {
        Tree storage table = _makeTable();

        // table.insert(1, 5);
        // table.insert(2, 25);
        // table.insert(3, 125);
        // table.insert(4, 99);
        table.insert(99, 99);
        table.insert(10001, 10001);

        // Tree storage index = _makeTable();
        // index.insert(5, 1);
        // index.insert(25, 2);
        // index.insert(125, 3);
        // index.insert(99, 4);
        // index.insert(999, 5);
        // index.insert(1001, 6);
    }

    function _makeTable() internal returns (Tree storage table) {
        table = tables[countTables];
        countTables++;
    }

    function _makeRow(uint256[] memory items, uint256 start, uint256 count) internal returns (uint256 sslot) {
        // hash is probably a bad idea because a single column can be mutated
        // TODO: need to be careful or change from hash, maybe nonce
        assembly {
            sslot := keccak256(add(add(items, 0x20), mul(start, 0x20)), mul(count, 0x20))
        }
        for (uint256 i = start; i < count; i++) {
            assembly {
                sstore(add(sslot, i), add(add(items, 0x20), mul(i, 0x20)))
            }
        }
    }

    function bytes32ToLiteralString(bytes32 data) 
        public
        pure
        returns (string memory result) 
    {
        bytes memory temp = new bytes(65);
        uint256 count;

        for (uint256 i = 0; i < 32; i++) {
            bytes1 currentByte = bytes1(data << (i * 8));
            
            uint8 c1 = uint8(
                bytes1((currentByte << 4) >> 4)
            );
            
            uint8 c2 = uint8(
                bytes1((currentByte >> 4))
            );
        
            if (c2 >= 0 && c2 <= 9) temp[++count] = bytes1(c2 + 48);
            else temp[++count] = bytes1(c2 + 87);
            
            if (c1 >= 0 && c1 <= 9) temp[++count] = bytes1(c1 + 48);
            else temp[++count] = bytes1(c1 + 87);
        }
        
        result = string(temp);
    }

    function execute(bytes calldata bytecode) public payable {
        // rowid should start at 1...
        uint256 rowid = 0;
        uint256 record_size = 0;

        Instruction memory ins = abi.decode(bytecode[0:INS_SIZE], (Instruction));

        uint256[] memory mem = new uint256[](100);
        
        // always start with Init opcode
        require(ins.opcode == uint256(Opcode.Init), "must start with Init opcode");
        uint256 init_pc = ins.p2 * INS_SIZE;
        if (init_pc == 0)
            init_pc = INS_SIZE;

        for (uint256 pc = init_pc; pc < bytecode.length; pc += INS_SIZE) {
            require(pc + INS_SIZE <= bytecode.length, "unexpected bytecode end");
            Instruction memory ins = abi.decode(bytecode[pc:pc + INS_SIZE], (Instruction));
            // console.log("%s - ???", uint256(ins.opcode));

            if (ins.opcode == uint256(Opcode.Init)) {
                // advance PC (-1 because the loop will advance one more INS_SIZE)
                pc = (ins.p2 - 1) * INS_SIZE;
            }
            /*
            TRANSACTIONS
            */
            else if (ins.opcode == uint256(Opcode.Transaction)) {
                // TODO: impl. no op for now
                console.log("Transaction started (ignored)");
            } else if (ins.opcode == uint256(Opcode.OpenRead)) {
                // TODO: impl. no op for now
                console.log("OpenRead (ignored)");
            } else if (ins.opcode == uint256(Opcode.OpenWrite)) {
                // TODO: impl. no op for now
                console.log("OpenWrite (ignored)");
            } else if (ins.opcode == uint256(Opcode.Init)) {
                revert("Init unexpected! reverting.");
            } else if (ins.opcode == uint256(Opcode.InitCoroutine)) { revert("unimplemented opcode");
            } else if (ins.opcode == uint256(Opcode.EndCoroutine)) { revert("unimplemented opcode");
            } else if (ins.opcode == uint256(Opcode.Yield)) { revert("unimplemented opcode");
            }
            /*
            CONSTANTS
            */
            else if (ins.opcode == uint256(Opcode.Integer)) {
                // if (ins.p2 == 1) {
                //     ins.p2 = 2; // STUPID PATCH
                //     console.log("(!!! INTEGER PATCHED !!!)");
                // }
                console.log("Integer %s <- %s", ins.p2, ins.p1);
                mem[ins.p2] = ins.p1;
            } else if (ins.opcode == uint256(Opcode.Real)) {
                // mem[ins.p2] = ins.p4;
                revert("Real unsupported");
            } else if (ins.opcode == uint256(Opcode.String)) {
                /*
                The string value P4 of length P1 (bytes) is stored in register P2.
                If P3 is not zero and the content of register P3 is equal to P5, then the datatype of the register P2 is converted to BLOB. The content is the same sequence of bytes, it is merely interpreted as a BLOB instead of a string, as if it had been CAST. In other words:

                if( P3!=0 and reg[P3]==P5 ) reg[P2] := CAST(reg[P2] as BLOB)
                */
                // TODO: calc length
                // mem[ins.p2] = ins.p4;
                console.log("String unimplemented");
                //mem[ins.p1] = strlen(ins.p4);
            } else if (ins.opcode == uint256(Opcode.String8)) {
                /*
                P4 points to a nul terminated UTF-8 string. This opcode is transformed into a String opcode before it is executed for the first time. During this transformation, the length of string P4 is computed and stored as the P1 parameter.
                */
                // TODO: calc length
                // mem[ins.p2] = ins.p4;
                console.log("String unimplemented");
                //mem[ins.p1] = strlen(ins.p4);
            } else if (ins.opcode == uint256(Opcode.Null)) {
                console.log("Null");
                mem[ins.p2++] = 0;
                while (ins.p2 < ins.p3)
                    mem[ins.p2++] = 0;
            } else if (ins.opcode == uint256(Opcode.SoftNull)) {
                /*
                Set register P1 to have the value NULL as seen by the MakeRecord instruction, but do not free any string or blob memory associated with the register, so that if the value was a string or blob that was previously copied using SCopy, the copies will continue to be valid.
                */
                // NOTE: normally when doing:
                // INSERT INTO tbl(id) VALUES(NULL)
                // it will auto-increment the id (starting from 1), BUT
                // INSERT INTO tbl(id) VALUES(0)
                // will insert a 0! however, here I'm ignoring NULLs
                // and everything is treated as zero, hence zero id is not possible
                console.log("SoftNull (translated as zero)");
                mem[ins.p1] = 0;
            }
            /*
            COMPARSIONS
            */
            else if (ins.opcode == uint256(Opcode.If)) {
                /*
                Jump to P2 if the value in register P1 is true. The value is considered true if it is numeric and non-zero. If the value in P1 is NULL then take the jump if and only if P3 is non-zero.
                */
                // TODO: edge cases
                if (mem[ins.p1] != 0) {
                    pc = (ins.p2 - 1) * INS_SIZE;
                    console.log("If (taken)");
                } else {
                    console.log("If (NOT taken)");
                }
            } else if (ins.opcode == uint256(Opcode.Eq)) {
                /*
                Compare the values in register P1 and P3. If reg(P3)==reg(P1) then jump to address P2.
                The SQLITE_AFF_MASK portion of P5 must be an affinity character - SQLITE_AFF_TEXT, SQLITE_AFF_INTEGER, and so forth. An attempt is made to coerce both inputs according to this affinity before the comparison is made. If the SQLITE_AFF_MASK is 0x00, then numeric affinity is used. Note that the affinity conversions are stored back into the input registers P1 and P3. So this opcode can cause persistent changes to registers P1 and P3.
                Once any conversions have taken place, and neither value is NULL, the values are compared. If both values are blobs then memcmp() is used to determine the results of the comparison. If both values are text, then the appropriate collating function specified in P4 is used to do the comparison. If P4 is not specified then memcmp() is used to compare text string. If both values are numeric, then a numeric comparison is used. If the two values are of different types, then numbers are considered less than strings and strings are considered less than blobs.
                If SQLITE_NULLEQ is set in P5 then the result of comparison is always either true or false and is never NULL. If both operands are NULL then the result of comparison is true. If either operand is NULL then the result is false. If neither operand is NULL the result is the same as it would be if the SQLITE_NULLEQ flag were omitted from P5.
                This opcode saves the result of comparison for use by the new Jump opcode.
                */
                console.log("Eq");
                if (mem[ins.p3] == mem[ins.p1]) {
                    pc = (ins.p2 - 1) * INS_SIZE;
                }
            } else if (ins.opcode == uint256(Opcode.Ne)) {
                /*
                This works just like the Eq opcode except that the jump is taken if the operands in registers P1 and P3 are not equal. See the Eq opcode for additional information.
                */
                console.log("Ne");
                if (mem[ins.p3] != mem[ins.p1]) {
                    pc = (ins.p2 - 1) * INS_SIZE;
                }
            } else if (ins.opcode == uint256(Opcode.Lt)) {
                console.log("Lt");
                if (mem[ins.p3] < mem[ins.p1]) {
                    pc = (ins.p2 - 1) * INS_SIZE;
                }
            } else if (ins.opcode == uint256(Opcode.Le)) {
                console.log("Le");
                if (mem[ins.p3] <= mem[ins.p1]) {
                    pc = (ins.p2 - 1) * INS_SIZE;
                }
            } else if (ins.opcode == uint256(Opcode.Gt)) {
                console.log("Gt");
                if (mem[ins.p3] > mem[ins.p1]) {
                    pc = (ins.p2 - 1) * INS_SIZE;
                }
            } else if (ins.opcode == uint256(Opcode.Ge)) {
                console.log("Ge");
                if (mem[ins.p3] >= mem[ins.p1]) {
                    pc = (ins.p2 - 1) * INS_SIZE;
                }
            } else if (ins.opcode == uint256(Opcode.NotNull)) {
                /*
                Jump to P2 if the value in register P1 is not NULL.
                */
                // TODO: impl. NULL as 0x80..00?
                if (mem[ins.p1] != 0) {
                    pc = (ins.p2 - 1) * INS_SIZE;
                    console.log("NotNull (taken)");
                } else {
                    console.log("NotNull (NOT taken)");
                }
            } else if (ins.opcode == uint256(Opcode.NotExists)) {
                /*
                P1 is the index of a cursor open on an SQL table btree (with integer keys). P3 is an integer rowid. If P1 does not contain a record with rowid P3 then jump immediately to P2. Or, if P2 is 0, raise an SQLITE_CORRUPT error. If P1 does contain a record with rowid P3 then leave the cursor pointing at that record and fall through to the next instruction.
                The SeekRowid opcode performs the same operation but also allows the P3 register to contain a non-integer value, in which case the jump is always taken. This opcode requires that P3 always contain an integer.

                The NotFound opcode performs the same operation on index btrees (with arbitrary multi-value keys).

                This opcode leaves the cursor in a state where it cannot be advanced in either direction. In other words, the Next and Prev opcodes will not work following this opcode.

                See also: Found, NotFound, NoConflict, SeekRowid
                */
                // TODO: is it p1 or mem[p1] ???
                uint256 index = mem[ins.p3];
                console.log("NotExists; tbl: %s, index: %s, jump: %s", ins.p1, index, ins.p2);
                if (tables[ins.p1].exists(index)) {
                    console.log("  \\--> key exists.");
                } else {
                    console.log("  \\--> key DOES NOT exist.");
                    pc = (ins.p2 - 1) * INS_SIZE;
                }
            } else if (ins.opcode == uint256(Opcode.NoConflict)) {
                /*
                If P4==0 then register P3 holds a blob constructed by MakeRecord. If P4>0 then register P3 is the first of P4 registers that form an unpacked record.
                Cursor P1 is on an index btree. If the record identified by P3 and P4 contains any NULL value, jump immediately to P2. If all terms of the record are not-NULL then a check is done to determine if any row in the P1 index btree has a matching key prefix. If there are no matches, jump immediately to P2. If there is a match, fall through and leave the P1 cursor pointing to the matching row.

                This opcode is similar to NotFound with the exceptions that the branch is always taken if any part of the search key input is NULL.

                This operation leaves the cursor in a state where it cannot be advanced in either direction. In other words, the Next and Prev opcodes do not work after this operation.

                See also: NotFound, Found, NotExists
                */
                // TODO: check all P4 arguments (or blob if P4 == 0)
                uint256 index = mem[ins.p3];
                console.log("NoConflict; tbl: %s, p3: %s, p4: %s", ins.p1, ins.p3, ins.p4);
                bool conflicted = false;
                // TODO: multiple columns conflict (count should be stored in MakeRecord -> _makeRow -> sslot MSB?)
                for (uint256 i = 0; i < 1/*ins.p2*/; i++) {
                    if (tables[ins.p1 + i].exists(index)) {
                        conflicted = true;
                        break;
                    }
                }
                if (conflicted) {
                    console.log("  \\--> CONFLICT!");
                } else {
                    // if there is no conflict, jump to p2
                    console.log("  \\--> no conflict.");
                    pc = (ins.p2 - 1) * INS_SIZE;
                }
            }
            /*
            ARITHMETIC
            */
            else if (ins.opcode == uint256(Opcode.AddImm)) {
                revert("AddImm unimplemented");
            }
            /*
            TYPES
            */
            else if (ins.opcode == uint256(Opcode.MustBeInt)) {
                /*
                Force the value in register P1 to be an integer. If the value in P1 is not an integer and cannot be converted into an integer without data loss, then jump immediately to P2, or if P2==0 raise an SQLITE_MISMATCH exception.
                */
                console.log("MustBeInt (ignored)");
            }

            /*
            RECORDS
            */
            else if (ins.opcode == uint256(Opcode.Copy)) {
                revert("Copy unimplemented");
            } else if (ins.opcode == uint256(Opcode.SCopy)) {
                /*
                Make a shallow copy of register P1 into register P2.
                This instruction makes a shallow copy of the value. If the value is a string or blob, then the copy is only a pointer to the original and hence if the original changes so will the copy. Worse, if the original is deallocated, the copy becomes invalid. Thus the program must guarantee that the original will not change during the lifetime of the copy. Use Copy to make a complete copy.
                */
                // TODO: check if extra work needed to copy strings and blobs too
                mem[ins.p2] = mem[ins.p1];
                console.log("SCopy %s <- %s", ins.p2, mem[ins.p1]);
            } else if (ins.opcode == uint256(Opcode.IntCopy)) {
                /*
                Transfer the integer value held in register P1 into register P2.
                This is an optimized version of SCopy that works only for integer values.
                */
                // TODO: validate int?
                mem[ins.p2] = mem[ins.p1];
                console.log("MakeInt %s <- %s", ins.p2, mem[ins.p1]);
            } else if (ins.opcode == uint256(Opcode.NewRowid)) {
                mem[ins.p2] = tables[ins.p1].size + 1;
                // mem[ins.p3] = mem[ins.p2]; // "The P3 register is updated with the ' generated record number."
                console.log("NewRowid (emulated): %s", mem[ins.p2]);
            } else if (ins.opcode == uint256(Opcode.Blob)) {
                /*
                P4 points to a blob of data P1 bytes long. Store this blob in register P2. If P4 is a NULL pointer, then construct a zero-filled blob that is P1 bytes long in P2.
                */
                console.log("Blob (ignored) | p1: %s, p2: %s, p4: %s", ins.p1, ins.p2, ins.p4);
                console.log("  \\--> data: %s", mem[ins.p4]);
                mem[ins.p2] = mem[ins.p4];
            } else if (ins.opcode == uint256(Opcode.MakeRecord)) {
                /*
                Convert P2 registers beginning with P1 into the record format use as a data record in a database table or as a key in an index. The Column opcode can decode the record later.
                P4 may be a string that is P2 characters long. The N-th character of the string indicates the column affinity that should be used for the N-th field of the index key.

                The mapping from character to affinity is given by the SQLITE_AFF_ macros defined in sqliteInt.h.

                If P4 is NULL then all index fields have the affinity BLOB.

                The meaning of P5 depends on whether or not the SQLITE_ENABLE_NULL_TRIM compile-time option is enabled:

                * If SQLITE_ENABLE_NULL_TRIM is enabled, then the P5 is the index of the right-most table that can be null-trimmed.

                * If SQLITE_ENABLE_NULL_TRIM is omitted, then P5 has the value OPFLAG_NOCHNG_MAGIC if the MakeRecord opcode is allowed to accept no-change records with serial_type 10. This value is only used inside an assert() and does not affect the end result.
                */
                // NOTE: it does not seem to say so in the documentation, but the output is written to p3.
                console.log("MakeRecord (emulated): %s-%s", ins.p1, ins.p1 + ins.p2 - 1);
                for (uint256 i = 0; i < ins.p2; i++) {
                    console.log("  %s: %s", ins.p1 + i, mem[ins.p1 + i]);
                    // mem[ins.p3 + i] = mem[ins.p1 + i];
                }

                // cache record_size for Insert
                record_size = ins.p2;
                uint256 sslot = _makeRow(mem, ins.p1, record_size);
                console.log("  (sslot: %s)", sslot);
                mem[ins.p3] = sslot;

            } else if (ins.opcode == uint256(Opcode.Insert)) {
                /*
                Write an entry into the table of cursor P1. A new entry is created if it doesn't already exist or the data for an existing entry is overwritten. The data is the value MEM_Blob stored in register number P2. The key is stored in register P3. The key must be a MEM_Int.
                If the OPFLAG_NCHANGE flag of P5 is set, then the row change count is incremented (otherwise not). If the OPFLAG_LASTROWID flag of P5 is set, then rowid is stored for subsequent return by the sqlite3_last_insert_rowid() function (otherwise it is unmodified).

                If the OPFLAG_USESEEKRESULT flag of P5 is set, the implementation might run faster by avoiding an unnecessary seek on cursor P1. However, the OPFLAG_USESEEKRESULT flag must only be set if there have been no prior seeks on the cursor or if the most recent seek used a key equal to P3.

                If the OPFLAG_ISUPDATE flag is set, then this opcode is part of an UPDATE operation. Otherwise (if the flag is clear) then this opcode is part of an INSERT operation. The difference is only important to the update hook.

                Parameter P4 may point to a Table structure, or may be NULL. If it is not NULL, then the update-hook (sqlite3.xUpdateCallback) is invoked following a successful insert.

                (WARNING/TODO: If P1 is a pseudo-cursor and P2 is dynamically allocated, then ownership of P2 is transferred to the pseudo-cursor and register P2 becomes ephemeral. If the cursor is changed, the value of register P2 will then change. Make sure this does not cause any problems.)

                This instruction only works on tables. The equivalent instruction for indices is IdxInsert.
                */
                // NOTE: doc is very unclear about flag == 0x08...
                uint256 key = mem[ins.p3];
                uint256 value = mem[ins.p2];
                
                // TODO: remove this stupid patch...
                // if (value == 0)
                //     value = tables[ins.p1].size + 1;

                console.log("Insert [%s] %s -> %s", ins.p1, key, value);
                tables[ins.p1].insert(key, value);
                record_size = 0;
            } else if (ins.opcode == uint256(Opcode.IdxInsert)) {
                // NOTE: doc is very unclear about flag == 0x08...
                uint256 key = mem[ins.p3];
                uint256 value = mem[ins.p2];

                // TODO: remove this stupid patch...
                // if (value == 0)
                //     value = tables[ins.p1].size + 1;

                console.log("IdxInsert [%s] %s -> %s", ins.p1, key, value);
                tables[ins.p1].insert(key, value);
                record_size = 0;
            }
            /*
            CONTROL FLOW
            */
            else if (ins.opcode == uint256(Opcode.Goto)) {
                console.log("Goto %s", ins.p2);
                pc = (ins.p2 - 1) * INS_SIZE;
            } else if (ins.opcode == uint256(Opcode.Prev)) {
                // jump if has more rows
                rowid = tables[ins.p1].prev(rowid);
                if (rowid > 0) {
                    console.log("Prev %s", rowid);
                    pc = (ins.p2 - 1) * INS_SIZE;
                } else {
                    console.log("Prev (end.)");
                }
            } else if (ins.opcode == uint256(Opcode.Next)) {
                /*
                Advance cursor P1 so that it points to the next key/data pair in its table or index. If there are no more key/value pairs then fall through to the following instruction. But if the cursor advance was successful, jump immediately to P2.
                */
                // simulate items only once...
                // jump if has more rows
                rowid = tables[ins.p1].next(rowid);
                if (rowid > 0) {
                    console.log("Next %s", rowid);
                    pc = (ins.p2 - 1) * INS_SIZE;
                } else {
                    console.log("Next (end.)");
                }
            } else if (ins.opcode == uint256(Opcode.Halt)) {
                /*
                Exit immediately. All open cursors, etc are closed automatically.
                P1 is the result code returned by sqlite3_exec(), sqlite3_reset(), or sqlite3_finalize(). For a normal halt, this should be SQLITE_OK (0). For errors, it can be some other value. If P1!=0 then P2 will determine whether or not to rollback the current transaction. Do not rollback if P2==OE_Fail. Do the rollback if P2==OE_Rollback. If P2==OE_Abort, then back out all changes that have occurred during this execution of the VDBE, but do not rollback the transaction.

                If P4 is not null then it is an error message string.

                P5 is a value between 0 and 4, inclusive, that modifies the P4 string.

                0: (no change) 1: NOT NULL contraint failed: P4 2: UNIQUE constraint failed: P4 3: CHECK constraint failed: P4 4: FOREIGN KEY constraint failed: P4

                If P5 is not zero and P4 is NULL, then everything after the ":" is omitted.

                There is an implied "Halt 0 0 0" instruction inserted at the very end of every program. So a jump past the last instruction of the program is the same as executing Halt.
                */
                if (ins.p1 == 0) {
                    console.log("Halt. (success)");
                    break;
                } else {
                    // TODO: don't always revert, check ins.p2
                    console.log("Halt. (error: %s / %s)", ins.p1, ins.p2);
                    revert("Halt caused rollback");
                }
            } else if (ins.opcode == uint256(Opcode.HaltIfNull)) {
                revert("HaltIfNull unimplemented");
            }
            /*
            DATABASE
            */
            else if (ins.opcode == uint256(Opcode.Close)) {
                console.log("Close unimplemented");
            } else if (ins.opcode == uint256(Opcode.Rowid)) {
                console.log("Rowid %s", rowid);
                // TODO: take rowid with respect to table entry p1
                mem[ins.p2] = rowid;
            } else if (ins.opcode == uint256(Opcode.Column)) {
                /*
                Interpret the data that cursor P1 points to as a structure built using the MakeRecord instruction. (See the MakeRecord opcode for additional information about the format of the data.) Extract the P2-th column from this record. If there are less that (P2+1) values in the record, extract a NULL.
                The value extracted is stored in register P3.
                If the record contains fewer than P2 fields, then extract a NULL. Or, if the P4 argument is a P4_MEM use the value of the P4 argument as the result.
                If the OPFLAG_LENGTHARG and OPFLAG_TYPEOFARG bits are set on P5 then the result is guaranteed to only be used as the argument of a length() or typeof() function, respectively. The loading of large blobs can be skipped for length() and all content loading can be skipped for typeof().
                */
                // TODO: instead of pc need to extract p2-th element from table p1 (or null)
                mem[ins.p3] = tables[ins.p2].nodes[rowid].sslot;
                console.log("Column %s:%s => %s", rowid, ins.p2, mem[ins.p3]);
            } else if (ins.opcode == uint256(Opcode.Affinity)) {
                console.log("Affinity (ignored: %s)", ins.p4);
            } else if (ins.opcode == uint256(Opcode.ResultRow)) {
                console.log("ResultRow output: (%s columns)", ins.p2);
                for (uint256 i = 0; i < ins.p2; i++) {
                    console.log("  %s: %s", ins.p1 + i, mem[ins.p1 + i]);
                }
                // TODO: emit row as log?
            } else if (ins.opcode == uint256(Opcode.Rewind)) {
                /*
                The next use of the Rowid or Column or Next instruction for P1 will refer to the first entry in the database table or index. If the table or index is empty, jump immediately to P2. If the table or index is not empty, fall through to the following instruction.
                This opcode leaves the cursor configured to move in forward order, from the beginning toward the end. In other words, the cursor is configured to use Next, not Prev.
                */
                // TODO: jump to p2 if needed
                // TODO: should be first() not 1...
                rowid = tables[ins.p1].first();
                console.log("Rewind %s (partially implemented): %s", ins.p1, rowid);
            } else if (ins.opcode == uint256(Opcode.Last)) {
                // TODO: set rowid to the last element in the table
                //rowid = -1;
                // TODO: should be last() not size...
                rowid = tables[ins.p1].size;
                console.log("Last %s (partially implemented): %s", ins.p1, rowid);
            } else if (ins.opcode == uint256(Opcode.Noop)) {
                // no-op
                console.log("No-op");
            } else if (ins.opcode == uint256(Opcode.Explain)) {
                // no-op (?)
                // console.log("Explain (ignored)");
            } else if (ins.opcode == uint256(Opcode.ParseSchema)) {
                console.log("ParseSchema %s (ignored)", bytes32ToLiteralString(bytes32(ins.p4)));
            } else if (ins.opcode == uint256(Opcode.ReadCookie)) {
                console.log("ReadCookie (emulated)");
                mem[ins.p2] = 123;
            } else if (ins.opcode == uint256(Opcode.SetCookie)) {
                console.log("SetCookie (ignored)");
            } else if (ins.opcode == uint256(Opcode.CreateBtree)) {
                console.log("CreateBtree (ignored - only main table)");
            } else {
                console.log("%s: UNKNOWN OPCODE", uint256(ins.opcode));
                revert("unimplemented opcode");
            }
        }

        console.log("\n");
    }
}


/*
NOTES:
- tables without primary key will have additional column `rowid` (or oid or _rowid_) as the primary key
- tables that specify "WITHOUT ROWID" *MUST* have a primary key
--> it also seems that tables that have WITHOUT ROWID & primary key (must) will be the same row..

- to sqlidity, in my understanding, Insert is just InsertIdx for the PRIMARY KEY.
-- there should be no difference (?) in impl. (need to verify this claim)

- I'm not sure if it's safe to just transfer opcodes since the sql query compiler actually does a lot of sanity checks on it's own...

- check if it is safe to ignore OpenWrite / OpenRead and just assume a single table in db for now..? (contract = table?? I don't think it should be)

I think the following distinction does not exist for sqlidity hence should only support either one of PRIMARY KEY / UNIQUE
(also what's the point of having a NULL in a unique table.......)

What Is Primary Key?
The primary key is the minimum set of traits that distinguishes any row of a table. It cannot have NULL and duplicate values. The primary key is used to add integrity to the table.

In the case of a primary key, both Duplicate and NULL values are not valid. And, it can be utilized as foreign keys for different tables.

What Is a Unique Key?
A unique Key is an individual value that is used to protect duplicate values in a column. The foremost purpose of a unique key in a table is to prevent duplicate values. However, when it comes to a unique value, the primary key also includes it. So, there is one big difference that makes a unique key different, and it is: a unique key can have a NULL value which is not supported in a primary key.

-- one point that may be interesting to investigate:

Index:
    The primary key tends to generate a clustered index by default.
    The unique key tends to generate a non-clustered index.
*/