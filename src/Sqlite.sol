// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./RedBlackBinaryTree.sol";

import "forge-std/console.sol";

enum Opcode {
  Savepoint, // 0,
  AutoCommit, // 1,
  Transaction, // 2,
  SorterNext, // 3, /* jump                                       */
  Prev, // 4, /* jump                                       */
  Next, // 5, /* jump                                       */
  Checkpoint, // 6,
  JournalMode, // 7,
  Vacuum, // 8,
  VFilter, // 9, /* jump, synopsis: iplan=r[P3] zplan='P4'     */
  VUpdate, // 10, /* synopsis: data=r[P3@P2]                    */
  Goto, // 11, /* jump                                       */
  Gosub, // 12, /* jump                                       */
  InitCoroutine, // 13, /* jump                                       */
  Yield, // 14, /* jump                                       */
  MustBeInt, // 15, /* jump                                       */
  Jump, // 16, /* jump                                       */
  Once, // 17, /* jump                                       */
  If, // 18, /* jump                                       */
  Not, // 19, /* same as TK_NOT, synopsis: r[P2]= !r[P1]    */
  IfNot, // 20, /* jump                                       */
  IfNullRow, // 21, /* jump, synopsis: if P1.nullRow then r[P3]=NULL, goto P2, */
  SeekLT, // 22, /* jump, synopsis: key=r[P3@P4]               */
  SeekLE, // 23, /* jump, synopsis: key=r[P3@P4]               */
  SeekGE, // 24, /* jump, synopsis: key=r[P3@P4]               */
  SeekGT, // 25, /* jump, synopsis: key=r[P3@P4]               */
  IfNotOpen, // 26, /* jump, synopsis: if( !csr[P1] ) goto P2,     */
  IfNoHope, // 27, /* jump, synopsis: key=r[P3@P4]               */
  NoConflict, // 28, /* jump, synopsis: key=r[P3@P4]               */
  NotFound, // 29, /* jump, synopsis: key=r[P3@P4]               */
  Found, // 30, /* jump, synopsis: key=r[P3@P4]               */
  SeekRowid, // 31, /* jump, synopsis: intkey=r[P3]               */
  NotExists, // 32, /* jump, synopsis: intkey=r[P3]               */
  Last, // 33, /* jump                                       */
  IfSmaller, // 34, /* jump                                       */
  SorterSort, // 35, /* jump                                       */
  Sort, // 36, /* jump                                       */
  Rewind, // 37, /* jump                                       */
  IdxLE, // 38, /* jump, synopsis: key=r[P3@P4]               */
  IdxGT, // 39, /* jump, synopsis: key=r[P3@P4]               */
  IdxLT, // 40, /* jump, synopsis: key=r[P3@P4]               */
  IdxGE, // 41, /* jump, synopsis: key=r[P3@P4]               */
  RowSetRead, // 42, /* jump, synopsis: r[P3]=rowset(P1)           */
  Or, // 43, /* same as TK_OR, synopsis: r[P3]=(r[P1] || r[P2]) */
  And, // 44, /* same as TK_AND, synopsis: r[P3]=(r[P1] && r[P2]) */
  RowSetTest, // 45, /* jump, synopsis: if r[P3] in rowset(P1) goto P2, */
  Program, // 46, /* jump                                       */
  FkIfZero, // 47, /* jump, synopsis: if fkctr[P1]==0, goto P2,    */
  IfPos, // 48, /* jump, synopsis: if r[P1]>0, then r[P1]-=P3, goto P2, */
  IfNotZero, // 49, /* jump, synopsis: if r[P1]!=0, then r[P1]--, goto P2, */
  IsNull, // 50, /* jump, same as TK_ISNULL, synopsis: if r[P1]==NULL goto P2, */
  NotNull, // 51, /* jump, same as TK_NOTNULL, synopsis: if r[P1]!=NULL goto P2, */
  Ne, // 52, /* jump, same as TK_NE, synopsis: IF r[P3]!=r[P1] */
  Eq, // 53, /* jump, same as TK_EQ, synopsis: IF r[P3]==r[P1] */
  Gt, // 54, /* jump, same as TK_GT, synopsis: IF r[P3]>r[P1] */
  Le, // 55, /* jump, same as TK_LE, synopsis: IF r[P3]<=r[P1] */
  Lt, // 56, /* jump, same as TK_LT, synopsis: IF r[P3]<r[P1] */
  Ge, // 57, /* jump, same as TK_GE, synopsis: IF r[P3]>=r[P1] */
  ElseNotEq, // 58, /* jump, same as TK_ESCAPE                    */
  DecrJumpZero, // 59, /* jump, synopsis: if (--r[P1])==0, goto P2,    */
  IncrVacuum, // 60, /* jump                                       */
  VNext, // 61, /* jump                                       */
  Init, // 62, /* jump, synopsis: Start at P2,                */
  PureFunc, // 63, /* synopsis: r[P3]=func(r[P2@NP])             */
  Function, // 64, /* synopsis: r[P3]=func(r[P2@NP])             */
  Return, // 65,
  EndCoroutine, // 66,
  HaltIfNull, // 67, /* synopsis: if r[P3]=null halt               */
  Halt, // 68,
  Integer, // 69, /* synopsis: r[P2]=P1,                         */
  Int64, // 70, /* synopsis: r[P2]=P4,                         */
  String, // 71, /* synopsis: r[P2]='P4' (len=P1)              */
  Null, // 72, /* synopsis: r[P2..P3]=NULL                   */
  SoftNull, // 73, /* synopsis: r[P1]=NULL                       */
  Blob, // 74, /* synopsis: r[P2]=P4, (len=P1)                */
  Variable, // 75, /* synopsis: r[P2]=parameter(P1,P4)           */
  Move, // 76, /* synopsis: r[P2@P3]=r[P1@P3]                */
  Copy, // 77, /* synopsis: r[P2@P3+1]=r[P1@P3+1]            */
  SCopy, // 78, /* synopsis: r[P2]=r[P1]                      */
  IntCopy, // 79, /* synopsis: r[P2]=r[P1]                      */
  ResultRow, // 80, /* synopsis: output=r[P1@P2]                  */
  CollSeq, // 81,
  AddImm, // 82, /* synopsis: r[P1]=r[P1]+P2,                   */
  RealAffinity, // 83,
  Cast, // 84, /* synopsis: affinity(r[P1])                  */
  Permutation, // 85,
  Compare, // 86, /* synopsis: r[P1@P3] <-> r[P2@P3]            */
  IsTrue, // 87, /* synopsis: r[P2] = coalesce(r[P1]==TRUE,P3) ^ P4, */
  Offset, // 88, /* synopsis: r[P3] = sqlite_offset(P1)        */
  Column, // 89, /* synopsis: r[P3]=PX                         */
  Affinity, // 90, /* synopsis: affinity(r[P1@P2])               */
  MakeRecord, // 91, /* synopsis: r[P3]=mkrec(r[P1@P2])            */
  Count, // 92, /* synopsis: r[P2]=count()                    */
  ReadCookie, // 93,
  SetCookie, // 94,
  ReopenIdx, // 95, /* synopsis: root=P2, iDb=P3,                   */
  OpenRead, // 96, /* synopsis: root=P2, iDb=P3,                   */
  OpenWrite, // 97, /* synopsis: root=P2, iDb=P3,                   */
  OpenDup, // 98,
  OpenAutoindex, // 99, /* synopsis: nColumn=P2,                       */
  OpenEphemeral, // 100, /* synopsis: nColumn=P2,                       */
  BitAnd, // 101, /* same as TK_BITAND, synopsis: r[P3]=r[P1]&r[P2] */
  BitOr, // 102, /* same as TK_BITOR, synopsis: r[P3]=r[P1]|r[P2] */
  ShiftLeft, // 103, /* same as TK_LSHIFT, synopsis: r[P3]=r[P2]<<r[P1] */
  ShiftRight, // 104, /* same as TK_RSHIFT, synopsis: r[P3]=r[P2]>>r[P1] */
  Add, // 105, /* same as TK_PLUS, synopsis: r[P3]=r[P1]+r[P2] */
  Subtract, // 106, /* same as TK_MINUS, synopsis: r[P3]=r[P2]-r[P1] */
  Multiply, // 107, /* same as TK_STAR, synopsis: r[P3]=r[P1]*r[P2] */
  Divide, // 108, /* same as TK_SLASH, synopsis: r[P3]=r[P2]/r[P1] */
  Remainder, // 109, /* same as TK_REM, synopsis: r[P3]=r[P2]%r[P1] */
  Concat, // 110, /* same as TK_CONCAT, synopsis: r[P3]=r[P2]+r[P1] */
  SorterOpen, // 111,
  BitNot, // 112, /* same as TK_BITNOT, synopsis: r[P2]= ~r[P1] */
  SequenceTest, // 113, /* synopsis: if( cursor[P1].ctr++ ) pc = P2,   */
  OpenPseudo, // 114, /* synopsis: P3, columns in r[P2]              */
  String8, // 115, /* same as TK_STRING, synopsis: r[P2]='P4'    */
  Close, // 116,
  ColumnsUsed, // 117,
  SeekHit, // 118, /* synopsis: seekHit=P2,                       */
  Sequence, // 119, /* synopsis: r[P2]=cursor[P1].ctr++           */
  NewRowid, // 120, /* synopsis: r[P2]=rowid                      */
  Insert, // 121, /* synopsis: intkey=r[P3] data=r[P2]          */
  Delete, // 122,
  ResetCount, // 123,
  SorterCompare, // 124, /* synopsis: if key(P1)!=trim(r[P3],P4) goto P2, */
  SorterData, // 125, /* synopsis: r[P2]=data                       */
  RowData, // 126, /* synopsis: r[P2]=data                       */
  Rowid, // 127, /* synopsis: r[P2]=rowid                      */
  NullRow, // 128,
  SeekEnd, // 129,
  IdxInsert, // 130, /* synopsis: key=r[P2]                        */
  SorterInsert, // 131, /* synopsis: key=r[P2]                        */
  IdxDelete, // 132, /* synopsis: key=r[P2@P3]                     */
  DeferredSeek, // 133, /* synopsis: Move P3, to P1.rowid if needed    */
  IdxRowid, // 134, /* synopsis: r[P2]=rowid                      */
  FinishSeek, // 135,
  Destroy, // 136,
  Clear, // 137,
  ResetSorter, // 138,
  CreateBtree, // 139, /* synopsis: r[P2]=root iDb=P1, flags=P3,       */
  SqlExec, // 140,
  ParseSchema, // 141,
  LoadAnalysis, // 142,
  DropTable, // 143,
  DropIndex, // 144,
  DropTrigger, // 145,
  IntegrityCk, // 146,
  RowSetAdd, // 147, /* synopsis: rowset(P1)=r[P2]                 */
  Param, // 148,
  FkCounter, // 149, /* synopsis: fkctr[P1]+=P2,                    */
  Real, // 150, /* same as TK_FLOAT, synopsis: r[P2]=P4,       */
  MemMax, // 151, /* synopsis: r[P1]=max(r[P1],r[P2])           */
  OffsetLimit, // 152, /* synopsis: if r[P1]>0, then r[P2]=r[P1]+max(0,r[P3]) else r[P2]=(-1) */
  AggInverse, // 153, /* synopsis: accum=r[P3] inverse(r[P2@P5])    */
  AggStep, // 154, /* synopsis: accum=r[P3] step(r[P2@P5])       */
  AggStep1, // 155, /* synopsis: accum=r[P3] step(r[P2@P5])       */
  AggValue, // 156, /* synopsis: r[P3]=value N=P2,                 */
  AggFinal, // 157, /* synopsis: accum=r[P1] N=P2,                 */
  Expire, // 158,
  CursorLock, // 159,
  CursorUnlock, // 160,
  TableLock, // 161, /* synopsis: iDb=P1, root=P2, write=P3,          */
  VBegin, // 162,
  VCreate, // 163,
  VDestroy, // 164,
  VOpen, // 165,
  VColumn, // 166, /* synopsis: r[P3]=vcolumn(P2)                */
  VRename, // 167,
  Pagecount, // 168,
  MaxPgcnt, // 169,
  Trace, // 170,
  CursorHint, // 171,
  ReleaseReg, // 172, /* synopsis: release r[P1@P2] mask P3,         */
  Noop, // 173,
  Explain, // 174,
  Abortable // 175,
}

contract Sqlite {
    using RedBlackBinaryTree for RedBlackBinaryTree.Tree;

    struct Instruction {
        uint256 opcode;
        uint256 p1;
        uint256 p2;
        uint256 p3;
        uint256 p4;
        uint256 p5;
    }

    // mapping (uint256 => RedBlackBinaryTree.Tree) public trees;
    RedBlackBinaryTree.Tree public main;

    constructor() {
        main.insert(4, 99);
        main.insert(5, 999);
        main.insert(6, 1001);
        main.insert(1, 5);
        main.insert(2, 25);
        main.insert(3, 125);
    }

    uint256 immutable INS_SIZE = 32 * 6;

    function execute(bytes calldata bytecode) public payable {
        uint256[100] memory mem;
        
        // rowid should start at 1...
        uint256 rowid = 0;

        // cache table size
        uint256 main_size = main.size;

        Instruction memory ins = abi.decode(bytecode[0:INS_SIZE], (Instruction));

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
                console.log("OpenRead ignored");
            } else if (ins.opcode == uint256(Opcode.OpenWrite)) {
                // TODO: impl. no op for now
            } else if (ins.opcode == uint256(Opcode.Init)) { revert("unimplemented opcode");
            } else if (ins.opcode == uint256(Opcode.InitCoroutine)) { revert("unimplemented opcode");
            } else if (ins.opcode == uint256(Opcode.EndCoroutine)) { revert("unimplemented opcode");
            } else if (ins.opcode == uint256(Opcode.Yield)) { revert("unimplemented opcode");
            }
            /*
            CONSTANTS
            */
            else if (ins.opcode == uint256(Opcode.Integer)) {
                mem[ins.p2] = ins.p1;
            } else if (ins.opcode == uint256(Opcode.Real)) {
                mem[ins.p2] = ins.p4;
            } else if (ins.opcode == uint256(Opcode.String)) {
                /*
                The string value P4 of length P1 (bytes) is stored in register P2.
                If P3 is not zero and the content of register P3 is equal to P5, then the datatype of the register P2 is converted to BLOB. The content is the same sequence of bytes, it is merely interpreted as a BLOB instead of a string, as if it had been CAST. In other words:

                if( P3!=0 and reg[P3]==P5 ) reg[P2] := CAST(reg[P2] as BLOB)
                */
                // TODO: calc length
                mem[ins.p2] = ins.p4;
                //mem[ins.p1] = strlen(ins.p4);
            } else if (ins.opcode == uint256(Opcode.String8)) {
                /*
                P4 points to a nul terminated UTF-8 string. This opcode is transformed into a String opcode before it is executed for the first time. During this transformation, the length of string P4 is computed and stored as the P1 parameter.
                */
                // TODO: calc length
                mem[ins.p2] = ins.p4;
                //mem[ins.p1] = strlen(ins.p4);
            } else if (ins.opcode == uint256(Opcode.Null)) {
                mem[ins.p2++] = 0;
                while (ins.p2 < ins.p3)
                    mem[ins.p2++] = 0;
            } else if (ins.opcode == uint256(Opcode.SoftNull)) { revert("unimplemented opcode");
            }
            /*
            COMPARSIONS
            */
            else if (ins.opcode == uint256(Opcode.Eq)) {
                /*
                Compare the values in register P1 and P3. If reg(P3)==reg(P1) then jump to address P2.
                The SQLITE_AFF_MASK portion of P5 must be an affinity character - SQLITE_AFF_TEXT, SQLITE_AFF_INTEGER, and so forth. An attempt is made to coerce both inputs according to this affinity before the comparison is made. If the SQLITE_AFF_MASK is 0x00, then numeric affinity is used. Note that the affinity conversions are stored back into the input registers P1 and P3. So this opcode can cause persistent changes to registers P1 and P3.
                Once any conversions have taken place, and neither value is NULL, the values are compared. If both values are blobs then memcmp() is used to determine the results of the comparison. If both values are text, then the appropriate collating function specified in P4 is used to do the comparison. If P4 is not specified then memcmp() is used to compare text string. If both values are numeric, then a numeric comparison is used. If the two values are of different types, then numbers are considered less than strings and strings are considered less than blobs.
                If SQLITE_NULLEQ is set in P5 then the result of comparison is always either true or false and is never NULL. If both operands are NULL then the result of comparison is true. If either operand is NULL then the result is false. If neither operand is NULL the result is the same as it would be if the SQLITE_NULLEQ flag were omitted from P5.
                This opcode saves the result of comparison for use by the new Jump opcode.
                */
                if (mem[ins.p3] == mem[ins.p1]) {
                    pc = (ins.p2 - 1) * INS_SIZE;
                }
            } else if (ins.opcode == uint256(Opcode.Ne)) {
                /*
                This works just like the Eq opcode except that the jump is taken if the operands in registers P1 and P3 are not equal. See the Eq opcode for additional information.
                */
                if (mem[ins.p3] != mem[ins.p1]) {
                    pc = (ins.p2 - 1) * INS_SIZE;
                }
            } else if (ins.opcode == uint256(Opcode.Lt)) {
                if (mem[ins.p3] < mem[ins.p1]) {
                    pc = (ins.p2 - 1) * INS_SIZE;
                }
            } else if (ins.opcode == uint256(Opcode.Le)) {
                if (mem[ins.p3] <= mem[ins.p1]) {
                    pc = (ins.p2 - 1) * INS_SIZE;
                }
            } else if (ins.opcode == uint256(Opcode.Gt)) {
                if (mem[ins.p3] > mem[ins.p1]) {
                    pc = (ins.p2 - 1) * INS_SIZE;
                }
            } else if (ins.opcode == uint256(Opcode.Ge)) {
                if (mem[ins.p3] >= mem[ins.p1]) {
                    pc = (ins.p2 - 1) * INS_SIZE;
                }
            } else if (ins.opcode == uint256(Opcode.NotNull)) {
                revert("unimplemented opcode");
                // TODO: impl. NULL as 0x80..00?
                if (mem[ins.p3] != 0) {
                    pc = (ins.p2 - 1) * INS_SIZE;
                }
            }
            /*
            ARITHMETIC
            */
            else if (ins.opcode == uint256(Opcode.AddImm)) { revert("unimplemented opcode");
            }
            /*
            RECORDS
            */
            else if (ins.opcode == uint256(Opcode.Copy)) { revert("unimplemented opcode");
            } else if (ins.opcode == uint256(Opcode.SCopy)) { revert("unimplemented opcode");
            } else if (ins.opcode == uint256(Opcode.NewRowid)) { revert("unimplemented opcode");
            } else if (ins.opcode == uint256(Opcode.MakeRecord)) { revert("unimplemented opcode");
            } else if (ins.opcode == uint256(Opcode.Insert)) { revert("unimplemented opcode");
            }
            /*
            CONTROL FLOW
            */
            else if (ins.opcode == uint256(Opcode.Goto)) {
                pc = ins.p2 * INS_SIZE;
                // console.log("Goto %s", ins.p2);
            } else if (ins.opcode == uint256(Opcode.Prev)) {
                // TODO: is this ok?
                rowid--;
                // jump if has more rows
                if (rowid > 0)
                    pc = (ins.p2 - 1) * INS_SIZE;
            } else if (ins.opcode == uint256(Opcode.Next)) {
                /*
                Advance cursor P1 so that it points to the next key/data pair in its table or index. If there are no more key/value pairs then fall through to the following instruction. But if the cursor advance was successful, jump immediately to P2.
                */
                rowid++;
                // simulate items only once...
                // jump if has more rows
                if (rowid <= main_size)
                    pc = (ins.p2 - 1) * INS_SIZE;
            } else if (ins.opcode == uint256(Opcode.Halt)) {
                console.log("Halt.");
                break;
            } else if (ins.opcode == uint256(Opcode.HaltIfNull)) { revert("unimplemented opcode");
            }
            /*
            DATABASE
            */
            else if (ins.opcode == uint256(Opcode.Close)) { revert("unimplemented opcode");
            } else if (ins.opcode == uint256(Opcode.Rowid)) {
                // TODO: take rowid with respect to table entry p1
                mem[ins.p2] = rowid;
                console.log("Rowid %s", rowid);
            } else if (ins.opcode == uint256(Opcode.Column)) {
                /*
                Interpret the data that cursor P1 points to as a structure built using the MakeRecord instruction. (See the MakeRecord opcode for additional information about the format of the data.) Extract the P2-th column from this record. If there are less that (P2+1) values in the record, extract a NULL.
                The value extracted is stored in register P3.
                If the record contains fewer than P2 fields, then extract a NULL. Or, if the P4 argument is a P4_MEM use the value of the P4 argument as the result.
                If the OPFLAG_LENGTHARG and OPFLAG_TYPEOFARG bits are set on P5 then the result is guaranteed to only be used as the argument of a length() or typeof() function, respectively. The loading of large blobs can be skipped for length() and all content loading can be skipped for typeof().
                */
                // TODO: instead of pc need to extract p2-th element from table p1 (or null)
                mem[ins.p3] = main.key(rowid);
                // console.log("Column unimplemented");
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
                // rowid should start at 1.
                rowid = 1;
                // console.log("Rewind partially implemented");
            } else if (ins.opcode == uint256(Opcode.Last)) {
                // TODO: set rowid to the last element in the table
                //rowid = -1;
                rowid = main.size;
            } else if (ins.opcode == uint256(Opcode.Noop)) {
                // no-op
            } else if (ins.opcode == uint256(Opcode.Explain)) {
                // no-op (?)
                // console.log("Explain (ignored)");
            } else {
                console.log("%s: UNKNOWN OPCODE", uint256(ins.opcode), ins.p1);
                revert("unimplemented opcode");
            }
        }
    }
}


