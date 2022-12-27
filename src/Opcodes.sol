// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

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
