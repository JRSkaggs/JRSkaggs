000100231214**free
000200231214Ctl-Opt COPYRIGHT('©EMMI Physician Service, Inc. - 2023')
000300231214DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')
000400231214OPTION(*SRCSTMT:*NODEBUGIO:*NOUNREF)
000500231214DECEDIT('0.') ExtBinInt(*YES) OPTIMIZE(*BASIC);
000600231214//*************************************************************************************************/
000700231214//                                   EMMI Physician Service, Inc.                                  /
000800231214//                                               ©2023                                             /
000900231214//*************************************************************************************************/
001000231214// CREATE DATE: 12/14/2023                                                                         /
001100231214// PROGRAMMER.: Johnny Skaggs                                                                      /
001200231214// PROGRAM....: MCM0101R                                                                           /
001300231214// SYNOPSIS...: Account Type Data Maintenance                                                      /
001400231214// DESCRIPTION: Display a screen that contains the financial class account type code data for the  /
001500231214//              code that was passed to the program. The user must authority to change or add the  /
001600231214//              account type code data; otherwise, the data can on be displayed.  Any messages     /
001700231214//              produced by this program will be passed back to the calling program to handle.     /
001800231214//              Any modifications made the the account type code data will be recorded in the      /
001900231214//              customer Miscellaneous Codes Maintenance Audit File (Mxx.AUDM). A check is done to /
002000231214//              make sure the data was changed before updating the data, so that no unneccesary    /
002100231214//              records are written to the audit file. If no modifications were made to the data,  /
002200231214//              then a message is displayed and nothing is done.                                   /
002300231214//                                                                                                 /
002400231214//++++++++++++++++++++++++++++++++++++++  P R A M A T E R S  ++++++++++++++++++++++++++++++++++++++/
002500231214//      NAME      I/O                                  DESCRIPTION                                 /
002600231214// -------------- --- ---------------------------------------------------------------------------- /
002700240418//  CustCode      In  ·Group code used to identify the customer                                    /
002800240418//  AcctType      In  ·Financial class account type                                                /
002900240418//  AddChgDsp     In  ·Add, change or display the account type code data                           /
003000240418//  RetFncKey     Out ·Function key pressed in calling program that needs to be passed back to     /
003100240418//                     the current program: F3=Exit out of all programs and back to menu           /
003200240418//  RetMsgTyp     Out ·Program message type: ERR=Error, INF=Informational, WRN=Warning             /
003300240418//  RetPgmMsg     Out ·Message returned by the program called                                      /
003400231214//                                                                                                 /
003500231214//++++++++++++++++++++++++++++++++++++++++++  F I L E S  ++++++++++++++++++++++++++++++++++++++++++/
003600231214//    NAME     OVERRIDDEN                                DESCRIPTION                               /
003700231214// ----------  ----------  ----------------------------------------------------------------------- /
003800231214// Mxx.ATM     ATM         Account Type (Financial Class) File                                     /
003900231214// Mxx.ATP1    ATP1        Account Type Pay Code Changes Logical                                   /
004000231214// M.MSG       MSG         Message File                                                            /
004100231214//                                                                                                 /
004200231214//++++++++++++++++++++++++++++++++  D A T A  S T R U C T U R E S  +++++++++++++++++++++++++++++++++/
004300231214//      NAME      I/O                                  DESCRIPTION                                 /
004400231214// -------------- --- ---------------------------------------------------------------------------- /
004500231214// AuditData      Out Allows the moving of the audit data into the audit file without having to    /
004600231214//                    move each individual field.                                                  /
004700231214// AudtDta1       I/O Used to store the file data that corresponds to the screen data. This allows /
004800231214//                    the comparison of the screen data to the file data to see if it changed.     /
004900231214// AudtDta2       I/O Used to store the screen data that corresponds to the file data.             /
005000231214// DataIn         In  Allows the data to be retrieved from the input file by the SQL processing.   /
005100231214// MyLDA          In  Holds the data that is read in from the Local Data Area (LDA).               /
005200231214// WSInd          In  Since INDARA is used in the display file, mapping of the indicators must be  /
005300231214//                    done  in the program.  The indicators for the display are now accessed using /
005400231214//                    the  data structure. Turning on an indicator in the data structure will not  /
005500231214//                    turn on the corresponding *INxx indicator.                                   /
005600231214//                                                                                                 /
005700231214//+++++++++++++++++++++++++++++++++++++  C O N S T A N T S   ++++++++++++++++++++++++++++++++++++++/
005800231214//      NAME                                          DESCRIPTION                                  /
005900231214// --------------   ------------------------------------------------------------------------------ /
006000231214// ADD            - Add a record to the miscellaneous codes maintenance file                       /
006100231214// CHANGE         - Change a record in the miscellaneous codes maintenance file                    /
006200231214// DELETE         - Delete a record fromthe miscellaneous codes maintenance file                   /
006300231214// DELIQUENT      - The message type used for looking up deliquent statements in the Message file  /
006400231214// DISPLAY        - Display the data for the account type code                                     /
006500231214// EXIT           - Show that the function key F3 was pressed to exit the calling program          /
006600231214// ERROR          - Message passed back from program called is an error message                    /
006700231214// NO             - Readability replacement for N                                                  /
006800231214// RECID          - Record identification                                                          /
006900231214// STATEMENT      - The message type used for looking up regular statements in the Message file    /
007000231214// SYSKEY         - System file key used to look up provider account information                   /
007100231214// YES            - Readability replacement for Y                                                  /
007200231214//                                                                                                 /
007300231214//++++++++++++++++++++++++++++++++++++++  V A R I A B L E S  ++++++++++++++++++++++++++++++++++++++/
007400231214//      NAME                                          DESCRIPTION                                  /
007500231214// --------------   ------------------------------------------------------------------------------ /
007600231214// AccTypF        - Override Mxx.ATM to this account type file name                                /
007700231214// AcTyPyCdF      - Override Mxx.ATP1 to thisAccount type pay code changes file format name        /
007800231214// CompanyName    - Name of the company who's data is being presented                              /
007900231214// DataAdded      - Data that was entered into the screen was added to the file                    /
008000231214//                                                                                                 /
008100231214//++++++++++++++++++++  F U N C T I O N  K E Y S  A N D  I N D I C A T O R S  +++++++++++++++++++++/
008200231214//     NAME                                         DESCRIPTION                                    /
008300231214// ----------   ---------------------------------------------------------------------------------- /
008400231214// F1_Help    - Context sensitive help                                                             /
008500231214// F3_Exit    - Exit program                                                                       /
008600231214// F12_Cancel - Cancel current action and return to previous screen                                /
008700231214// F18_PyCdAT - Pay code account type maintenance                                                  /
008800231214// ProtFld_28 - Protect the field from changes                                                     /
008900231214// AddCode_36 - Add a new accounting type code                                                     /
009000231214// AccType_40 - Accounting type missing when adding data                                           /
009100231214// InactDt_41 - Inactive date is invalid                                                           /
009200231214// TypDesc_42 - Account type file description cannot be blanks                                     /
009300231214// OBRAIRC_43 - OBRA/IRCA is invalid (must be Y, N or blank)                                       /
009400231214// AbrDesc_44 - Short account type description cannot be blank                                     /
009500231214// AcpAsgn_45 - Accept assignment cannot be blank                                                  /
009600231214// Acronym_46 - Acronym cannot be blank                                                            /
009700231214// ChrgInt_47 - Charge interest invalid (must be Y or blank)                                       /
009800231214// EdSvrCd_48 - Edit severity code invalid (must be between 00 and 99)                             /
009900231214// PhysReq_49 - Ref physician req invalid (must be Y, N or blank)                                  /
010000231214// StmtTyp_50 - Type of statement invalid (must be N or S)                                         /
010100231214// ClmFreq_51 - Claims frequency is invalid (must be D, M, N, or W)                                /
010200231214// InsType_52 - Insurance type invalid (must be between 0 and 8)                                   /
010300231214// PprOnly_53 - Produce paper form only invalid (must be B, N or Y)                                /
010400231214// FormTyp_54 - Form used for paper report cannot be blank                                         /
010500231214// SumAcTy_55 - Currently not checked                                                              /
010600231214// IntStDy_56 - Initial statement after xxx days invalid                                           /
010700231214// IntStMC_57 - Initial statement message code invalid                                             /
010800231214// DelLtDy_58 - Deliquent letter after xxx days invalid                                            /
010900231214// DelLtSt_59 - Include stmt with deliquent ltr invalid (must be N or Y)                           /
011000231214// DelLtMC_60 - Deliquent statement message code invalid                                           /
011100231214// StMCCur_61 - Current statement message code invalid                                             /
011200231214// StMC030_62 - 30 day statement message code invalid                                              /
011300231214// StMC060_63 - 60 day statement message code invalid                                              /
011400231214// StMC090_64 - 90 day statement message code invalid                                              /
011500231214// StMC120_65 - 120 day statement message code invalid                                             /
011600231214// FinNtDy_66 - Final notice after xxx days invalid                                                /
011700231214// FinNtSt_67 - Include stmt with final notice invalid (must be N or Y)                            /
011800231214// FinNtMC_68 - Final notice statement message code invalid                                        /
011900231214// ColLtDy_69 - Collection list after xxx days invalid                                             /
012000231214// ColLtSt_70 - Include stmt with collection list notice (must be N or Y)                          /
012100231214// DataErr_89 - Data error found                                                                   /
012200240416// DataChg_91 - Data was changed on the display                                                    /
012300231214//                                                                                                 /
012400231214//+++++++++++++++++++++++++++++++++  M O D I F I C A T I O N S  +++++++++++++++++++++++++++++++++++/
012500231214// DATE..: MM/DD/CCYY   PROGRAMMER: First and last name                                            /
012600231214// REASON: Project number or ticket number                                                         /
012700231214// MODS..: What changes were made to the program                                                   /
012800231214//*************************************************************************************************/
012900231214
013000231214// Passed parameters................................................................................
013100231214Dcl-PI *n;
013200231214  CustCode  Char( 2) Const;
013300231214  AcctTyCde Char( 2) Const;
013400231214  AddChgDsp Char( 3) Const;
013500231214  RetFncKey Char( 3);
013600231214  RetMsgTyp Char( 3);
013700231214  RetPgmMsg Char(78);
013800231214End-PI;
013900231214
014000231214// Declare, override and open files.................................................................
014100231214Dcl-F ATM  Disk Keyed Qualified Usage(*DELETE:*OUTPUT) ExtDesc('MXX.ATM') ExtFile(AccTypF) UsrOpn;
014200231214Dcl-F ATP1 Disk Keyed Qualified Usage(*DELETE) ExtDesc('MXX.ATP1') ExtFile(AcTyPyCdF) UsrOpn;
014300231214Dcl-F MSG  Disk Keyed Usage(*INPUT) ExtDesc('M.MSG') ExtFile(*ExtDesc);
014400231214Dcl-F DSP  WorkStn Qualified ExtDesc('MCM0101D') ExtFile(*ExtDesc) InDDS(WsInd);
014500231214
014600231214// Data structure templates to deifine record formats...............................................
014700231214Dcl-DS ATM_T  LikeRec(ATM.ATMR      :*All) Template;
014800231214Dcl-DS ATP1_T LikeRec(ATP1.ATPR     :*All) Template;
014900231214Dcl-DS INFO_T LikeRec(DSP.MCM0101   :*All) Template;
015000231214Dcl-DS MSGC_T LikeRec(DSP.MSGCTL    :*All) Template;
015100231214
015200231214// Like data structures used for the reading and writing of data....................................
015300231214Dcl-DS ATM_R  LikeDS(ATM_T );          // Accounting type (financial class) file format
015400231214Dcl-DS ATP1_R LikeDS(ATP1_T);          // Account type pay code changes file format
015500231214Dcl-DS INFO_R LikeDS(INFO_T);          // Accounting type code information
015600231214Dcl-DS MSGC_R LikeDS(MSGC_T);          // Error message screen format
015700231214
015800231214// Define data structure for reading of batch control file using SQL................................
015900231214Dcl-DS DataIn ExtName('MXX.ATM') Qualified End-DS;
016000231214
016100231214// Functions keys and indicators data structure.....................................................
016200231214Dcl-DS WsInd Len(99);
016300231214  FuncKeyInd Char(24) Pos(01);         // Function key indicators...................................
016400231214    F3_Exit    Ind Pos(03);            // End program
016500231214    F12_Cancel Ind Pos(12);            // Cancel
016600231214    F18_PyCdAT Ind Pos(18);            // Call the pay code account type maintenance program
016700231214  ScreenInd  Char(15) Pos(25);         // Screen manipulation indicators............................
016800231214    ProtFld_28 Ind Pos(28);            // Protect the field from being changed
016900231214    AddCode_36 Ind Pos(36);            // Add a new account type code
017000231214    SubFEnd_39 Ind Pos(39);            // Subfile End (SFLEND)
017100231214  FldErrInd  Char(50) Pos(40);         // Error indicators..........................................
017200231214    AccTyCd_40 Ind Pos(40);            // Accounting type missing when adding data
017300231214    InactDt_41 Ind Pos(41);            // Inactive date is invalid
017400231214    TypDesc_42 Ind Pos(42);            // Account type file description cannot be blanks
017500231214    OBRAIRC_43 Ind Pos(43);            // OBRA/IRCA is invalid (must be Y, N or blank)
017600231214    AbrDesc_44 Ind Pos(44);            // Short account type description cannot be blank
017700231214    AcpAsgn_45 Ind Pos(45);            // Accept assignment cannot be blank
017800231214    Acronym_46 Ind Pos(46);            // Acronym cannot be blank
017900231214    ChrgInt_47 Ind Pos(47);            // Charge interest invalid (must be Y or blank)
018000231214    EdSvrCd_48 Ind Pos(48);            // Edit severity code invalid (must be between 00 and 99)
018100231214    PhysReq_49 Ind Pos(49);            // Ref physician req invalid (must be Y, N or blank)
018200231214    StmtTyp_50 Ind Pos(50);            // Type of statement invalid (must be N or S)
018300231214    ClmFreq_51 Ind Pos(51);            // Claims frequency is invalid (must be D, M, N, or W)
018400231214    InsType_52 Ind Pos(52);            // Insurance type invalid (must be between 0 and 8)
018500231214    PprOnly_53 Ind Pos(53);            // Produce paper form only invalid (must be B, N or Y)
018600231214    FormTyp_54 Ind Pos(54);            // Form used for paper report cannot be blank
018700231214    SumAcTy_55 Ind Pos(55);            // Currently not checked
018800231214    IntStDy_56 Ind Pos(56);            // Initial statement after xxx days invalid
018900231214    IntStMC_57 Ind Pos(57);            // Initial statement message code invalid
019000231214    DelLtDy_58 Ind Pos(58);            // Deliquent letter after xxx days invalid
019100231214    DelLtSt_59 Ind Pos(59);            // Include stmt with deliquent ltr invalid (must be N or Y)
019200231214    DelLtMC_60 Ind Pos(60);            // Deliquent statement message code invalid
019300231214    StMCCur_61 Ind Pos(61);            // Current statement message code invalid
019400231214    StMC030_62 Ind Pos(62);            // 30 day statement message code invalid
019500231214    StMC060_63 Ind Pos(63);            // 60 day statement message code invalid
019600231214    StMC090_64 Ind Pos(64);            // 90 day statement message code invalid
019700231214    StMC120_65 Ind Pos(65);            // 120 day statement message code invalid
019800231214    FinNtDy_66 Ind Pos(66);            // Final notice after xxx days invalid
019900231214    FinNtSt_67 Ind Pos(67);            // Include stmt with final notice invalid (must be N or Y)
020000231214    FinNtMC_68 Ind Pos(68);            // Final notice statement message code invalid
020100231214    ColLtDy_69 Ind Pos(69);            // Collection list after xxx days invalid
020200231214    ColLtSt_70 Ind Pos(70);            // Include stmt with collection list notice (must be N or Y)
020300231214    DataErr_89 Ind Pos(89);            // Data error found
020400231214  ProgramInd Char(10) Pos(90);         // Program flow indicators...................................
020500231214    DataChg_91 Ind Pos(91);            // Data was changed on the display
020600231214End-DS WsInd;
020700231214
020800231214// Declare data structure to store audit data.......................................................
020900231214Dcl-DS AuditData1;
021000231214  ATMAType  Like(ATM_R.ATMATYPE);     // Account Type
021100231214  ATMADesc  Like(ATM_R.ATMADESC);     // Type Description
021200231214  ATMAbrDsc Like(ATM_R.ATMABRDSC);     // Abbreviated Desc
021300231214  ATMAcrnym Like(ATM_R.ATMACRNYM);     // Acronym
021400231214  ATMInsFm  Like(ATM_R.ATMINSFM);     // Ins Claim (D,W,,M,N)
021500231214  ATMInsTyp Like(ATM_R.ATMINSTYP);     // Ins Type (0-7)
021600231214  ATMStmTyp Like(ATM_R.ATMSTMTYP);     // Stmnt Type (N,M,S)
021700231214  ATMMsgCr  Like(ATM_R.ATMMSGCR);     // Current Msg
021800231214  ATMMsg30  Like(ATM_R.ATMMSG30);     // 30 Days Msg
021900231214  ATMMsg60  Like(ATM_R.ATMMSG60);     // 60 Days Msg
022000231214  ATMMsg90  Like(ATM_R.ATMMSG90);     // 90 Days Msg
022100231214  ATMMsg120 Like(ATM_R.ATMMSG120);     // 120 Days Msg
022200231214  ATMMsgDl  Like(ATM_R.ATMMSGDL);     // Delinquent Msg
022300231214  ATMDays48 Like(ATM_R.ATMDAYS48);     // Days Old for 48 Hr Not
022400231214  ATMStmt48 Like(ATM_R.ATMSTMT48);     // Print 48 Hr Stmt
022500231214  ATMPaper  Like(ATM_R.ATMPAPER);     // Paper Claim Only
022600231214  ATMAssign Like(ATM_R.ATMASSIGN);     // Accept Assignment-YN
022700231214  ATMOlDl   Like(ATM_R.ATMOLDL );     // Days Old For Del Not
022800231214  ATMStmtDl Like(ATM_R.ATMSTMTDL);     // Print Stmt w/Delinq
022900231214  ATMColOld Like(ATM_R.ATMCOLOLD);     // Days Old for Collect
023000231214  ATMColStm Like(ATM_R.ATMCOLSTM);     // Print Stmt w/Coll
023100231214  ATMInitSt Like(ATM_R.ATMINITST);     // Days Old for 1st Stmt
023200231214  ATMIntMsg Like(ATM_R.ATMINTMSG);     // First Stmt After Msg
023300231214  ATMErrLvl Like(ATM_R.ATMERRLVL);     // Error Level
023400231214  ATMMsgFn  Like(ATM_R.ATMMSGFN);     // Final Notice Msg
023500231214  ATMFrmCd  Like(ATM_R.ATMFRMCD);     // Form Type Code
023600231214  ATMATMInt Like(ATM_R.ATMATMINT);     // Chg Int this Type
023700231214  ATMDatChg Like(ATM_R.ATMDATCHG);     // Last Change Date
023800231214  ATMUsrChg Like(ATM_R.ATMUSRCHG);     // Last Change User
023900231214  ATMOBRIRC Like(ATM_R.ATMOBRIRC);     // OBRA/IRCA? Y/N
024000231214  ATMATRfRq Like(ATM_R.ATMATRFRQ);     // Refer Phy Reqd-Y/N
024100231214  ATMSumTyp Like(ATM_R.ATMSUMTYP);     // Summary Account Type
024200231214  ATMInacDt Like(ATM_R.ATMINACDT);     // Inactive Date
024300231214End-DS AuditData1;
024400231214
024500231214// Data structures used to see if the screen and file data are the same.............................
024600231214Dcl-DS AudtDta1 LikeDS(AuditData1);
024700231214Dcl-DS AudtDta2 LikeDS(AuditData1);
024800231214
024900231214// Declare data structre for reading in the Local Data Area (LDA)...................................
025000231214Dcl-DS MyLDA DtaAra(*LDA) Qualified;
025100231214  Entity   Char(3)  Pos(137);          // Used to open the correct account type file
025200231214  Group    Char(2)  Pos(138);          // Used as key to lookup customer information
025300231214  DeviceID Char(2)  Pos(494);          // Last two characters of device name
025400231214  UserID   Char(10) Pos(496);          // User identification of person running the job
025500231214  Customer Char(50) Pos(951);          // Customer company name
025600231214End-DS;
025700231214
025800231214// Declare constatnts...............................................................................
025900231214Dcl-C ADD       Const('ADD');
026000231214Dcl-C CHANGE    Const('CHG');
026100231214Dcl-C DELETE    Const('DLT');
026200231214Dcl-C DELIQUENT Const('D');
026300231214Dcl-C DISPLAY   Const('DSP');
026400231214Dcl-C EXIT      Const('F03');
026500231214Dcl-C ERROR     Const('ERR');
026600231214Dcl-C NO        Const('N');
026700231214Dcl-C RECID     Const('01');
026800231214Dcl-C STATEMENT Const('S');
026900231214Dcl-C SYSKEY    Const('01');
027000231214Dcl-C YES       Const('Y');
027100231214
027200231214// Declare variables...............................................................................
027300231214Dcl-S AccTypF     Char(10)      Inz;
027400231214Dcl-S AcTyPyCdF   Char(10)      Inz;
027500231214Dcl-S CompanyName Char(50)      Inz;
027600231214Dcl-S DataAdded   Char( 1)      Inz(NO);
027700231214
027800231214// Prototype-Lookup the financial class account type from the Account Type file.....................
027900231214/COPY QCPYSRC,D_ACCTYPLU
028000231214
028100231214// Data structure-Contains any API interface errors.................................................
028200231214/COPY QCPYSRC,D_APIErrDS
028300231214
028400231214// Prototype-Change the account type based on the associated pay code...............................
028500231214/COPY QCPYSRC,D_MCM0102R
028600231214
028700231214// Prototype-Send program message and clear program message queue...................................
028800231214/COPY QCPYSRC,D_PGMMSGS
028900231214
029000231214// Data structure-Contains the program information..................................................
029100231214/COPY QCPYSRC,D_PGMSTSDS
029200231214
029300231214// Constants-Human readable form for the program message identifiers................................
029400231214/COPY QCPYSRC,D_PMSGIDS
029500231214
029600231214// Prototype-Retrieve security data from the User/Program Security file.............................
029700231214/COPY QCPYSRC,D_RTVSECDT
029800231214
029900231214// Prototype-Retrieve system control data from the System Control file..............................
030000231214/COPY QCPYSRC,D_RTVSYSDT
030100231214
030200231214// Prototype-Write the audit data to the correct audit file.........................................
030300231214/COPY QCPYSRC,D_WRTAUDTA
030400231214
030500231214//**************************************************************************************************
030600231214//************************************  M A I N  P R O G R A M  ************************************
030700231214//**************************************************************************************************
030800231214
030900231214// Stuff that only needs to be done once when the program is first run..............................
031000231214ProgramEntry();
031100231214
031200231214// Process the screen until F3 is pressed...........................................................
031300231214DoU F3_Exit or F12_Cancel;
031400231214
031500231214  // Display the account type maintenance screen....................................................
031600231214  INFO_R.CompName = CompanyName;                 // Record format clear requires company name here
031700231214  Write DSP.MSGCTL MSGC_R;
031800231214  ExFmt DSP.MCM0101 INFO_R;
031900231214
032000231214  // Reset the error indicators and clear out any previously displayed messages.....................
032100231214  AddCode_36 = *OFF;                             // Turn off record add indicator
032200231214  FldErrInd  = *OFF;
032300231214  ClrMsgQ( MsgQ_Cur : MsgQNbr_Cur : MsgKey_All :  MsgRmv_All : APIErrC);
032400231214
032500231214  // F3 - Exit out of program.......................................................................
032600231214  Select;
032700231214  When F3_Exit;
032800231214    RetFncKey = EXIT;
032900231214    Leave;
033000231214
033100231214  // F12 - Go back to previous screen...............................................................
033200231214  When F12_Cancel;
033300231214    Leave;
033400231214
033500231214  // F18 - Pay code account type maintenance screen.................................................
033600231214  When F18_PyCdAT;
033700231214    If INFO_R.ATMATYPE <> *BLANKS;               // Account type must be filled in
033800231214      PyCdAcTypMnt(CustCode : INFO_R.ATMATYPE : AddChgDsp : PCATM.RetFncKey : PCATM.RetMsgTyp :
033900231214                   PCATM.RetPgmMsg);
034000231214      If AddChgDsp = ADD;                        // Turn add mode back on, because it will be off
034100231214        AddCode_36 = *ON;                        // when control is returned back to this program
034200231214      EndIf;
034300231214      If PCATM.RetFncKey=EXIT;                   // If exit passed back by program called, then exit
034400231214        RetFncKey = EXIT;                        // back to menu
034500231214        Leave;
034600231214      ElseIf PCATM.RetPgmMsg <> *BLANKS;
034700231214        CPF9898.Field1 = PCATM.RetPgmMsg;
034800231214        SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
034900231214                  MsgQNbr_Cur : MsgKey : APIErrC);
035000231214        If PCATM.RetMsgTyp = ERROR;              // Error message passed back from program called
035100231214          DataErr_89 = *ON;
035200231214        EndIf;
035300231214      EndIf;
035400231214    Else;                                        // Acocunt type not filled in :-(
035500231214      SndPgmMsg(Err_AcTyCdB : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
035600231214                 MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC);
035700231214      DataErr_89 = *ON;
035800231214    EndIf;
035900231214
036000231214
036100231214  // Enter - Process the display....................................................................
036200231214  Other;
036300231214    If AddChgDsp = ADD and DataChg_91 and DataAdded <> YES;
036400231214      If ProtFld_28 = *OFF;                        // Must have the security to add codes
036500231214        AddCode_36 = *ON;
036600231214        VldAccTypDta();
036700231214        If not DataErr_89;
036800231214          AddTypCdeDta();
036900231214        EndIf;
037000231214      Else;
037100231214        SndPgmMsg(Err_CodeAdd : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
037200231214                   MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC);
037300231214        DataErr_89 = *ON;
037400231214      EndIf;
037500231214    ElseIf AddChgDsp = CHANGE and DataChg_91 or AddChgDsp = ADD and DataChg_91 and DataAdded = YES;
037600231214      If ProtFld_28 = *OFF;
037700231214        VldAccTypDta();
037800231214        If DataErr_89 = *OFF;
037900231214          ChgAccCdeDta();                          // Update the data in the Account Type file
038000231214        EndIf;
038100231214      Else;
038200231214        SndPgmMsg(Err_CodeChg : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
038300231214                   MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC);
038400231214        DataErr_89 = *ON;
038500231214      EndIf;
038600231214    EndIf;
038700231214  EndSL;
038800231214
038900231214EndDo;                                           // DoU F3_Exit or F12_Cancel
039000231214
039100231214// Close files that were opened by this program.....................................................
039200231214CloseOpenFiles();
039300231214
039400231214//--------------------------------------------------------------------------------------------------
039500231214//- SUBPROCEDURE: ProgramEntry                                                                     -
039600231214//- FUNCTION....: Tasks Done When The Prorgam Is First Run                                         -
039700231214//- EXPLANATION.: Process all of the tasks that only need to done when the program is first run.   -
039800231214//-               Such as, getting user privileges, opening files, initializing variables, etc.    -
039900240416//-                                                                                                -
040000240416//- - - - - - - - - - - - - - - - - - -  V A R I A B L E S   - - - - - - - - - - - - - - - - - - - -
040100240416//-      Name                                          Description                                 -
040200240416//- --------------   ----------------------------------------------------------------------------- -
040300240416//- FilePrefix       Prefix needed for the file to open the correct customer file (Mxx)            -
040400240416//--------------------------------------------------------------------------------------------------
040500231214Dcl-Proc ProgramEntry;
040600231214
040700231214  // Declare standalone variables...................................................................
040800231214  Dcl-S FilePrefix Char(3);
040900231214
041000231214  // Going down one level in the message queue......................................................
041100231214  MsgQNbr_Cur += 1;
041200231214
041300231214  // Set program name for error message screen and initialize the error message screen..............
041400231214  *INLR = *ON;
041500231214  Clear INFO_R;
041600231214  MSGC_R.PGMNAME = PgmName;                      // Required because of screen record format DS
041700231214  ClrMsgQ( MsgQ_Cur : MsgQNbr_Cur : MsgKey_All :  MsgRmv_All : APIErrC);
041800231214
041900231214  // Retrieve the user security information from the program security file..........................
042000231214  If AddChgDsp = *BLANKS;
042100231214  RtvSecDta(PgmName : JobUser : RSECD.SecFileDta : RSECD.ErrorMsg);
042200231214    If RSECD.ErrorMsg = *BLANKS;
042300231214      If RSECD.SecFileDta.SEC02 <> YES;          // Pay code data edit security
042400231214        ProtFld_28 = *ON;                        // Do not allow editing of pay code data
042500231214      EndIf;
042600231214    Else;
042700231214      CPF9898.Field1 = RSECD.ErrorMsg;
042800231214      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
042900231214                 MsgQNbr_Cur : MsgKey : APIErrC);
043000231214      ProtFld_28 = *ON;
043100231214      DataErr_89 = *ON;
043200231214    EndIf;
043300231214  ElseIf AddChgDsp = DISPLAY;
043400231214    ProtFld_28 = *ON;
043500231214  EndIf;
043600231214
043700231214  // Customer code needed to open the correct files.................................................
043800231214  If %Len(%Trim(CustCode)) = 2;
043900231214    FilePrefix = 'M' + CustCode;
044000231214    MyLDA.Group = CustCode;
044100231214  Else;
044200231214    In MyLDA;
044300231214    FilePrefix = MyLDA.Entity;
044400231214  EndIf;
044500231214
044600231214  // Open the correct account type file and audit file..............................................
044700231214  If %Len(%Trim(FilePrefix)) = 3;
044800231214    AccTypF = FilePrefix + '.ATM';
044900231214    If not %Open(ATM);
045000231214      Open(E) ATM;
045100231214      If %Error;
045200231214        CPF9898.Field1 = 'The program could not open the file ' + AccTypF + '. Contact IT for help';
045300231214        SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
045400231214                   MsgQNbr_Cur : MsgKey : APIErrC);
045500231214        DataErr_89  = *ON;
045600231214      EndIf;
045700231214    EndIf;
045800231214
045900231214    AcTyPyCdF = FilePrefix + '.ATP1';
046000231214    If not %Open(ATP1);
046100231214      Open(E) ATP1;
046200231214      If %Error;
046300231214        CPF9898.Field1 = 'The program could not open the file ' + AcTyPyCdF + '. Contact IT for help';
046400231214        SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
046500231214                   MsgQNbr_Cur : MsgKey : APIErrC);
046600231214        DataErr_89  = *ON;
046700231214      EndIf;
046800231214    EndIf;
046900231214
047000231214  Else;
047100231214    CPF9898.Field1 = 'LDA missing data. Cannot open correct file. Contact IT for help';
047200231214    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
047300231214               MsgQNbr_Cur : MsgKey : APIErrC);
047400231214    DataErr_89  = *ON;
047500231214  EndIf;
047600231214
047700231214  // Retrieve the customer company and center it in the field.......................................
047800231214  RtvSysDta(CustCode : SYSKEY : RSYSD.SysFileDta : RSYSD.ErrorMsg);
047900231214  If RSYSD.ErrorMsg = *BLANKS;
048000231214    CompanyName = CenterText(RSYSD.SysFileDta.SYSNAM);
048100231214  Else;
048200231214    CPF9898.Field1 = RSYSD.ErrorMsg;
048300231214    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
048400231214               MsgQNbr_Cur : MsgKey : APIErrC);
048500231214    DataErr_89 = *ON;
048600231214  EndIf;
048700231214
048800231214  // Retrieve the detail data for the account type code.............................................
048900231214  If not DataErr_89 and AddChgDsp <> ADD;
049000231214    INFO_R.ATMATYPE = AcctTyCde;
049100231214    RtvAccTypData();
049200231214  ElseIf not DataErr_89 and AddChgDsp = ADD;
049300231214    AddCode_36 = *ON;
049400231214  EndIf;
049500231214
049600231214  // Going up one level in the message queue........................................................
049700231214  MsgQNbr_Cur -= 1;
049800231214
049900231214End-Proc ProgramEntry;
050000231214
050100231214//--------------------------------------------------------------------------------------------------
050200231214//- SUBPROCEDURE: RtvAccTypData                                                                    -
050300231214//- FUNCTION....: Retrieve Data To Load Into The Display                                           -
050400231214//- EXPLANATION.: Based on the account type code that was passed to the program, retrieve data     -
050500231214//-               from the Account Type file to populate the display. Even though only one record  -
050600231214//-               is retrieved at a time to populate the display, SQL is used to get the data      -
050700231214//-               because it is slightly quicker when retrieving data.                             -
050800231214//-                                                                                                -
050900231214//- - - - - - - - - - - - - - - - - -   P A R A M E T E R S  - - - - - - - - - - - - - - - - - - - -
051000231214//      Name      I/O                                  Description                                 -
051100231214// -------------- --- ---------------------------------------------------------------------------- -
051200231214//- HowToRtv      In  How the data is to be retrieved: By code, description or search string       -
051300231214//-                                                                                                -
051400231214//- - - - - - - - - - - - - - - - - - -  C O N S T A N T S   - - - - - - - - - - - - - - - - - - - -
051500231214//-      Name                                          Description                                 -
051600231214//- --------------   ----------------------------------------------------------------------------- -
051700231214//- ASCENDING        Sort the returned SQL data in ascending sequence                              -
051800231214//- DESCENDING       Sort the returned SQL data in descending sequence                             -
051900231214//- MAXSFREC         Maximum number of records in the main subfile                                 -
052000231214//- SPACE            Used to put spaces inbetween the different clauses of the SQL statement       -
052100231214//- SQLOK            Status of good SQL processing                                                 -
052200231214//- SQLEOF           SQL end of file indicator                                                     -
052300231214//- SQUOTE           Single quote to put around character values in the SQL statement              -
052400231214//-                                                                                                -
052500231214//- - - - - - - - - - - - - - - - - - -  V A R I A B L E S   - - - - - - - - - - - - - - - - - - - -
052600231214//-      Name                                          Description                                 -
052700231214//- --------------   ----------------------------------------------------------------------------- -
052800231214//- ForClause        Dynamic SQL FOR clause (not required; however, it is recommended)             -
052900231214//- GroupByClause    Dynamic SQL GROUP BY clause used to get unique values for the field           -
053000231214//- OrderByClause    Dynamic SQL ORDER BY clause (not required)                                    -
053100231214//- SelectClause     Dynamic SQL SELECT clause (also update, delete, etc)                          -
053200231214//- SortSeq          Sequence in which the data is sorted (ascending or descending)                -
053300231214//- SQLStmt          Complete dynamic SQL stament to be executed                                   -
053400231214//- WhereClause      Dynamic SQL WHERE clause                                                      -
053500231214//--------------------------------------------------------------------------------------------------
053600231214Dcl-Proc RtvAccTypData;
053700231214
053800231214  // Declare constants..............................................................................
053900231214  Dcl-C ASCENDING  Const('ASC');
054000231214  Dcl-C DESCENDING Const('DESC');
054100231214  Dcl-C MAXSFREC   Const(1200);
054200231214  Dcl-C SPACE      Const(' ');
054300231214  Dcl-C SQLOK      Const('00000');
054400231214  Dcl-C SQLEOF     Const('02000');
054500231214  Dcl-C SQUOTE     Const('''');
054600231214
054700231214  // Declare standalone variables...................................................................
054800231214  Dcl-S ForClause     Char(  64);
054900231214  Dcl-S GroupByClause Char( 128);
055000231214  Dcl-S OrderByClause Char( 128);
055100231214  Dcl-S SelectClause  Char( 256);
055200231214  Dcl-S SortSeqAsc    Char(   4)  Inz(ASCENDING);
055300231214  Dcl-S SortSeqDsc    Char(   4)  Inz(DESCENDING);
055400231214  Dcl-S SQLStmt       Char(1024);
055500231214  Dcl-S WhereClause   Char( 256);
055600231214
055700231214  // Going down one level in the message queue......................................................
055800231214  MsgQNbr_Cur += 1;
055900231214
056000231214  // Build the SQL select clause....................................................................
056100231214  SelectClause = 'select * from "' + AccTypF + '"';
056200231214
056300231214  // Build the SQL where clause.....................................................................
056400231214  WhereClause = ' where ATMATYPE = ' + SQUOTE + INFO_R.ATMATYPE + SQUOTE;
056500231214
056600231214  // Build the SQL group by clause(not needed)......................................................
056700231214  GroupByClause = SPACE;
056800231214
056900231214  // Build the SQL order by clause..................................................................
057000231214  OrderByClause = 'order by ATMATYPE ' + SortSeqAsc;
057100231214
057200231214  // Build the SQL for clause.......................................................................
057300231214  ForClause = 'for read only';
057400231214
057500231214  // Build the SQL statement separating each clause by a space......................................
057600231214  SQLStmt = %Trim(SelectClause) + SPACE + %Trim(WhereClause) + SPACE + %Trim(GroupByClause) +
057700231214            SPACE + %Trim(OrderByClause) + SPACE + %TrimR(ForClause);
057800231214
057900231214  // Commit must be set to none since table is not journaled........................................
058000231214  Exec SQL Set Option Commit = *NONE, Closqlcsr = *ENDMOD;
058100231214
058200231214  // Declare the cursor for dynamic SQL statement...................................................
058300231214  Exec SQL Declare InputFile cursor for DynSQLStmt;
058400231214
058500231214  // Prepare the declared dynamic SQL cursor to receive data........................................
058600231214  Exec SQL Prepare DynSQLStmt from :SQLStmt;
058700231214
058800231214  // Open the cursor for reading of the data and make sure data was retrieved.......................
058900231214  Exec SQL Open InputFile;
059000231214  If SQLState <> SQLOK;
059100231214    Wrn0000.Field1 = SQLStmt;
059200231214    SndPgmMsg(Wrn_NoDtaRt : MsgFile_Dft : Wrn0000 : %Len(Wrn0000) : MsgTy_Diag : MsgQ_Cur :
059300231214               MsgQNbr_Cur : MsgKey : APIErrC);
059400231214    DataErr_89 = *ON;
059500231214  EndIf;
059600231214
059700231214  // Read the data into the data structure and wrtie it to the file.................................
059800231214  If SQLState = SQLOK and DataErr_89 = *OFF;
059900231214    Exec SQL Fetch next from InputFile into :DataIn;
060000231214
060100231214    DoW SQLState = SQLOK and SQLState <> SQLEOF;
060200231214      EVAL-Corr INFO_R = DataIn;
060300231214      If DataIn.ATMINACDT <> *ZERO;
060400231214        INFO_R.ATMINACDT = %Dec(%Char(%Date(DataIn.ATMINACDT:*ISO):*USA0):8:0);
060500231214      EndIf;
060600231214      Write DSP.MCM0101 INFO_R;
060700231214      Exec SQL Fetch next from InputFile into :DataIn;
060800231214    EndDo;
060900231214  EndIf;
061000231214
061100231214  // Close the cursor once the data has been read...................................................
061200231214  Exec SQL Close InputFile;
061300231214
061400231214  // No records read from input file, so show warning message.......................................
061500231214  If SQLState <> SQLOK;
061600231214    CPF9898.Field1 = 'No data found for account type code. Contact IT if problem persists';
061700231214    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
061800231214               MsgQNbr_Cur : MsgKey : APIErrC);
061900231214    DataErr_89  = *ON;
062000231214  EndIf;
062100231214
062200231214  // Going up one level in the message queue........................................................
062300231214  MsgQNbr_Cur -= 1;
062400231214
062500231214End-Proc RtvAccTypData;
062600231214
062700231214//--------------------------------------------------------------------------------------------------
062800231214//- SUBPROCEDURE: VldAccTypDta                                                                     -
062900231214//- FUNCTION....: Validate Changes Made To The Account Type Code Data                              -
063000231214//- EXPLANATION.: The account type code data has to be validated before being written to the file. -
063100231214//-               The payer identification and the EDI suffix name are allowed to be blank.  On an -
063200231214//-               add, the account type has to be checked to make sure that it does not already    -
063300231214//-               exist in the file. On a change, the account type code cannot be modified.        -
063400231214//-                                                                                                -
063500231214//- - - - - - - - - - - - - - - - - - -  C O N S T A N T S   - - - - - - - - - - - - - - - - - - - -
063600231214//-      Name                                          Description                                 -
063700231214//- --------------   ----------------------------------------------------------------------------- -
063800231214//- VLDACCEPT        Valid values for accept assignment                                            -
063900231214//- VLDCHGINT        Valid values for charge interest                                              -
064000231214//- VLDCLMFRE        Valid values for claim frequency                                              -
064100231214//- VLDPAPCPY        Valid values for paper copy only                                              -
064200231214//- VLDSTMTYP        Valid values for statement type                                               -
064300231214//- YESNO            Validation for fields with allowed values of N or Y                           -
064400231214//- YESNOBLNK        Validation for fields with allowed values of blank, N, or Y                   -
064500231214//--------------------------------------------------------------------------------------------------
064600231214Dcl-Proc VldAccTypDta;
064700231214
064800231214  // Declare constants..............................................................................
064900231214  Dcl-C VLDACCEPT Const('AN');
065000231214  Dcl-C VLDCHGINT Const('Y ');
065100231214  Dcl-C VLDCLMFRE Const('DMNW');
065200231214  Dcl-C VLDPAPCPY Const('BNY');
065300231214  Dcl-C VLDSTMTYP Const('NS');
065400231214  Dcl-C YESNO     Const('YN');
065500231214  Dcl-C YESNOBLNK Const('YN ');
065600231214
065700231214  // Going down one level in the message queue......................................................
065800231214  MsgQNbr_Cur += 1;
065900231214
066000231214  // Account type cannot be blank...................................................................
066100231214  If INFO_R.ATMATYPE = *BLANKS;
066200231214    ERR0024.Field1 = 'Account Type';
066300231214    SndPgmMsg(Err_MisValu : MsgFile_Dft : Err0024 : %Len(Err0024) : MsgTy_Diag : MsgQ_Cur :
066400231214               MsgQNbr_Cur : MsgKey : APIErrC);
066500231214    AccTyCd_40 = *ON;
066600231214    DataErr_89 = *ON;
066700231214  EndIf;
066800231214
066900231214  // See if the account type code areadly exists in the file........................................
067000231214  If AddCode_36 = *ON;
067100231214    SetLL(E) (INFO_R.ATMATYPE) ATM.ATMR;
067200231214    If %Equal and not %Error;
067300231214      ERR0029.Field1 = INFO_R.ATMATYPE;
067400231214      ERR0029.Field2 = AccTypF;
067500231214      SndPgmMsg(Err_KeyValu : MsgFile_Dft : Err0029 : %Len(Err0029) : MsgTy_Diag : MsgQ_Cur :
067600231214                 MsgQNbr_Cur : MsgKey : APIErrC);
067700231214      AccTyCd_40 = *ON;
067800231214      DataErr_89 = *ON;
067900231214    ElseIf %Error;
068000231214      CPF9898.Field1 = 'Issues checking the existance of the account type in the Acct Type file';
068100231214      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
068200231214                 MsgQNbr_Cur : MsgKey : APIErrC);
068300231214      DataErr_89 = *ON;
068400231214    EndIf;
068500231214  EndIf;
068600231214
068700231214  // Inactive date is invalid.......................................................................
068800231214  If INFO_R.ATMINACDT <> *ZERO;
068900231214    Test(DE) *USA INFO_R.ATMINACDT;
069000231214    If %Error;
069100231214      SndPgmMsg(Err_InvDat : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
069200231214      MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC);
069300231214      InactDt_41 = *ON;
069400231214      DataErr_89 = *ON;
069500231214    EndIf;
069600231214  EndIf;
069700231214
069800231214  // Account type file description cannot be blanks.................................................
069900231214  If INFO_R.ATMADESC = *BLANKS;
070000231214    ERR0024.Field1 = 'Account Type Description';
070100231214    SndPgmMsg(Err_MisValu : MsgFile_Dft : Err0024 : %Len(Err0024) : MsgTy_Diag : MsgQ_Cur :
070200231214    MsgQNbr_Cur : MsgKey : APIErrC);
070300231214    TypDesc_42 = *ON;
070400231214    DataErr_89 = *ON;
070500231214  EndIf;
070600231214
070700231214  // OBRA/IRCA has to be Y, N or blank..............................................................
070800231214  If %Check(YESNOBLNK : INFO_R.ATMOBRIRC) <> *ZERO;
070900231214    SndPgmMsg(CPF_InvldOp : MsgFile_CPF : MsgDta_None : MsgDtaLen_None : MsgTy_Diag : MsgQ_Cur :
071000231214    MsgQNbr_Cur : MsgKey : APIErrC);
071100231214    OBRAIRC_43 = *ON;
071200231214    DataErr_89 = *ON;
071300231214  EndIf;
071400231214
071500231214  // OBRA/IRCA has to be N or blank if the insurance type code is not 2 or 8........................
071600231214  If INFO_R.ATMINSTYP <> 2 and INFO_R.ATMINSTYP <> 8;
071700231214    If INFO_R.ATMOBRIRC <> *BLANKS and INFO_R.ATMOBRIRC <> 'N';
071800231214      CPF9898.Field1 = 'OBRA/IRCA must be N or blank if the insurance type code is not 2 or 8';
071900231214      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
072000231214      MsgQNbr_Cur : MsgKey : APIErrC);
072100231214      OBRAIRC_43 = *ON;
072200231214      DataErr_89 = *ON;
072300231214    EndIf;
072400231214  EndIf;
072500231214
072600231214  // Short account type description cannot be blank.................................................
072700231214  If INFO_R.ATMABRDSC = *BLANKS;
072800231214    ERR0024.Field1 = 'Short Account Type Description';
072900231214    SndPgmMsg(Err_MisValu : MsgFile_Dft : Err0024 : %Len(Err0024) : MsgTy_Diag : MsgQ_Cur :
073000231214    MsgQNbr_Cur : MsgKey : APIErrC);
073100231214    AbrDesc_44 = *ON;
073200231214    DataErr_89 = *ON;
073300231214  EndIf;
073400231214
073500231214  // Accept assignment cannot be blank.......................................................
073600231214  If %Check(VLDACCEPT : INFO_R.ATMASSIGN) <> *ZERO;
073700231214    Err0032.Field1 = 'accept assignment';
073800231214    Err0032.Field2 = 'A or N';
073900231214    SndPgmMsg(Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
074000231214    MsgQNbr_Cur : MsgKey : APIErrC);
074100231214    AcpAsgn_45 = *ON;
074200231214    DataErr_89 = *ON;
074300231214  EndIf;
074400231214
074500231214  // Acronym cannot be blank........................................................................
074600231214  If INFO_R.ATMACRNYM = *BLANKS;
074700231214    ERR0024.Field1 = 'Acronym';
074800231214    SndPgmMsg(Err_MisValu : MsgFile_Dft : Err0024 : %Len(Err0024) : MsgTy_Diag : MsgQ_Cur :
074900231214    MsgQNbr_Cur : MsgKey : APIErrC);
075000231214    Acronym_46 = *ON;
075100231214    DataErr_89 = *ON;
075200231214  EndIf;
075300231214
075400231214  // Charge interest must be an allowed value.......................................................
075500231214  If %Check(VLDCHGINT : INFO_R.ATMATMINT) <> *ZERO;
075600231214    Err0032.Field1 = 'charge interest';
075700231214    Err0032.Field2 = 'blank or Y';
075800231214    SndPgmMsg(Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
075900231214    MsgQNbr_Cur : MsgKey : APIErrC);
076000231214    ChrgInt_47 = *ON;
076100231214    DataErr_89 = *ON;
076200231214  EndIf;
076300231214
076400231214  // Edit severity code must be between 00 and 04...................................................
076500231214  If INFO_R.ATMERRLVL < *ZERO or INFO_R.ATMERRLVL > 4;
076600231214    CPF9898.Field1 = 'Severity code must be between 00 and 04';
076700231214    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
076800231214    MsgQNbr_Cur : MsgKey : APIErrC);
076900231214    EdSvrCd_48 = *ON;
077000231214    DataErr_89 = *ON;
077100231214  EndIf;
077200231214
077300231214  // Referring physician required must be an allowed value..........................................
077400231214  If %Check(YESNOBLNK : INFO_R.ATMATRFRQ) <> *ZERO;
077500231214    Err0032.Field1 = 'referring physician required';
077600231214    Err0032.Field2 = 'blank, Y, or N';
077700231214    SndPgmMsg(Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
077800231214    MsgQNbr_Cur : MsgKey : APIErrC);
077900231214    PhysReq_49 = *ON;
078000231214    DataErr_89 = *ON;
078100231214  EndIf;
078200231214
078300231214  // Type of statement must be N or S...............................................................
078400231214  If %Check(VLDSTMTYP : INFO_R.ATMSTMTYP) <> *ZERO;
078500231214    Err0032.Field1 = 'type of statement';
078600231214    Err0032.Field2 = 'N or S';
078700231214    SndPgmMsg(Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
078800231214    MsgQNbr_Cur : MsgKey : APIErrC);
078900231214    StmtTyp_50 = *ON;
079000231214    DataErr_89 = *ON;
079100231214  EndIf;
079200231214
079300231214  // Claims frequency must be D, M, N, or W.........................................................
079400231214  If %Check(VLDCLMFRE : INFO_R.ATMINSFM) <> *ZERO;
079500231214    Err0032.Field1 = 'claims frequency';
079600231214    Err0032.Field2 = 'D, M, N, or W';
079700231214    SndPgmMsg(Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
079800231214    MsgQNbr_Cur : MsgKey : APIErrC);
079900231214    ClmFreq_51 = *ON;
080000231214    DataErr_89 = *ON;
080100231214  EndIf;
080200231214
080300231214  // Insurance type must be between 0 and 8.........................................................
080400231214  If INFO_R.ATMINSTYP < 0 or INFO_R.ATMINSTYP > 8;
080500231214    Err0032.Field1 = 'insurance type';
080600231214    Err0032.Field2 = 'between 0 and 8';
080700231214    SndPgmMsg(Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
080800231214    MsgQNbr_Cur : MsgKey : APIErrC);
080900231214    InsType_52 = *ON;
081000231214    DataErr_89 = *ON;
081100231214  EndIf;
081200231214
081300231214  // Insurance code must be 2 or 8 if form type is 401C or 151C.....................................
081400231214  If INFO_R.ATMFRMCD = '401C' or INFO_R.ATMFRMCD = '151C';
081500231214    If INFO_R.ATMINSTYP <> 2 and INFO_R.ATMINSTYP <> 8;
081600231214      Err0034.Field1 = '02 or 08';
081700231214      Err0034.Field2 = INFO_R.ATMFRMCD;
081800231214      SndPgmMsg(Err_InsCde : MsgFile_Dft : Err0034 : %Len(Err0034) : MsgTy_Diag : MsgQ_Cur :
081900231214      MsgQNbr_Cur : MsgKey : APIErrC);
082000231214      InsType_52 = *ON;
082100231214      DataErr_89 = *ON;
082200231214    EndIf;
082300231214  EndIf;
082400231214
082500231214  // Produce paper form only must be B, N or Y......................................................
082600231214  If %Check(VLDPAPCPY : INFO_R.ATMPAPER) <> *ZERO;
082700231214    Err0032.Field1 = 'paper copy only';
082800231214    Err0032.Field2 = 'B, N or Y';
082900231214    SndPgmMsg(Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
083000231214    MsgQNbr_Cur : MsgKey : APIErrC);
083100231214    PprOnly_53 = *ON;
083200231214    DataErr_89 = *ON;
083300231214  EndIf;
083400231214
083500231214  // Form used for paper report cannot be blank if produce paper form set to B or Y..................
083600231214  If INFO_R.ATMFRMCD = *BLANKS and INFO_R.ATMPAPER = 'Y' or INFO_R.ATMFRMCD = *BLANKS and
083700231214    INFO_R.ATMPAPER = 'B';
083800231214    CPF9898.Field1 = 'Form used for paper report must be filled in when paper copy only is B or Y';
083900231214    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
084000231214               MsgQNbr_Cur : MsgKey : APIErrC);
084100231214    FormTyp_54 = *ON;
084200231214    DataErr_89 = *ON;
084300231214  EndIf;
084400231214
084500231214  // Form type must be UB04, 1500 or 401C............................................................
084600231214  If INFO_R.ATMPAPER = 'B' or INFO_R.ATMPAPER = 'Y';
084700231214    If INFO_R.ATMFRMCD <> 'UB04' and INFO_R.ATMFRMCD <> '1500' and INFO_R.ATMFRMCD <> '401C';
084800231214      Err0032.Field1 = 'paper form type';
084900231214      Err0032.Field2 = 'UB04, 1500 or 401C';
085000231214      SndPgmMsg(Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
085100231214      MsgQNbr_Cur : MsgKey : APIErrC);
085200231214      FormTyp_54 = *ON;
085300231214      DataErr_89 = *ON;
085400231214    EndIf;
085500231214  EndIf;
085600231214
085700231214  // Form used for paper report must be blank if produce paper form set to N........................
085800231214  If INFO_R.ATMPAPER = 'N' and INFO_R.ATMFRMCD <> *BLANKS;
085900231214    CPF9898.Field1 = 'Form used for paper report must be blank in when paper copy only is N';
086000231214    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
086100231214               MsgQNbr_Cur : MsgKey : APIErrC);
086200231214    FormTyp_54 = *ON;
086300231214    DataErr_89 = *ON;
086400231214  EndIf;
086500231214
086600231214  // Initial statement after xxx days...............................................................
086700231214  If INFO_R.ATMINITST < *ZERO or INFO_R.ATMINITST > 999;
086800231214    Err0032.Field1 = 'initial statement days';
086900231214    Err0032.Field2 = 'between 0 and 999';
087000231214    SndPgmMsg(Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
087100231214    MsgQNbr_Cur : MsgKey : APIErrC);
087200231214    IntStDy_56 = *ON;
087300231214    DataErr_89 = *ON;
087400231214  EndIf;
087500231214
087600231214  // Initial statement days must be filled in if initial statement message code is filled in........
087700231214  If INFO_R.ATMINITST = *ZERO and INFO_R.ATMINTMSG <> *ZERO;
087800231214    Err0035.Field1 = 'iinitial statement days';
087900231214    Err0035.Field2 = 'initial statement message code';
088000231214    SndPgmMsg(Err_FldFill : MsgFile_Dft : Err0035 : %Len(Err0035) : MsgTy_Diag : MsgQ_Cur :
088100231214    MsgQNbr_Cur : MsgKey : APIErrC);
088200231214    IntStDy_56 = *ON;
088300231214    DataErr_89 = *ON;
088400231214  EndIf;
088500231214
088600231214  // Initial statement message code.................................................................
088700231214  If INFO_R.ATMINTMSG <> *ZERO;
088800231214    SetLL(E) (STATEMENT : INFO_R.ATMINTMSG) MSGR;
088900231214    If not %Equal;
089000231214      Err0033.Field1 = 'initial statement message code';
089100231214      SndPgmMsg(Err_MsgCde : MsgFile_Dft : Err0033 : %Len(Err0033) : MsgTy_Diag : MsgQ_Cur :
089200231214      MsgQNbr_Cur : MsgKey : APIErrC);
089300231214      IntStMC_57 = *ON;
089400231214      DataErr_89 = *ON;
089500231214    ElseIf %Error;
089600231214      CPF9898.Field1 = 'Error encountered when trying to check initial statement message code';
089700231214      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
089800231214      MsgQNbr_Cur : MsgKey : APIErrC);
089900231214    EndIf;
090000231214  EndIf;
090100231214
090200231214  // Initial statement message code must be filled in if initial statement days is filled in........
090300231214  If INFO_R.ATMINITST <> *ZERO and INFO_R.ATMINTMSG = *ZERO;
090400231214    Err0035.Field1 = 'initial statement message code ';
090500231214    Err0035.Field2 = 'initial statement days';
090600231214    SndPgmMsg(Err_FldFill : MsgFile_Dft : Err0035 : %Len(Err0035) : MsgTy_Diag : MsgQ_Cur :
090700231214    MsgQNbr_Cur : MsgKey : APIErrC);
090800231214    IntStDy_56 = *ON;
090900231214    DataErr_89 = *ON;
091000231214  EndIf;
091100231214
091200231214  // Deliquent letter after xxx days................................................................
091300231214  If INFO_R.ATMOLDL < *ZERO or INFO_R.ATMOLDL > 999;
091400231214    Err0032.Field1 = 'deliquent letter days';
091500231214    Err0032.Field2 = 'between 0 and 999';
091600231214    SndPgmMsg(Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
091700231214    MsgQNbr_Cur : MsgKey : APIErrC);
091800231214    DelLtDy_58 = *ON;
091900231214    DataErr_89 = *ON;
092000231214  EndIf;
092100231214
092200231214  // Deliquent letter after xxx days must be filled in if include stmt with deliquent letter is Y...
092300231214  If INFO_R.ATMOLDL = *ZERO and INFO_R.ATMSTMTDL = 'Y';
092400231214    Err0035.Field1 = 'deliquent letter days';
092500231214    Err0035.Field2 = 'include statement with deliquent letter';
092600231214    SndPgmMsg(Err_FldFill : MsgFile_Dft : Err0035 : %Len(Err0035) : MsgTy_Diag : MsgQ_Cur :
092700231214    MsgQNbr_Cur : MsgKey : APIErrC);
092800231214    DelLtDy_58 = *ON;
092900231214    DataErr_89 = *ON;
093000231214  EndIf;
093100231214
093200231214  // Deliquent letter after xxx days must be filled in if deliquent stmt message code is filled in..
093300231214  If INFO_R.ATMOLDL = *ZERO and INFO_R.ATMMSGDL <> *ZERO;
093400231214    Err0035.Field1 = 'deliquent letter days';
093500231214    Err0035.Field2 = 'deliquent statement message code';
093600231214    SndPgmMsg(Err_FldFill :MsgFile_Dft : Err0035 : %Len(Err0035) : MsgTy_Diag : MsgQ_Cur :
093700231214    MsgQNbr_Cur : MsgKey : APIErrC);
093800231214    DelLtDy_58 = *ON;
093900231214    DataErr_89 = *ON;
094000231214  EndIf;
094100231214
094200231214  // Include statement with deliquent letter........................................................
094300231214  If %Check(YESNO : INFO_R.ATMSTMTDL) <> *ZERO;
094400231214    Err0032.Field1 = 'statement with deliquent letter';
094500231214    Err0032.Field2 = 'N or Y';
094600231214    SndPgmMsg(Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
094700231214    MsgQNbr_Cur : MsgKey : APIErrC);
094800231214    DelLtSt_59 = *ON;
094900231214    DataErr_89 = *ON;
095000231214  EndIf;
095100231214
095200231214  // Deliquent statement message code...............................................................
095300231214  If INFO_R.ATMMSGDL <> *ZERO;
095400231214    SetLL(E) (DELIQUENT : INFO_R.ATMMSGDL) MSGR;
095500231214    If not %Equal;
095600231214      Err0033.Field1 = 'deliquent statement message code';
095700231214      SndPgmMsg(Err_MsgCde : MsgFile_Dft : Err0033 : %Len(Err0033) : MsgTy_Diag : MsgQ_Cur :
095800231214      MsgQNbr_Cur : MsgKey : APIErrC);
095900231214      DelLtMC_60 = *ON;
096000231214      DataErr_89 = *ON;
096100231214    ElseIf %Error;
096200231214      CPF9898.Field1 = 'Error encountered when trying to check deliquent statement message code';
096300231214      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
096400231214      MsgQNbr_Cur : MsgKey : APIErrC);
096500231214     EndIf;
096600231214  EndIf;
096700231214
096800231214  // Deliquent statement message code must be filled in if deliquent ltr after xxx days filled in...
096900231214  If INFO_R.ATMOLDL <> *ZERO and INFO_R.ATMMSGDL = *ZERO;
097000231214    Err0035.Field1 = 'deliquent statement message code';
097100231214    Err0035.Field2 = 'deliquent letter days';
097200231214    SndPgmMsg(Err_FldFill : MsgFile_Dft : Err0035 : %Len(Err0035) : MsgTy_Diag : MsgQ_Cur :
097300231214    MsgQNbr_Cur : MsgKey : APIErrC);
097400231214    DelLtMC_60 = *ON;
097500231214    DataErr_89 = *ON;
097600231214  EndIf;
097700231214
097800231214  // Deliquent statement days must be greater than initial statement days...........................
097900231214  If INFO_R.ATMOLDL <> *ZERO and INFO_R.ATMOLDL <= INFO_R.ATMINITST;
098000231214    Err0047.Field1 = 'deliquent letter';
098100231214    Err0047.Field2 = 'initial statement';
098200231214    SndPgmMsg(Err_D2LTD1 : MsgFile_Dft : Err0047 : %Len(Err0047) : MsgTy_Diag : MsgQ_Cur :
098300231214    MsgQNbr_Cur : MsgKey : APIErrC);
098400231214    IntStDy_56 = *ON;
098500231214    DelLtDy_58 = *ON;
098600231214    DataErr_89 = *ON;
098700231214  EndIf;
098800231214
098900231214  // Current statement message code.................................................................
099000231214  If INFO_R.ATMMSGCR <> *ZERO;
099100231214    SetLL(E) (STATEMENT : INFO_R.ATMMSGCR) MSGR;
099200231214    If not %Equal;
099300231214      Err0033.Field1 = 'current statement message code';
099400231214      SndPgmMsg(Err_MsgCde : MsgFile_Dft : Err0033 : %Len(Err0033) : MsgTy_Diag : MsgQ_Cur :
099500231214      MsgQNbr_Cur : MsgKey : APIErrC);
099600231214      StMCCur_61 = *ON;
099700231214      DataErr_89 = *ON;
099800231214    ElseIf %Error;
099900231214      CPF9898.Field1 = 'Error encountered when trying to check current statement message code';
100000231214      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
100100231214      MsgQNbr_Cur : MsgKey : APIErrC);
100200231214    EndIf;
100300231214  EndIf;
100400231214
100500231214  // Current statement message code must be filled in if 30 day statement message code is filled in.
100600231214  If INFO_R.ATMMSGCR = *ZERO and INFO_R.ATMMSG30 <> *ZERO;
100700231214    Err0035.Field1 = 'current statement message code';
100800231214    Err0035.Field2 = '30 day statement message code';
100900231214    SndPgmMsg(Err_FldFill : MsgFile_Dft : Err0035 : %Len(Err0035) : MsgTy_Diag : MsgQ_Cur :
101000231214    MsgQNbr_Cur : MsgKey : APIErrC);
101100231214    StMCCur_61 = *ON;
101200231214    DataErr_89 = *ON;
101300231214  EndIf;
101400231214
101500231214  // 30 day statement message code..................................................................
101600231214  If INFO_R.ATMMSG30 <> *ZERO;
101700231214    SetLL(E) (STATEMENT : INFO_R.ATMMSG30) MSGR;
101800231214    If not %Equal;
101900231214      Err0033.Field1 = '30 days statement message code';
102000231214      SndPgmMsg(Err_MsgCde : MsgFile_Dft : Err0033 : %Len(Err0033) : MsgTy_Diag : MsgQ_Cur :
102100231214      MsgQNbr_Cur : MsgKey : APIErrC);
102200231214      StMC030_62 = *ON;
102300231214      DataErr_89 = *ON;
102400231214    ElseIf %Error;
102500231214      CPF9898.Field1 = 'Error encountered when trying to check 30 dayst statement message code';
102600231214      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
102700231214      MsgQNbr_Cur : MsgKey : APIErrC);
102800231214    EndIf;
102900231214  EndIf;
103000231214
103100231214  // 30 day statement message code must be filled in if 60 day statement message code is filled in..
103200231214  If INFO_R.ATMMSG30 = *ZERO and INFO_R.ATMMSG60 <> *ZERO;
103300231214    Err0035.Field1 = '30 day statement message code';
103400231214    Err0035.Field2 = '60 day statement message code';
103500231214    SndPgmMsg(Err_FldFill : MsgFile_Dft : Err0035 : %Len(Err0035) : MsgTy_Diag : MsgQ_Cur :
103600231214    MsgQNbr_Cur : MsgKey : APIErrC);
103700231214    StMC030_62 = *ON;
103800231214    DataErr_89 = *ON;
103900231214  EndIf;
104000231214
104100231214  // 60 day statement message code..................................................................
104200231214  If INFO_R.ATMMSG60 <> *ZERO;
104300231214    SetLL(E) (STATEMENT : INFO_R.ATMMSG60) MSGR;
104400231214    If not %Equal;
104500231214      Err0033.Field1 = '60 days statement message code';
104600231214      SndPgmMsg(Err_MsgCde : MsgFile_Dft : Err0033 : %Len(Err0033) : MsgTy_Diag : MsgQ_Cur :
104700231214      MsgQNbr_Cur : MsgKey : APIErrC);
104800231214      StMC060_63 = *ON;
104900231214      DataErr_89 = *ON;
105000231214    ElseIf %Error;
105100231214      CPF9898.Field1 = 'Error encountered when trying to check 60 days statement message code';
105200231214      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
105300231214      MsgQNbr_Cur : MsgKey : APIErrC);
105400231214    EndIf;
105500231214  EndIf;
105600231214
105700231214  // 60 day statement message code must be filled in if 90 day statement message code is filled in..
105800231214  If INFO_R.ATMMSG60 = *ZERO and INFO_R.ATMMSG90 <> *ZERO;
105900231214    Err0035.Field1 = '60 day statement message code';
106000231214    Err0035.Field2 = '90 day statement message code';
106100231214    SndPgmMsg(Err_FldFill : MsgFile_Dft : Err0035 : %Len(Err0035) : MsgTy_Diag : MsgQ_Cur :
106200231214    MsgQNbr_Cur : MsgKey : APIErrC);
106300231214    StMC060_63 = *ON;
106400231214    DataErr_89 = *ON;
106500231214  EndIf;
106600231214
106700231214  // 90 day statement message code..................................................................
106800231214  If INFO_R.ATMMSG90 <> *ZERO;
106900231214    SetLL(E) (STATEMENT : INFO_R.ATMMSG90) MSGR;
107000231214    If not %Equal;
107100231214      Err0033.Field1 = '90 days statement message code';
107200231214      SndPgmMsg(Err_MsgCde : MsgFile_Dft : Err0033 : %Len(Err0033) : MsgTy_Diag : MsgQ_Cur :
107300231214      MsgQNbr_Cur : MsgKey : APIErrC);
107400231214      StMC090_64 = *ON;
107500231214      DataErr_89 = *ON;
107600231214    ElseIf %Error;
107700231214      CPF9898.Field1 = 'Error encountered when trying to check 90 days statement message code';
107800231214      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
107900231214      MsgQNbr_Cur : MsgKey : APIErrC);
108000231214    EndIf;
108100231214  EndIf;
108200231214
108300231214  // 90 day statement message code must be filled in if 120 day statement message code is filled in.
108400231214  If INFO_R.ATMMSG90 = *ZERO and INFO_R.ATMMSG120 <> *ZERO;
108500231214    Err0035.Field1 = '90 day statement message code';
108600231214    Err0035.Field2 = '120 day statement message code';
108700231214    SndPgmMsg(Err_FldFill : MsgFile_Dft : Err0035 : %Len(Err0035) : MsgTy_Diag : MsgQ_Cur :
108800231214    MsgQNbr_Cur : MsgKey : APIErrC);
108900231214    StMC090_64 = *ON;
109000231214    DataErr_89 = *ON;
109100231214  EndIf;
109200231214
109300231214  // 120 day statement message code.................................................................
109400231214  If INFO_R.ATMMSG120 <> *ZERO;
109500231214    SetLL(E) (STATEMENT : INFO_R.ATMMSG120) MSGR;
109600231214    If not %Equal;
109700231214      Err0033.Field1 = '120 days statement message code';
109800231214      SndPgmMsg(Err_MsgCde : MsgFile_Dft : Err0033 : %Len(Err0033) : MsgTy_Diag : MsgQ_Cur :
109900231214      MsgQNbr_Cur : MsgKey : APIErrC);
110000231214      StMC120_65 = *ON;
110100231214      DataErr_89 = *ON;
110200231214    ElseIf %Error;
110300231214      CPF9898.Field1 = 'Error encountered when trying to check 120 days statement message code';
110400231214      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
110500231214      MsgQNbr_Cur : MsgKey : APIErrC);
110600231214    EndIf;
110700231214  EndIf;
110800231214
110900231214  // Final notice after xxx days....................................................................
111000231214  If INFO_R.ATMDAYS48 < *ZERO or INFO_R.ATMDAYS48 > 999;
111100231214    Err0032.Field1 = 'final notice days';
111200231214    Err0032.Field2 = 'between 0 and 999';
111300231214    SndPgmMsg(Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
111400231214    MsgQNbr_Cur : MsgKey : APIErrC);
111500231214    FinNtDy_66 = *ON;
111600231214    DataErr_89 = *ON;
111700231214  EndIf;
111800231214
111900231214  // Final notice after xxx days must be filled in if include statement with final notice is Y......
112000231214  If INFO_R.ATMDAYS48 = *ZERO and INFO_R.ATMSTMT48 = 'Y';
112100231214    Err0035.Field1 = 'final notice after xxx days';
112200231214    Err0035.Field2 = 'include statement with final notice';
112300231214    SndPgmMsg(Err_FldFill : MsgFile_Dft : Err0035 : %Len(Err0035) : MsgTy_Diag : MsgQ_Cur :
112400231214    MsgQNbr_Cur : MsgKey : APIErrC);
112500231214    FinNtDy_66 = *ON;
112600231214    DataErr_89 = *ON;
112700231214  EndIf;
112800231214
112900231214  // Final notice after xxx days must be filled in if final notice message code is filled in........
113000231214  If INFO_R.ATMDAYS48 = *ZERO and INFO_R.ATMMSGFN <> *ZERO;
113100231214    Err0035.Field1 = 'final notice after xxx days';
113200231214    Err0035.Field2 = 'final notice message code';
113300231214    SndPgmMsg(Err_FldFill : MsgFile_Dft : Err0035 : %Len(Err0035) : MsgTy_Diag : MsgQ_Cur :
113400231214    MsgQNbr_Cur : MsgKey : APIErrC);
113500231214    FinNtDy_66 = *ON;
113600231214    DataErr_89 = *ON;
113700231214  EndIf;
113800231214
113900231214  // Include statement with final notice............................................................
114000231214  If %Check(YESNO : INFO_R.ATMSTMT48) <> *ZERO;
114100231214    Err0032.Field1 = 'statement with final notice';
114200231214    Err0032.Field2 = 'N or Y';
114300231214    SndPgmMsg(Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
114400231214    MsgQNbr_Cur : MsgKey : APIErrC);
114500231214    FinNtSt_67 = *ON;
114600231214    DataErr_89 = *ON;
114700231214  EndIf;
114800231214
114900231214  // Final notice statement message code............................................................
115000231214  If INFO_R.ATMMSGFN <> *ZERO;
115100231214    SetLL(E) (DELIQUENT : INFO_R.ATMMSGFN) MSGR;
115200231214    If not %Equal;
115300231214      Err0033.Field1 = 'final notice message code';
115400231214      SndPgmMsg(Err_MsgCde : MsgFile_Dft : Err0033 : %Len(Err0033) : MsgTy_Diag : MsgQ_Cur :
115500231214      MsgQNbr_Cur : MsgKey : APIErrC);
115600231214      FinNtMC_68 = *ON;
115700231214      DataErr_89 = *ON;
115800231214    ElseIf %Error;
115900231214      CPF9898.Field1 = 'Error encountered when trying to check final notice message code';
116000231214      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
116100231214      MsgQNbr_Cur : MsgKey : APIErrC);
116200231214    EndIf;
116300231214  EndIf;
116400231214
116500231214  // Final notice message code must be filled in if final notice after xxx days filled in...........
116600231214  If INFO_R.ATMDAYS48 <> *ZERO and INFO_R.ATMMSGFN = *ZERO;
116700231214    Err0035.Field1 = 'final notice message code';
116800231214    Err0035.Field2 = 'final notice after xxx days';
116900231214    SndPgmMsg(Err_InvVal : MsgFile_Dft : Err0035 : %Len(Err0035) : MsgTy_Diag : MsgQ_Cur :
117000231214    MsgQNbr_Cur : MsgKey : APIErrC);
117100231214    FinNtMC_68 = *ON;
117200231214    DataErr_89 = *ON;
117300231214  EndIf;
117400231214
117500231214  // Final notice days must be greater than deliquent letter days...................................
117600231214  If INFO_R.ATMDAYS48 <> *ZERO and INFO_R.ATMDAYS48 <= INFO_R.ATMOLDL;
117700231214    Err0047.Field1 = 'final notice';
117800231214    Err0047.Field2 = 'deliquent letter';
117900231214    SndPgmMsg(Err_D2LTD1 : MsgFile_Dft : Err0047 : %Len(Err0047) : MsgTy_Diag : MsgQ_Cur :
118000231214    MsgQNbr_Cur : MsgKey : APIErrC);
118100231214    DelLtDy_58 = *ON;
118200231214    FinNtDy_66 = *ON;
118300231214    DataErr_89 = *ON;
118400231214  EndIf;
118500231214
118600231214  // Collection list after xxx days.................................................................
118700231214  If INFO_R.ATMCOLOLD < *ZERO or INFO_R.ATMCOLOLD > 999;
118800231214    Err0032.Field1 = 'collection list days';
118900231214    Err0032.Field2 = 'between 0 and 999';
119000231214    SndPgmMsg(Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
119100231214    MsgQNbr_Cur : MsgKey : APIErrC);
119200231214    ColLtDy_69 = *ON;
119300231214    DataErr_89 = *ON;
119400231214  EndIf;
119500231214
119600231214  // Collection list after xxx days must be filled in if include statement with collection list
119700231214  // notice is filled in............................................................................
119800231214  If INFO_R.ATMCOLOLD = *ZERO and INFO_R.ATMCOLSTM = 'Y';
119900231214    Err0035.Field1 = 'collection list after xxx days';
120000231214    Err0035.Field2 = 'include statement with collection list notice';
120100231214    SndPgmMsg(Err_InvVal : MsgFile_Dft : Err0035 : %Len(Err0035) : MsgTy_Diag : MsgQ_Cur :
120200231214    MsgQNbr_Cur : MsgKey : APIErrC);
120300231214    ColLtDy_69 = *ON;
120400231214    DataErr_89 = *ON;
120500231214  EndIf;
120600231214
120700231214  // Include statement with collection list notice..................................................
120800231214  If %Check(YESNO : INFO_R.ATMCOLSTM) <> *ZERO;
120900231214    Err0032.Field1 = 'statement with collection list notice';
121000231214    Err0032.Field2 = 'N or Y';
121100231214    SndPgmMsg(Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
121200231214    MsgQNbr_Cur : MsgKey : APIErrC);
121300231214    ColLtSt_70 = *ON;
121400231214    DataErr_89 = *ON;
121500231214  EndIf;
121600231214
121700231214  // Collection List days must be greater than final notice days....................................
121800231214  If INFO_R.ATMCOLOLD <> *ZERO and INFO_R.ATMCOLOLD <= INFO_R.ATMDAYS48;
121900231214    Err0047.Field1 = 'collection list';
122000231214    Err0047.Field2 = 'final notice';
122100231214    SndPgmMsg(Err_D2LTD1 : MsgFile_Dft : Err0047 : %Len(Err0047) : MsgTy_Diag : MsgQ_Cur :
122200231214    MsgQNbr_Cur : MsgKey : APIErrC);
122300231214    FinNtDy_66 = *ON;
122400231214    ColLtDy_69 = *ON;
122500231214    DataErr_89 = *ON;
122600231214  EndIf;
122700231214
122800231214  // Going up one level in the message queue........................................................
122900231214  MsgQNbr_Cur -= 1;
123000231214
123100231214End-Proc VldAccTypDta;
123200231214
123300231214//--------------------------------------------------------------------------------------------------
123400231214//- SUBPROCEDURE: ChgAccCdeDta                                                                     -
123500231214//- FUNCTION....: Change the Account Type Code Data                                                -
123600231214//- EXPLANATION.: Update the data for the account type code in the Account Type (Financial Class)  -
123700231214//-               file. Before the account type code data is updated, a before and after snaphot   -
123800231214//-               of the data is made and saved to the customer Miscellaneous Codes Maintenance    -
123900231214//-               Audit file (Mxx.AUDM).                                                           -
124000231214//--------------------------------------------------------------------------------------------------
124100231214Dcl-Proc ChgAccCdeDta;
124200231214
124300231214  // Going down one level in the message queue......................................................
124400231214  MsgQNbr_Cur += 1;
124500231214
124600231214  // Make sure the record exists in the Account Type file before updating it........................
124700231214  Chain(E) (INFO_R.ATMATYPE) ATM.ATMR ATM_R;
124800231214  If %Found(ATM) and not %Error;
124900231214    Eval-Corr AudtDta1 = ATM_R;                  // File fields data structure for comparison
125000231214    Eval-Corr AudtDta2 = INFO_R;                 // Screen fields data structure for comparison
125100231214    If AudtDta2 <> AudtDta1;                     // Were changes made to the screen data
125200231214
125300231214    // Save the before and after data to the audit file before updating the record................
125400231214      WrtAudDta( MyLDA.Group : RECID : INFO_R.ATMAType : CHANGE : AudtDta1 : AudtDta2 :
125500231214                 WAD.ErrorMsg);
125600231214      If WAD.ErrorMsg <> *BLANKS;                // Issues saving the audit data?
125700231214        CPF9898.Field1 = WAD.ErrorMsg;
125800231214        SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
125900231214                   MsgQNbr_Cur : MsgKey : APIErrC);
126000231214        DataErr_89 = *ON;
126100231214      Else;                                      // No issues saving the audit data
126200231214        Eval-Corr ATM_R = INFO_R;                // Move the screen data to the file
126300231214        If INFO_R.ATMINACDT <> *ZERO;            // Date saved in file as YYYYMMDD
126400231214          ATM_R.ATMINACDT = %Dec(%Char(%Date(INFO_R.ATMINACDT:*USA):*ISO0):8:0);
126500231214        EndIf;
126600231214        ATM_R.ATMDATCHG = %Dec(%Date():*USA);    // Update date changed
126700231214        ATM_R.ATMUSRCHG = JobUser;               // Update changed by user ID
126800231214        Update ATM.ATMR ATM_R;
126900231214        CPF9898.Field1 = 'Account type code ' + INFO_R.ATMATYPE + ' updated in Account Type file';
127000231214        RtvAccTypData();                         // Refresh the screen to show the changed data
127100231214      EndIf;
127200231214    Else;
127300231214      CPF9898.Field1 = 'No changes to the data where made to account type code ' + INFO_R.ATMATYPE +
127400231214      '. No updates were done';
127500231214    EndIf;
127600231214
127700231214  ElseIF not %Found;
127800231214    CPF9898.Field1 = 'No account type code exists for ' + INFO_R.ATMATYPE +
127900231214                     ' in the Account Type file';
128000231214  Else;
128100231214    CPF9898.Field1 = 'Error occured when updating account type code ' + INFO_R.ATMATYPE +
128200231214                     ' in the Account Type file';
128300231214  EndIf;
128400231214
128500231214  // Show the action taken message..................................................................
128600231214  SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
128700231214  MsgQNbr_Cur : MsgKey : APIErrC);
128800231214
128900231214  // Going up one level in the message queue........................................................
129000231214  MsgQNbr_Cur -= 1;
129100231214
129200231214End-Proc ChgAccCdeDta;
129300231214
129400231214//--------------------------------------------------------------------------------------------------
129500231214//- SUBPROCEDURE: AddTypCdeDta                                                                     -
129600231214//- FUNCTION....: Add the Account Type Code To The Account Type (Financial Class) File             -
129700231214//- EXPLANATION.: Add the new account type code to the Account Type file. Before the account type  -
129800231214//-               code data is added, a snaphot of the data to add is made and saved to the        -
129900231214//-               customer Miscellaneous Codes Maintenance Audit file (Mxx.AUDM).                  -
130000231214//--------------------------------------------------------------------------------------------------
130100231214Dcl-Proc AddTypCdeDta;
130200231214
130300231214  // Going down one level in the message queue......................................................
130400231214  MsgQNbr_Cur += 1;
130500231214
130600231214  // Save the record to the audit file before adding the record to the Account Type file............
130700231214  Eval-Corr AudtDta1 = INFO_R;                   // Data to add is taken from the screen
130800231214  Clear AudtDta2;                                // No after snapshot of the data is needed
130900231214  WrtAudDta( MyLDA.Group : RECID : INFO_R.ATMAType : ADD : AudtDta1 : AudtDta2 : WAD.ErrorMsg);
131000231214  If WAD.ErrorMsg <> *BLANKS;                    // Issues saving the audit data?
131100231214    CPF9898.Field1 = WAD.ErrorMsg;
131200231214    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
131300231214               MsgQNbr_Cur : MsgKey : APIErrC);
131400231214    DataErr_89 = *ON;
131500231214  Else;
131600231214
131700231214    // Add the account type to the Account Type file................................................
131800231214    Clear ATM_R;
131900231214    Eval-Corr ATM_R = INFO_R;
132000231214    If ATM_R.ATMINACDT <> *ZERO;                 // Just in case this field is filled in
132100231214      ATM_R.ATMINACDT = %Dec(%Char(%Date(INFO_R.ATMINACDT:*USA):*ISO0):8:0);
132200231214    Else;
132300231214      ATM_R.ATMDATCHG = %Dec(%Date():*USA);      // Populate date created
132400231214    EndIf;
132500231214    ATM_R.ATMUSRCHG = JobUser;                   // Populate created by user ID
132600231214    Write(E) ATM.ATMR ATM_R;
132700231214    If not %Error;
132800231214      CPF9898.Field1 = 'Account type code ' + %Trim(INFO_R.ATMATYPE) +
132900231214                       ' added to the Account Type file';
133000231214      AddCode_36 = *OFF;                         // Data added, so turn add mode off
133100231214      DataAdded  = YES;                          // Allow added data to be changed
133200231214      RtvAccTypData();
133300231214    Else;
133400231214      CPF9898.Field1 = 'Error occured when adding the type code ' + %Trim(INFO_R.ATMATYPE) +
133500231214                       ' to the Account Type file';
133600231214    EndIf;
133700231214  EndIf;
133800231214
133900231214  // Show the action taken message..................................................................
134000231214  SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
134100231214  MsgQNbr_Cur : MsgKey : APIErrC);
134200231214
134300231214  // Going up one level in the message queue........................................................
134400231214  MsgQNbr_Cur -= 1;
134500231214
134600231214End-Proc AddTypCdeDta;
134700231214
134800231214//--------------------------------------------------------------------------------------------------
134900231214//- SUBPROCEDURE: CloseOpenFiles                                                                   -
135000231214//- FUNCTION....: Close Files Opened By This Program                                               -
135100231214//- EXPLANATION.: Some files were opened by this program so that the file could be overridden at   -
135200231214//-               the time it was opened. At the end of the program these files need to be closed. -
135300231214//--------------------------------------------------------------------------------------------------
135400231214Dcl-Proc CloseOpenFiles;
135500231214
135600231214  // Close the Account Type (Financial Class) file..................................................
135700231214  If %Open(ATM);
135800231214    Close(E) ATM;
135900231214  EndIf;
136000231214
136100231214  // Close the Account Type-Pay Code Changes file...................................................
136200231214  If %Open(ATP1);
136300231214    Close(E) ATP1;
136400231214  EndIf;
136500231214
136600231214End-Proc CloseOpenFiles;
136700231214
136800231214//--------------------------------------------------------------------------------------------------
136900231214// FUNCTION....: Center text within a field                                                        -
137000231214//--------------------------------------------------------------------------------------------------
137100231214/COPY QCPYSRC,F_CENTRTXT
