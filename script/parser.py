import sys
import sqlite3

op2code = \
{
  'Savepoint': (0, False),
  'AutoCommit': (1, False),
  'Transaction': (2, True),
  'SorterNext': (3, False), # jump
  'Prev': (4, True), # jump
  'Next': (5, True), # jump
  'Checkpoint': (6, False),
  'JournalMode': (7, False),
  'Vacuum': (8, False),
  'VFilter': (9, False), # jump, synopsis: iplan=r[P3] zplan='P4'
  'VUpdate': (10, False), # synopsis: data=r[P3@P2]
  'Goto': (11, True), # jump
  'Gosub': (12, False), # jump
  'InitCoroutine': (13, False), # jump
  'Yield': (14, False), # jump
  'MustBeInt': (15, True), # jump
  'Jump': (16, False), # jump
  'Once': (17, False), # jump
  'If': (18, True), # jump
  'Not': (19, False), # same as TK_NOT, synopsis: r[P2]= !r[P1]
  'IfNot': (20, False), # jump
  'IfNullRow': (21, False), # jump, synopsis: if P1.nullRow then r[P3]=NULL, goto P2,
  'SeekLT': (22, False), # jump, synopsis: key=r[P3@P4]
  'SeekLE': (23, False), # jump, synopsis: key=r[P3@P4]
  'SeekGE': (24, False), # jump, synopsis: key=r[P3@P4]
  'SeekGT': (25, False), # jump, synopsis: key=r[P3@P4]
  'IfNotOpen': (26, False), # jump, synopsis: if( !csr[P1] ) goto P2
  'IfNoHope': (27, False), # jump, synopsis: key=r[P3@P4]
  'NoConflict': (28, False), # jump, synopsis: key=r[P3@P4]
  'NotFound': (29, False), # jump, synopsis: key=r[P3@P4]
  'Found': (30, False), # jump, synopsis: key=r[P3@P4]
  'SeekRowid': (31, False), # jump, synopsis: intkey=r[P3]
  'NotExists': (32, True), # jump, synopsis: intkey=r[P3]
  'Last': (33, True), # jump
  'IfSmaller': (34, False), # jump
  'SorterSort': (35, False), # jump
  'Sort': (36, False), # jump
  'Rewind': (37, True), # jump
  'IdxLE': (38, False), # jump, synopsis: key=r[P3@P4]
  'IdxGT': (39, False), # jump, synopsis: key=r[P3@P4]
  'IdxLT': (40, False), # jump, synopsis: key=r[P3@P4]
  'IdxGE': (41, False), # jump, synopsis: key=r[P3@P4]
  'RowSetRead': (42, False), # jump, synopsis: r[P3]=rowset(P1)
  'Or': (43, False), # same as TK_OR, synopsis: r[P3]=(r[P1] || r[P2])
  'And': (44, False), # same as TK_AND, synopsis: r[P3]=(r[P1] && r[P2])
  'RowSetTest': (45, False), # jump, synopsis: if r[P3] in rowset(P1) goto P2,
  'Program': (46, False), # jump
  'FkIfZero': (47, False), # jump, synopsis: if fkctr[P1]==0, goto P2, #
  'IfPos': (48, False), # jump, synopsis: if r[P1]>0, then r[P1]-=P3, goto P2,
  'IfNotZero': (49, False), # jump, synopsis: if r[P1]!=0, then r[P1]--, goto P2,
  'IsNull': (50, False), # jump, same as TK_ISNULL, synopsis: if r[P1]==NULL goto P2,
  'NotNull': (51, True), # jump, same as TK_NOTNULL, synopsis: if r[P1]!=NULL goto P2,
  'Ne': (52, True), # jump, same as TK_NE, synopsis: IF r[P3]!=r[P1]
  'Eq': (53, True), # jump, same as TK_EQ, synopsis: IF r[P3]==r[P1]
  'Gt': (54, True), # jump, same as TK_GT, synopsis: IF r[P3]>r[P1]
  'Le': (55, True), # jump, same as TK_LE, synopsis: IF r[P3]<=r[P1]
  'Lt': (56, True), # jump, same as TK_LT, synopsis: IF r[P3]<r[P1]
  'Ge': (57, True), # jump, same as TK_GE, synopsis: IF r[P3]>=r[P1]
  'ElseNotEq': (58, False), # jump, same as TK_ESCAPE
  'DecrJumpZero': (59, False), # jump, synopsis: if (--r[P1])==0, goto P2, #
  'IncrVacuum': (60, False), # jump
  'VNext': (61, False), # jump
  'Init': (62, True), # jump, synopsis: Start at P2, #
  'PureFunc': (63, False), # synopsis: r[P3]=func(r[P2@NP])
  'Function': (64, False), # synopsis: r[P3]=func(r[P2@NP])
  'Return': (65, False),
  'EndCoroutine': (66, False),
  'HaltIfNull': (67, False), # synopsis: if r[P3]=null halt
  'Halt': (68, True),
  'Integer': (69, True), # synopsis: r[P2]=P1, #
  'Int64': (70, False), # synopsis: r[P2]=P4, #
  'String': (71, False), # synopsis: r[P2]='P4' (len=P1)
  'Null': (72, True), # synopsis: r[P2..P3]=NULL
  'SoftNull': (73, True), # synopsis: r[P1]=NULL
  'Blob': (74, True), # synopsis: r[P2]=P4, (len=P1)
  'Variable': (75, False), # synopsis: r[P2]=parameter(P1,P4)
  'Move': (76, False), # synopsis: r[P2@P3]=r[P1@P3]
  'Copy': (77, False), # synopsis: r[P2@P3+1]=r[P1@P3+1]
  'SCopy': (78, False), # synopsis: r[P2]=r[P1]
  'IntCopy': (79, False), # synopsis: r[P2]=r[P1]
  'ResultRow': (80, True), # synopsis: output=r[P1@P2]
  'CollSeq': (81, False),
  'AddImm': (82, False), # synopsis: r[P1]=r[P1]+P2, #
  'RealAffinity': (83, False),
  'Cast': (84, False), # synopsis: affinity(r[P1])
  'Permutation': (85, False),
  'Compare': (86, False), # synopsis: r[P1@P3] <-> r[P2@P3]
  'IsTrue': (87, False), # synopsis: r[P2]': coalesce(r[P1]==TRUE,P3) ^ P4,
  'Offset': (88, False), # synopsis: r[P3]': sqlite_offset(P1)
  'Column': (89, True), # synopsis: r[P3]=PX
  'Affinity': (90, False), # synopsis: affinity(r[P1@P2])
  'MakeRecord': (91, True), # synopsis: r[P3]=mkrec(r[P1@P2])
  'Count': (92, False), # synopsis: r[P2]=count()
  'ReadCookie': (93, True),
  'SetCookie': (94, True),
  'ReopenIdx': (95, False), # synopsis: root=P2, iDb=P3, #
  'OpenRead': (96, True), # synopsis: root=P2, iDb=P3, #
  'OpenWrite': (97, True), # synopsis: root=P2, iDb=P3, #
  'OpenDup': (98, False),
  'OpenAutoindex': (99, False), # synopsis: nColumn=P2, #
  'OpenEphemeral': (100, False), # synopsis: nColumn=P2, #
  'BitAnd': (101, False), # same as TK_BITAND, synopsis: r[P3]=r[P1]&r[P2]
  'BitOr': (102, False), # same as TK_BITOR, synopsis: r[P3]=r[P1]|r[P2]
  'ShiftLeft': (103, False), # same as TK_LSHIFT, synopsis: r[P3]=r[P2]<<r[P1]
  'ShiftRight': (104, False), # same as TK_RSHIFT, synopsis: r[P3]=r[P2]>>r[P1]
  'Add': (105, False), # same as TK_PLUS, synopsis: r[P3]=r[P1]+r[P2]
  'Subtract': (106, False), # same as TK_MINUS, synopsis: r[P3]=r[P2]-r[P1]
  'Multiply': (107, False), # same as TK_STAR, synopsis: r[P3]=r[P1]*r[P2]
  'Divide': (108, False), # same as TK_SLASH, synopsis: r[P3]=r[P2]/r[P1]
  'Remainder': (109, False), # same as TK_REM, synopsis: r[P3]=r[P2]%r[P1]
  'Concat': (110, False), # same as TK_CONCAT, synopsis: r[P3]=r[P2]+r[P1]
  'SorterOpen': (111, False),
  'BitNot': (112, False), # same as TK_BITNOT, synopsis: r[P2]= ~r[P1]
  'SequenceTest': (113, False), # synopsis: if( cursor[P1].ctr++ ) pc': P2, #
  'OpenPseudo': (114, False), # synopsis: P3, columns in r[P2]
  'String8': (115, False), # same as TK_STRING, synopsis: r[P2]='P4'
  'Close': (116, False),
  'ColumnsUsed': (117, False),
  'SeekHit': (118, False), # synopsis: seekHit=P2, #
  'Sequence': (119, False), # synopsis: r[P2]=cursor[P1].ctr++
  'NewRowid': (120, True), # synopsis: r[P2]=rowid
  'Insert': (121, True), # synopsis: intkey=r[P3] data=r[P2]
  'Delete': (122, False),
  'ResetCount': (123, False),
  'SorterCompare': (124, False), # synopsis: if key(P1)!=trim(r[P3],P4) goto P2,
  'SorterData': (125, False), # synopsis: r[P2]=data
  'RowData': (126, False), # synopsis: r[P2]=data
  'Rowid': (127, True), # synopsis: r[P2]=rowid
  'NullRow': (128, False),
  'SeekEnd': (129, False),
  'IdxInsert': (130, False), # synopsis: key=r[P2]
  'SorterInsert': (131, False), # synopsis: key=r[P2]
  'IdxDelete': (132, False), # synopsis: key=r[P2@P3]
  'DeferredSeek': (133, False), # synopsis: Move P3, to P1.rowid if needed
  'IdxRowid': (134, False), # synopsis: r[P2]=rowid
  'FinishSeek': (135, False),
  'Destroy': (136, False),
  'Clear': (137, False),
  'ResetSorter': (138, False),
  'CreateBtree': (139, True), # synopsis: r[P2]=root iDb=P1, flags=P3, #
  'SqlExec': (140, False),
  'ParseSchema': (141, True),
  'LoadAnalysis': (142, False),
  'DropTable': (143, False),
  'DropIndex': (144, False),
  'DropTrigger': (145, False),
  'IntegrityCk': (146, False),
  'RowSetAdd': (147, False), # synopsis: rowset(P1)=r[P2]
  'Param': (148, False),
  'FkCounter': (149, False), # synopsis: fkctr[P1]+=P2, #
  'Real': (150, False), # same as TK_FLOAT, synopsis: r[P2]=P4, #
  'MemMax': (151, False), # synopsis: r[P1]=max(r[P1],r[P2])
  'OffsetLimit': (152, False), # synopsis: if r[P1]>0, then r[P2]=r[P1]+max(0,r[P3]) else r[P2]=(-1)
  'AggInverse': (153, False), # synopsis: accum=r[P3] inverse(r[P2@P5])
  'AggStep': (154, False), # synopsis: accum=r[P3] step(r[P2@P5])
  'AggStep1': (155, False), # synopsis: accum=r[P3] step(r[P2@P5])
  'AggValue': (156, False), # synopsis: r[P3]=value N=P2, #
  'AggFinal': (157, False), # synopsis: accum=r[P1] N=P2, #
  'Expire': (158, False),
  'CursorLock': (159, False),
  'CursorUnlock': (160, False),
  'TableLock': (161, False), # synopsis: iDb=P1, root=P2, write=P3, #
  'VBegin': (162, False),
  'VCreate': (163, False),
  'VDestroy': (164, False),
  'VOpen': (165, False),
  'VColumn': (166, False), # synopsis: r[P3]=vcolumn(P2)
  'VRename': (167, False),
  'Pagecount': (168, False),
  'MaxPgcnt': (169, False),
  'Trace': (170, False),
  'CursorHint': (171, False),
  'ReleaseReg': (172, False), # synopsis: release r[P1@P2] mask P3, #
  'Noop': (173, True),
  'Explain': (174, True),
  'Abortable': 175
}

code2op = { value: key for (key, value) in op2code.items() }

#query = 'select * from im where id < 12345.6 and first like "%j%"'
#query = 'insert into im(is_del, time) values (0, 123), (1, 555)'
#query = 'CREATE TABLE test2 (id INTEGER PRIMARY KEY, value INTEGER)'
#query = 'select * from test'
#query = 'insert into test2(notid, value) values(7, 555)'
#query = 'insert into test3(onlyvalue) values(555)'
#query = 'CREATE TABLE twokeys2 (id INTEGER PRIMARY KEY, email CHAR(32) UNIQUE, name CHAR(32))'
#query = 'insert into three(id, value, meta) values(777, 777, 777)'
#query = 'select * from three'
#query = 'insert into four(id, imd, value, meta) values(777, 222, 555, 444)'
#query = 'select * from four'
query = 'delete from four where id = 111'

OUTPUT_BYTECODE = True

def sanitize(items):
  for i in range(len(items)):
    if items[i] is None:
      items[i] = 0
    elif type(items[i]) == str:
      if len(items[i]) > 32:
        print('WARNING: trimming string too long: "%s"' % items[i], file=sys.stderr)
      items[i] = int(bytes(items[i][:32], 'utf8').hex(), 16)
  
  return items

db = sqlite3.connect('./test.sqlite')
cur = db.cursor()
res = cur.execute('explain ' + query)
rows = res.fetchall()
output = ''
for row in rows:
  pc, op_name, p1, p2, p3, p4, p5, comment = row
  params = sanitize(list(row[2:7]))
  opcode, is_supported = op2code[op_name]

  if OUTPUT_BYTECODE:
    if not is_supported:
      print('OPCODE "%s" IS NOT SUPPORTED!' % op_name, file=sys.stderr)
      #exit(0)
    
    output += '%064x%064x%064x%064x%064x%064x' % (opcode, *params)

  print('[%02x] %02x %s (%x, %x, %x, %x, %x)' % (pc, opcode, op_name, *params), file=sys.stderr)

if output:
  print('\t\t\tconsole.log(">>> %s");\n\t\t\tsqlite.execute(hex"%s");' % (query, output))
