```c
/*
** The makefile scans the vdbe.c source file and creates the "opcodes.h"
** header file that defines a number for each opcode used by the VDBE.
*/
/************** Include opcodes.h in the middle of vdbe.h ********************/
/************** Begin file opcodes.h *****************************************/
/* Automatically generated.  Do not edit */
/* See the tool/mkopcodeh.tcl script for details */
#define OP_Savepoint       0
#define OP_AutoCommit      1
#define OP_Transaction     2
#define OP_SorterNext      3 /* jump                                       */
#define OP_Prev            4 /* jump                                       */
#define OP_Next            5 /* jump                                       */
#define OP_Checkpoint      6
#define OP_JournalMode     7
#define OP_Vacuum          8
#define OP_VFilter         9 /* jump, synopsis: iplan=r[P3] zplan='P4'     */
#define OP_VUpdate        10 /* synopsis: data=r[P3@P2]                    */
#define OP_Goto           11 /* jump                                       */
#define OP_Gosub          12 /* jump                                       */
#define OP_InitCoroutine  13 /* jump                                       */
#define OP_Yield          14 /* jump                                       */
#define OP_MustBeInt      15 /* jump                                       */
#define OP_Jump           16 /* jump                                       */
#define OP_Once           17 /* jump                                       */
#define OP_If             18 /* jump                                       */
#define OP_Not            19 /* same as TK_NOT, synopsis: r[P2]= !r[P1]    */
#define OP_IfNot          20 /* jump                                       */
#define OP_IfNullRow      21 /* jump, synopsis: if P1.nullRow then r[P3]=NULL, goto P2 */
#define OP_SeekLT         22 /* jump, synopsis: key=r[P3@P4]               */
#define OP_SeekLE         23 /* jump, synopsis: key=r[P3@P4]               */
#define OP_SeekGE         24 /* jump, synopsis: key=r[P3@P4]               */
#define OP_SeekGT         25 /* jump, synopsis: key=r[P3@P4]               */
#define OP_IfNotOpen      26 /* jump, synopsis: if( !csr[P1] ) goto P2     */
#define OP_IfNoHope       27 /* jump, synopsis: key=r[P3@P4]               */
#define OP_NoConflict     28 /* jump, synopsis: key=r[P3@P4]               */
#define OP_NotFound       29 /* jump, synopsis: key=r[P3@P4]               */
#define OP_Found          30 /* jump, synopsis: key=r[P3@P4]               */
#define OP_SeekRowid      31 /* jump, synopsis: intkey=r[P3]               */
#define OP_NotExists      32 /* jump, synopsis: intkey=r[P3]               */
#define OP_Last           33 /* jump                                       */
#define OP_IfSmaller      34 /* jump                                       */
#define OP_SorterSort     35 /* jump                                       */
#define OP_Sort           36 /* jump                                       */
#define OP_Rewind         37 /* jump                                       */
#define OP_IdxLE          38 /* jump, synopsis: key=r[P3@P4]               */
#define OP_IdxGT          39 /* jump, synopsis: key=r[P3@P4]               */
#define OP_IdxLT          40 /* jump, synopsis: key=r[P3@P4]               */
#define OP_IdxGE          41 /* jump, synopsis: key=r[P3@P4]               */
#define OP_RowSetRead     42 /* jump, synopsis: r[P3]=rowset(P1)           */
#define OP_Or             43 /* same as TK_OR, synopsis: r[P3]=(r[P1] || r[P2]) */
#define OP_And            44 /* same as TK_AND, synopsis: r[P3]=(r[P1] && r[P2]) */
#define OP_RowSetTest     45 /* jump, synopsis: if r[P3] in rowset(P1) goto P2 */
#define OP_Program        46 /* jump                                       */
#define OP_FkIfZero       47 /* jump, synopsis: if fkctr[P1]==0 goto P2    */
#define OP_IfPos          48 /* jump, synopsis: if r[P1]>0 then r[P1]-=P3, goto P2 */
#define OP_IfNotZero      49 /* jump, synopsis: if r[P1]!=0 then r[P1]--, goto P2 */
#define OP_IsNull         50 /* jump, same as TK_ISNULL, synopsis: if r[P1]==NULL goto P2 */
#define OP_NotNull        51 /* jump, same as TK_NOTNULL, synopsis: if r[P1]!=NULL goto P2 */
#define OP_Ne             52 /* jump, same as TK_NE, synopsis: IF r[P3]!=r[P1] */
#define OP_Eq             53 /* jump, same as TK_EQ, synopsis: IF r[P3]==r[P1] */
#define OP_Gt             54 /* jump, same as TK_GT, synopsis: IF r[P3]>r[P1] */
#define OP_Le             55 /* jump, same as TK_LE, synopsis: IF r[P3]<=r[P1] */
#define OP_Lt             56 /* jump, same as TK_LT, synopsis: IF r[P3]<r[P1] */
#define OP_Ge             57 /* jump, same as TK_GE, synopsis: IF r[P3]>=r[P1] */
#define OP_ElseNotEq      58 /* jump, same as TK_ESCAPE                    */
#define OP_DecrJumpZero   59 /* jump, synopsis: if (--r[P1])==0 goto P2    */
#define OP_IncrVacuum     60 /* jump                                       */
#define OP_VNext          61 /* jump                                       */
#define OP_Init           62 /* jump, synopsis: Start at P2                */
#define OP_PureFunc       63 /* synopsis: r[P3]=func(r[P2@NP])             */
#define OP_Function       64 /* synopsis: r[P3]=func(r[P2@NP])             */
#define OP_Return         65
#define OP_EndCoroutine   66
#define OP_HaltIfNull     67 /* synopsis: if r[P3]=null halt               */
#define OP_Halt           68
#define OP_Integer        69 /* synopsis: r[P2]=P1                         */
#define OP_Int64          70 /* synopsis: r[P2]=P4                         */
#define OP_String         71 /* synopsis: r[P2]='P4' (len=P1)              */
#define OP_Null           72 /* synopsis: r[P2..P3]=NULL                   */
#define OP_SoftNull       73 /* synopsis: r[P1]=NULL                       */
#define OP_Blob           74 /* synopsis: r[P2]=P4 (len=P1)                */
#define OP_Variable       75 /* synopsis: r[P2]=parameter(P1,P4)           */
#define OP_Move           76 /* synopsis: r[P2@P3]=r[P1@P3]                */
#define OP_Copy           77 /* synopsis: r[P2@P3+1]=r[P1@P3+1]            */
#define OP_SCopy          78 /* synopsis: r[P2]=r[P1]                      */
#define OP_IntCopy        79 /* synopsis: r[P2]=r[P1]                      */
#define OP_ResultRow      80 /* synopsis: output=r[P1@P2]                  */
#define OP_CollSeq        81
#define OP_AddImm         82 /* synopsis: r[P1]=r[P1]+P2                   */
#define OP_RealAffinity   83
#define OP_Cast           84 /* synopsis: affinity(r[P1])                  */
#define OP_Permutation    85
#define OP_Compare        86 /* synopsis: r[P1@P3] <-> r[P2@P3]            */
#define OP_IsTrue         87 /* synopsis: r[P2] = coalesce(r[P1]==TRUE,P3) ^ P4 */
#define OP_Offset         88 /* synopsis: r[P3] = sqlite_offset(P1)        */
#define OP_Column         89 /* synopsis: r[P3]=PX                         */
#define OP_Affinity       90 /* synopsis: affinity(r[P1@P2])               */
#define OP_MakeRecord     91 /* synopsis: r[P3]=mkrec(r[P1@P2])            */
#define OP_Count          92 /* synopsis: r[P2]=count()                    */
#define OP_ReadCookie     93
#define OP_SetCookie      94
#define OP_ReopenIdx      95 /* synopsis: root=P2 iDb=P3                   */
#define OP_OpenRead       96 /* synopsis: root=P2 iDb=P3                   */
#define OP_OpenWrite      97 /* synopsis: root=P2 iDb=P3                   */
#define OP_OpenDup        98
#define OP_OpenAutoindex  99 /* synopsis: nColumn=P2                       */
#define OP_OpenEphemeral 100 /* synopsis: nColumn=P2                       */
#define OP_BitAnd        101 /* same as TK_BITAND, synopsis: r[P3]=r[P1]&r[P2] */
#define OP_BitOr         102 /* same as TK_BITOR, synopsis: r[P3]=r[P1]|r[P2] */
#define OP_ShiftLeft     103 /* same as TK_LSHIFT, synopsis: r[P3]=r[P2]<<r[P1] */
#define OP_ShiftRight    104 /* same as TK_RSHIFT, synopsis: r[P3]=r[P2]>>r[P1] */
#define OP_Add           105 /* same as TK_PLUS, synopsis: r[P3]=r[P1]+r[P2] */
#define OP_Subtract      106 /* same as TK_MINUS, synopsis: r[P3]=r[P2]-r[P1] */
#define OP_Multiply      107 /* same as TK_STAR, synopsis: r[P3]=r[P1]*r[P2] */
#define OP_Divide        108 /* same as TK_SLASH, synopsis: r[P3]=r[P2]/r[P1] */
#define OP_Remainder     109 /* same as TK_REM, synopsis: r[P3]=r[P2]%r[P1] */
#define OP_Concat        110 /* same as TK_CONCAT, synopsis: r[P3]=r[P2]+r[P1] */
#define OP_SorterOpen    111
#define OP_BitNot        112 /* same as TK_BITNOT, synopsis: r[P2]= ~r[P1] */
#define OP_SequenceTest  113 /* synopsis: if( cursor[P1].ctr++ ) pc = P2   */
#define OP_OpenPseudo    114 /* synopsis: P3 columns in r[P2]              */
#define OP_String8       115 /* same as TK_STRING, synopsis: r[P2]='P4'    */
#define OP_Close         116
#define OP_ColumnsUsed   117
#define OP_SeekHit       118 /* synopsis: seekHit=P2                       */
#define OP_Sequence      119 /* synopsis: r[P2]=cursor[P1].ctr++           */
#define OP_NewRowid      120 /* synopsis: r[P2]=rowid                      */
#define OP_Insert        121 /* synopsis: intkey=r[P3] data=r[P2]          */
#define OP_Delete        122
#define OP_ResetCount    123
#define OP_SorterCompare 124 /* synopsis: if key(P1)!=trim(r[P3],P4) goto P2 */
#define OP_SorterData    125 /* synopsis: r[P2]=data                       */
#define OP_RowData       126 /* synopsis: r[P2]=data                       */
#define OP_Rowid         127 /* synopsis: r[P2]=rowid                      */
#define OP_NullRow       128
#define OP_SeekEnd       129
#define OP_IdxInsert     130 /* synopsis: key=r[P2]                        */
#define OP_SorterInsert  131 /* synopsis: key=r[P2]                        */
#define OP_IdxDelete     132 /* synopsis: key=r[P2@P3]                     */
#define OP_DeferredSeek  133 /* synopsis: Move P3 to P1.rowid if needed    */
#define OP_IdxRowid      134 /* synopsis: r[P2]=rowid                      */
#define OP_FinishSeek    135
#define OP_Destroy       136
#define OP_Clear         137
#define OP_ResetSorter   138
#define OP_CreateBtree   139 /* synopsis: r[P2]=root iDb=P1 flags=P3       */
#define OP_SqlExec       140
#define OP_ParseSchema   141
#define OP_LoadAnalysis  142
#define OP_DropTable     143
#define OP_DropIndex     144
#define OP_DropTrigger   145
#define OP_IntegrityCk   146
#define OP_RowSetAdd     147 /* synopsis: rowset(P1)=r[P2]                 */
#define OP_Param         148
#define OP_FkCounter     149 /* synopsis: fkctr[P1]+=P2                    */
#define OP_Real          150 /* same as TK_FLOAT, synopsis: r[P2]=P4       */
#define OP_MemMax        151 /* synopsis: r[P1]=max(r[P1],r[P2])           */
#define OP_OffsetLimit   152 /* synopsis: if r[P1]>0 then r[P2]=r[P1]+max(0,r[P3]) else r[P2]=(-1) */
#define OP_AggInverse    153 /* synopsis: accum=r[P3] inverse(r[P2@P5])    */
#define OP_AggStep       154 /* synopsis: accum=r[P3] step(r[P2@P5])       */
#define OP_AggStep1      155 /* synopsis: accum=r[P3] step(r[P2@P5])       */
#define OP_AggValue      156 /* synopsis: r[P3]=value N=P2                 */
#define OP_AggFinal      157 /* synopsis: accum=r[P1] N=P2                 */
#define OP_Expire        158
#define OP_CursorLock    159
#define OP_CursorUnlock  160
#define OP_TableLock     161 /* synopsis: iDb=P1 root=P2 write=P3          */
#define OP_VBegin        162
#define OP_VCreate       163
#define OP_VDestroy      164
#define OP_VOpen         165
#define OP_VColumn       166 /* synopsis: r[P3]=vcolumn(P2)                */
#define OP_VRename       167
#define OP_Pagecount     168
#define OP_MaxPgcnt      169
#define OP_Trace         170
#define OP_CursorHint    171
#define OP_ReleaseReg    172 /* synopsis: release r[P1@P2] mask P3         */
#define OP_Noop          173
#define OP_Explain       174
#define OP_Abortable     175
```