000100240325**free
000200240325Ctl-Opt COPYRIGHT('©EMMI Physician Service, Inc. - 2024')
000300240325DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')
000400240325OPTION(*SRCSTMT:*NODEBUGIO:*NOUNREF)
000500240325DECEDIT('0.') ExtBinInt(*YES) OPTIMIZE(*BASIC);
000600240325//*************************************************************************************************/
000700240325//                                   EMMI Physician Service, Inc.                                  /
000800240325//                                               ©2024                                             /
000900240325//*************************************************************************************************/
001000240325// CREATE DATE: 03/25/2024                                                                         /
001100240325// PROGRAMMER.: Johnny Skaggs                                                                      /
001200240325// PROGRAM....: MCM0104R                                                                           /
001300240325// SYNOPSIS...: Account Type Pay Code Changes Maintenance                                          /
001400240325// DESCRIPTION: A window that allows the addition, changing and deletion of pay codes to account   /
001500240325//              type codes. The account type conversions by pay code are unique to each customer.  /
001600240325//              The user must have authority to add, change or delete account type conversions;    /
001700240325//              otherwise, the user only has the ability to view the account type conversions.     /
001800240325//              Deletions require a confirmation step. This is accomplished by pressing F9 to      /
001900240325//              confirm the deletion. When an account type is deleted from Account Type file       /
002000240325//              (Mxx.ATM), then all of the account type conversions will be deleted from the       /
002100240325//              Account Type Pay Code Changes file (Mxx.ATP). Additions, changes and deletions     /
002200240325//              create audit records in the the customer Miscellaneous Codes Maintenance Audit     /
002300240325//              file (Mxx.AUDM). The program checks to make sure that a change was made to the     /
002400240325//              data before proceeding with changing the data, so that no unneccesary records are  /
002500240325//              written to the audit file. The F4 prompt function key is used to bring up a        /
002600240325//              window that allows for pay code and account type code searching and returning of   /
002700240325//              the desired value. The F3 exit function key was not put on the screen, because it  /
002800240325//              was felt that it might cause user fustration to exit back to the calling menu from /
002900240325//              the pop-up window.                                                                 /
003000240325//                                                                                                 /
003100240325//++++++++++++++++++++++++++++++++++++++  P R A M A T E R S  ++++++++++++++++++++++++++++++++++++++/
003200240325//      NAME      I/O                                  DESCRIPTION                                 /
003300240325// -------------- --- ---------------------------------------------------------------------------- /
003400240325//  CustCode        In  ·Group code used to identify the customer                                  /
003500240325//  PayCode         In  ·Pay code                                                                  /
003600240325//  ChgAccTyp       In  ·Change to financial class account type                                    /
003700240325//  AddChgDlt       In  ·Perform one of the following on the account type data: add/change/display /
003800240325//  RetFncKey       Out ·Function key pressed in calling program that needs to be passed back to   /
003900240325//                       the current program: F3=Exit out of all programs and back to menu         /
004000240325//  RetMsgTyp       Out ·Program message type: ERR=Error, INF=Informational, WRN=Warning           /
004100240325//  RetPgmMsg       Out ·Message returned by the program called                                    /
004200240325//                                                                                                 /
004300240325//++++++++++++++++++++++++++++++++++++++++++  F I L E S  ++++++++++++++++++++++++++++++++++++++++++/
004400240325//    NAME     OVERRIDDEN                                DESCRIPTION                               /
004500240325// ----------  ----------  ----------------------------------------------------------------------- /
004600240325// Mxx.ATM     ATM         Account Type (Financial Class) File                                     /
004700240325// Mxx.ATP1    ATP1        Account Type-Pay Code Changes File                                      /
004800240325// Mxx.PAYD    PAYD        Paycode Description File                                                /
004900240325//                                                                                                 /
005000240325//++++++++++++++++++++++++++++++++  D A T A  S T R U C T U R E S  +++++++++++++++++++++++++++++++++/
005100240325//      NAME      I/O                                  DESCRIPTION                                 /
005200240325// -------------- --- ---------------------------------------------------------------------------- /
005300240325// AuditData      Out Allows the moving of the audit data into the audit file without having to    /
005400240325//                    move each individual field.                                                  /
005500240325// AudtDta1       I/O Used to store the file data that corresponds to the screen data. This allows /
005600240325//                    the comparison of the screen data to the file data to see if it changed.     /
005700240325// AudtDta2       I/O Used to store the screen data that corresponds to the file data.             /
005800240325// DataIn         In  Allows the data to be retrieved from the input file by the SQL processing.   /
005900240325// MyLDA          In  Holds the data that is read in from the Local Data Area (LDA).               /
006000240325// WSInd          In  Since INDARA is used in the display file, mapping of the indicators must be  /
006100240325//                    done  in the program.  The indicators for the display are now accessed using /
006200240325//                    the  data structure. Turning on an indicator in the data structure will not  /
006300240325//                    turn on the corresponding *INxx indicator.                                   /
006400240325//                                                                                                 /
006500240325//+++++++++++++++++++++++++++++++++++++  C O N S T A N T S   ++++++++++++++++++++++++++++++++++++++/
006600240325//      NAME                                          DESCRIPTION                                  /
006700240325// --------------   ------------------------------------------------------------------------------ /
006800240325// ACCTYPELU      - Perform a data lookup on the account type code                                 /
006900240325// ADD            - Add a record to the miscellaneous codes maintenance file                       /
007000240325// CHANGE         - Change a record in the miscellaneous codes maintenance file                    /
007100240325// DELETE         - Delete a record fromthe miscellaneous codes maintenance file                   /
007200240325// ERROR          - Error message being returned to calling program                                /
007300240325// INFORM         - Infomrational message being returned to calling program                        /
007400240325// PAYCODELU      - Perform a data lookup on the pay code                                          /
007500240325// RECID          - Record identification                                                          /
007600240325// WARNING        - Warning message being returned to calling program                              /
007700240325// YES            - Replacement for Y                                                              /
007800240325//                                                                                                 /
007900240325//++++++++++++++++++++++++++++++++++++++  V A R I A B L E S  ++++++++++++++++++++++++++++++++++++++/
008000240325//      NAME                                          DESCRIPTION                                  /
008100240325// --------------   ------------------------------------------------------------------------------ /
008200240325// AccTypF        - Override Mxx.ATM to this account type file name                                /
008300240325// AcTyPyCdF      - Override Mxx.ATP1 to this account type to pay code changes by type file name   /
008400240325// CompanyName    - Name of the company who's data is being presented                              /
008500240325// PayCdeF        - Override Mxx.PAYD to this paycode description file name                        /
008600240325// SavRRN1        - Save of the main display relative record number                                /
008700240325// SFIdx          - Counter used to retrieve data from the subfile display records                 /
008800240325// ShowScreen     - Keeps track of what record format the screen is showing                        /
008900240325//                                                                                                 /
009000240325//++++++++++++++++++++  F U N C T I O N  K E Y S  A N D  I N D I C A T O R S  +++++++++++++++++++++/
009100240325//     NAME                                         DESCRIPTION                                    /
009200240325// ----------   ---------------------------------------------------------------------------------- /
009300240325// F1_Help    - Context sensitive help                                                             /
009400240325// F4_Prompt  - Prompt the field to show data selection window                                     /
009500240325// F9_CfrmDlt - Confirm delete of pay code change to account type code data                        /
009600240325// F12_Cancel - Cancel current action and return to previous screen                                /
009700240325// SFNxChg_25 - Mark subfile field as changed (SFLNXTCHG)                                          /
009800240325// ProtFld_28 - Protect the field from changes                                                     /
009900240325// InzSubF_29 - Initailze subfile (SFLINZ)                                                         /
010000240325// ClrSubF_30 - Subfile clear (SFLCLR)                                                             /
010100240325// DspCtlR_31 - Subfile Display Control (SFLDSPCTL)                                                /
010200240325// AddCode_36 - Add a new accounting type code                                                     /
010300240325// InactDt_37 - Account inactive date                                                              /
010400240325// SubFEnd_39 - Display subfile more/bottom                                                        /
010500240325// PayCode_40 - Pay code error                                                                     /
010600240325// AccType_41 - Account type error                                                                 /
010700240325// DataErr_89 - Data error found                                                                   /
010800240325//                                                                                                 /
010900240325//+++++++++++++++++++++++++++++++++  M O D I F I C A T I O N S  +++++++++++++++++++++++++++++++++++/
011000240325// DATE..: MM/DD/CCYY   PROGRAMMER: First and last name                                            /
011100240325// REASON: Project number or ticket number                                                         /
011200240325// MODS..: What changes were made to the program                                                   /
011300240325//*************************************************************************************************/
011400240325
011500240325
011600240325// Passed parameters when called from MCM0102R......................................................
011700240325Dcl-PI *n;
011800240325  CustCode  Char( 2) Const;
011900240325  AccTypCde Char( 2) Const;
012000240325  PayCode   Char( 2) Const;
012100240325  ChgAccTyp Char( 2) Const;
012200240325  AddChgDlt Char( 3) Const;
012300240325  ExitAdd   Char( 1);
012400240325  RetMsgTyp Char( 3);
012500240325  RetPgmMsg Char(78);
012600240325End-PI;
012700240325
012800240325// Declare, override and open files.................................................................
012900240325Dcl-F ATM  Disk Keyed Usage(*INPUT) ExtDesc('MXX.ATM') ExtFile(AccTypF) UsrOpn;
013000240325Dcl-F ATP1 Disk Keyed Usage(*DELETE:*OUTPUT) ExtDesc('MXX.ATP1') ExtFile(AcTyPyCdF) UsrOpn;
013100240325Dcl-F PAYD Disk Keyed Usage(*INPUT) ExtDesc('MXX.PAYD') ExtFile(PayCdeF) UsrOpn;
013200240325Dcl-F DSP  WorkStn Qualified ExtDesc('MCM0104D') ExtFile(*ExtDesc) InDDS(WsInd);
013300240325
013400240325// Data structure templates to deifine record formats...............................................
013500240325Dcl-DS MSGC_T LikeRec(DSP.MSGCTL    :*All) Template;
013600240325Dcl-DS WDW_T  LikeRec(DSP.PAYCDEWDW :*All) Template;
013700240325
013800240325// Like data structures used for the reading and writing of data....................................
013900240325Dcl-DS MSGC_R LikeDS(MSGC_T);          // Error message screen format
014000240325Dcl-DS WDW_R  LikeDS(WDW_T );          // Add/Delete pay code window
014100240325
014200240325// Functions keys and indicators data structure.....................................................
014300240325Dcl-DS WsInd Len(99);
014400240325  FuncKeyInd Char(24) Pos(01);         // Function key indicators...................................
014500240325    F4_Prompt  Ind Pos(04);            // Prompt the field to show data selection window
014600240325    F9_CfrmDlt Ind Pos(09);            // Comfirm the delete of the account type data record
014700240325    F12_Cancel Ind Pos(12);            // Cancel
014800240325  ScreenInd  Char(15) Pos(25);         // Screen manipulation indicators............................
014900240325    ProtFld_28 Ind Pos(28);            // Protect the field(s) from being changed
015000240325    ProtWdw_35 Ind Pos(35);            // Protect window fields from being changed
015100240325    AddCode_36 Ind Pos(36);            // Add a new change account type to based on pay code
015200240325  FldErrInd  Char(50) Pos(40);         // Error indicators..........................................
015300240325    PayCode_41 Ind Pos(41);            // Pay code error
015400240325    AccType_42 Ind Pos(42);            // Account type code error
015500240325    DataErr_89 Ind Pos(89);            // Data error found
015600240325  ProgramInd Char(10) Pos(90);         // Program flow indicators...................................
015700240325End-DS WsInd;
015800240325
015900240325// Audit data to save data structure................................................................
016000240325Dcl-DS AuditData Qualified;
016100240325  ATPAType  Like(ATPATYPE );           // Account type code
016200240325  ATMADesc  Like(ATMADESC );           // Account type description
016300240325  ATPPayCd  Like(ATPPAYCD );           // Pay code
016400240325  PADesc    Like(PADESC   );           // Pay code description
016500240325  ATPChgTyp Like(ATPCHGTYP);           // Change to account type
016600240325  ChgTypDsc Like(ATMADESC );           // Change to account type description
016700240325  ATPDatChg Char(8        );           // Last change date
016800240325  ATPUsrChg Like(ATPUSRCHG);           // Last change user
016900240325End-DS AuditData;
017000240325
017100240325// Like data structures used to see if the data has changed.........................................
017200240325Dcl-DS AudtDta1 LikeDS(AuditData) Inz;
017300240325Dcl-DS AudtDta2 LikeDS(AuditData) Inz;
017400240325
017500240325// Declare data structre for reading in the Local Data Area (LDA)...................................
017600240325Dcl-DS MyLDA DtaAra(*LDA) Qualified;
017700240325  Entity   Char(3)  Pos(137);          // Used to open the correct account type file
017800240325  Group    Char(2)  Pos(138);          // Used as key to lookup customer information
017900240325  DeviceID Char(2)  Pos(494);          // Last two characters of device name
018000240325  UserID   Char(10) Pos(496);          // User identification of person running the job
018100240325  Customer Char(50) Pos(951);          // Customer company name
018200240325End-DS;
018300240325
018400240325// Declare constatnts...............................................................................
018500240325Dcl-C ACCTYPELU Const('ACC');
018600240325Dcl-C ADD       Const('ADD');
018700240325Dcl-C CHANGE    Const('CHG');
018800240325Dcl-C DELETE    Const('DLT');
018900240325Dcl-C ERROR     Const('ERR');
019000240325Dcl-C INFORM    Const('INF');
019100240325Dcl-C RECID     Const('01');
019200240325Dcl-C PAYCODELU Const('PAY');
019300240325Dcl-C WARNING   Const('WRN');
019400240325Dcl-C YES       Const('Y');
019500240325
019600240325// Declare variables...............................................................................
019700240325Dcl-S AccTypF   Char(10) Inz;
019800240325Dcl-S AcTyPyCdF Char(10) Inz;
019900240325Dcl-S PayCdeF   Char(10) Inz;
020000240325
020100240325// Prototype-Lookup the financial class account type from the Account Type file.....................
020200240325/COPY QCPYSRC,D_ACCTYPLU
020300240325
020400240325// Data structure-Contains any API interface errors.................................................
020500240325/COPY QCPYSRC,D_APIErrDS
020600240325
020700240325// Prototype-Lookup the pay code from the Pay Code Description file.................................
020800240325/COPY QCPYSRC,D_PAYCDELU
020900240325
021000240325// Prototype-Send program message and clear program message queue...................................
021100240325/COPY QCPYSRC,D_PGMMSGS
021200240325
021300240325// Data structure-Contains the program information..................................................
021400240325/COPY QCPYSRC,D_PGMSTSDS
021500240325
021600240325// Constants-Human readable form for the program message identifiers................................
021700240325/COPY QCPYSRC,D_PMSGIDS
021800240325
021900240325// Prototype-Write the audit data to the correct audit file.........................................
022000240325/COPY QCPYSRC,D_WRTAUDTA
022100240325
022200240325//**************************************************************************************************
022300240325//************************************  M A I N  P R O G R A M  ************************************
022400240325//**************************************************************************************************
022500240325
022600240325// Stuff that only needs to be done once when the program is first run..............................
022700240325ProgramEntry();
022800240325
022900240325// Process the screen until F12 is set on............................................................
023000240325DoU F12_Cancel;
023100240325
023200240325  // Display the correct screen.....................................................................
023300240325  Write DSP.MSGCTL MSGC_R;
023400240325  ExFmt DSP.PAYCDEWDW WDW_R;
023500240325
023600240325  // Reset the error indicators and clear out any previously displayed messages.....................
023700240325  FldErrInd = *OFF;
023800240325  ClrMsgQ( MsgQ_Cur : MsgQNbr_Cur : MsgKey_All :  MsgRmv_All : APIErrC );
023900240325
024000240325  // F4 - Process prompt request for information lookup.............................................
024100240325  Select;
024200240325  When F4_Prompt;
024300240325    If WDW_R.WdwFld = 'WDWPAYCDE';
024400240325      ProcPrompt( PAYCODELU );
024500240325    ElseIf WDW_R.WdwFld = 'WDWACCTYP';
024600240325      ProcPrompt( ACCTYPELU );
024700240325    Else;
024800240325      CPF9898.Field1 = 'The location of your cursor does not allow for prompting';
024900240325      SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
025000240325                 MsgQNbr_Cur : MsgKey : APIErrC );
025100240325      DataErr_89  = *ON;
025200240325    EndIf;
025300240325
025400240325  // F12 - Go back to previous screen...............................................................
025500240325  When F12_Cancel;
025600240325    ExitAdd = YES;
025700240325    Leave;
025800240325
025900240325  // Enter - Process the different screens if the user has the permissions to modify the data.......
026000240325  Other;
026100240325    If ProtFld_28 = *OFF;                        // User can modify data
026200240325      ProcessScreen();
026300240325    Else;                                        // Added in the unlikely case this happens
026400240325      CPF9898.Field1 = 'You do not have authority to add/change/delete the data';
026500240325      SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
026600240325                 MsgQNbr_Cur : MsgKey : APIErrC );
026700240325      DataErr_89  = *ON;
026800240325    EndIf;
026900240325  EndSL;
027000240325
027100240325EndDo;                                           // DoU F3_Exit
027200240325
027300240325// Close files that were opened by this program.....................................................
027400240325CloseOpenFiles();
027500240325
027600240325//--------------------------------------------------------------------------------------------------
027700240325//- SUBPROCEDURE: ProgramEntry                                                                     -
027800240325//- FUNCTION....: Tasks Done When The Prorgam Is First Run                                         -
027900240325//- EXPLANATION.: Process all of the tasks that only need to done when the program is first run.   -
028000240325//-               Such as, getting user privileges, opening files, initializing variables, etc.    -
028100240325//--------------------------------------------------------------------------------------------------
028200240325Dcl-Proc ProgramEntry;
028300240325
028400240325  // Set program name for error message screen and initialize the error message screen..............
028500240325  *INLR = *ON;
028600240325  MSGC_R.PGMNAME = PgmName;                      // Required because of screen record format DS
028700240325  ClrMsgQ( MsgQ_Cur : MsgQNbr_Cur : MsgKey_All :  MsgRmv_All : APIErrC );
028800240325
028900240325  // Set the window title based upon what is being done to the data.................................
029000240325  If AddChgDlt = *BLANKS;                      // This should not happen, but is here just in case
029100240325    ProtFld_28 = *ON;                          // Do not allow editing of pay code data
029200240325    WDW_R.WdwTitle = 'Pay Code to Account Type Code';
029300240325    WDW_R.WdwTitle = CenterText(WDW_R.WdwTitle);
029400240325    CPF9898.Field1 = 'Add/Change/Delete not passed, so data is protected from modifications';
029500240325    SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
029600240325               MsgQNbr_Cur : MsgKey : APIErrC );
029700240325    DataErr_89  = *ON;
029800240325  ElseIf AddChgDlt = ADD;
029900240325    AddCode_36 = *ON;
030000240325    WDW_R.WdwTitle = CenterText('New Pay Code to Account Type Code');
030100240325  ElseIf AddChgDlt = CHANGE;
030200240325    WDW_R.WdwTitle = 'Change Account Type Code for Pay Code';
030300240325    WDW_R.WdwTitle = CenterText(WDW_R.WdwTitle);
030400240325  ElseIf AddChgDlt = DELETE;
030500240325    ProtWdw_35 = *ON;
030600240325    WDW_R.WdwTitle = CenterText('Delete Pay Code to Account Type Code');
030700240325  EndIf;
030800240325
030900240325  // Open the files with the appropriate name.......................................................
031000240325  If CustCode <> *BLANKS;
031100240325    MyLDA.Entity = 'M' + CustCode;
031200240325  Else;
031300240325    In MyLDA;
031400240325  EndIf;
031500240325
031600240325  // Open the files with the appropriate name.......................................................
031700240325  If %Len(%Trim(MyLDA.Entity)) = 3;
031800240325    AccTypF = MyLDA.Entity + '.ATM';
031900240325    If not %Open(ATM);
032000240325      Open(E) ATM;
032100240325      If %Error;
032200240325        CPF9898.Field1 = 'The program could not open the file ' + AccTypF + '. Contact IT for help';
032300240325        SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
032400240325                   MsgQNbr_Cur : MsgKey : APIErrC );
032500240325        DataErr_89 = *ON;
032600240325      EndIf;
032700240325    EndIf;
032800240325
032900240325    AcTyPyCdF = MyLDA.Entity + '.ATP1';
033000240325    If not %Open(ATP1);
033100240325      Open(E) ATP1;
033200240325      If %Error;
033300240325        CPF9898.Field1 = 'The program could not open the file ' + AcTyPyCdF + '. Contact IT for help';
033400240325        SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
033500240325                   MsgQNbr_Cur : MsgKey : APIErrC );
033600240325        DataErr_89 = *ON;
033700240325      EndIf;
033800240325    EndIf;
033900240325
034000240325    PayCdeF = MyLDA.Entity + '.PAYD';
034100240325    If not %Open(PAYD);
034200240325      Open(E) PAYD;
034300240325      If %Error;
034400240325        CPF9898.Field1 = 'The program could not open the file ' + PayCdeF + '. Contact IT for help';
034500240325        SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
034600240325                   MsgQNbr_Cur : MsgKey : APIErrC );
034700240325        DataErr_89 = *ON;
034800240325      EndIf;
034900240325    EndIf;
035000240325
035100240325  Else;
035200240325    CPF9898.Field1 = 'Cannot open any files because of invalid file prefix. Contact IT for help';
035300240325    SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
035400240325               MsgQNbr_Cur : MsgKey : APIErrC );
035500240325    DataErr_89 = *ON;
035600240325  EndIf;
035700240325
035800240325  // Retrieve the pay code data for the account type code...........................................
035900240325  If not DataErr_89;
036000240325
036100240325    WDW_R.WDWPayCde = PayCode;
036200240325    Chain(E) (PayCode) PAYDR;                    // Retrieve the pay code description
036300240325    If %Found and not %Error;
036400240325      WDW_R.WDWPyCdDsc = PADesc;
036500240325    EndIf;
036600240325
036700240325    AudtDta1.ATPAType = AccTypCde;               // Audit account type code data will not change
036800240325    AudtDta2.ATPAType = AccTypCde;
036900240325    Chain(E) (AccTypCde) ATMR;                   // Retrieve the account type code description
037000240325    If %Found and not %Error;
037100240325      AudtDta1.ATMADesc = ATMADesc;              // Audit account type code desc data will not chg
037200240325      AudtDta2.ATMADesc = ATMADesc;
037300240325    EndIf;
037400240325
037500240325    WDW_R.WDWAccTyp = ChgAccTyp;
037600240325    Chain(E) (ChgAccTyp) ATMR;                   // Retrieve the change account type code desc
037700240325    If %Found and not %Error;
037800240325      WDW_R.WDWAcTyDsc = ATMADesc;
037900240325    EndIf;
038000240325
038100240325  EndIf;
038200240325
038300240325End-Proc ProgramEntry;
038400240325
038500240325//--------------------------------------------------------------------------------------------------
038600240325//- SUBPROCEDURE: ProcPrompt                                                                       -
038700240325//- FUNCTION....: Process The F4 Prompt Command                                                    -
038800240325//- EXPLANATION.: Disply the correct lookup window based upon what field the cursor was in when    -
038900240325//-               the prompt key was pressed.  The account type code and the pay code can be       -
039000240325//-               prompted. If a code is passed back, then move it to the correct field.           -
039100240325//- - - - - - - - - - - - - - - - - -   P A R A M E T E R S  - - - - - - - - - - - - - - - - - - - -
039200240325//      Name      I/O                                  Description                                 -
039300240325// -------------- --- ---------------------------------------------------------------------------- -
039400240325//- LookUp        In  What kind of data lookup needs to be done (account code or pay code)         -
039500240325//--------------------------------------------------------------------------------------------------
039600240325Dcl-Proc ProcPrompt;
039700240325  Dcl-PI *n;
039800240325    Lookup Char(9) Value;
039900240325  End-PI;
040000240325
040100240325  // Account type code lookup.......................................................................
040200240325  If Lookup = ACCTYPELU;
040300240325    AccTypLkUp( MyLDA.Group : AT.AcctType : AT.AccTypDsc : AT.ErrorMsg );
040400240325    If AT.AcctType <> *BLANKS and AT.ErrorMsg = *BLANKS;
040500240325      WDW_R.WdwAccTyp  = AT.AcctType;
040600240325      WDW_R.WdwAcTyDsc = AT.AccTypDsc;
040700240325    ElseIf AT.ErrorMsg <> *BLANKS;
040800240325      CPF9898.Field1 = AT.ErrorMsg;
040900240325      SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
041000240325                 MsgQNbr_Cur : MsgKey : APIErrC );
041100240325      DataErr_89  = *ON;
041200240325    EndIf;
041300240325
041400240325  // Pay code lookup................................................................................
041500240325  ElseIf Lookup = PAYCODELU;
041600240325    PayCdeLkUp( MyLDA.Group : PC.PayCode : PC.PayCdeDsc : PC.ErrorMsg );
041700240325    If PC.PayCode <> *BLANKS and PC.ErrorMsg = *BLANKS;
041800240325      WDW_R.WdwPayCde  = PC.PayCode;
041900240325      WDW_R.WdwPyCdDsc = PC.PayCdeDsc;
042000240325    ElseIf PC.ErrorMsg <> *BLANKS;
042100240325      CPF9898.Field1 = PC.ErrorMsg;
042200240325      SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
042300240325                 MsgQNbr_Cur : MsgKey : APIErrC );
042400240325      DataErr_89  = *ON;
042500240325    EndIf;
042600240325  EndIf;
042700240325
042800240325
042900240325End-Proc ProcPrompt;
043000240325
043100240325//--------------------------------------------------------------------------------------------------
043200240325//- SUBPROCEDURE: ProcessScreen                                                                    -
043300240325//- FUNCTION....: Process The Screen                                                               -
043400240325//- EXPLANATION.: Determine what needs to happen next from what was entered on the screen or what  -
043500240325//-               key was pressed. When adding a new record the pay code and account type code     -
043600240325//-               · ADD - When adding a new record the pay code and account type code have to be   -
043700240325//-                       filled in.                                                               -
043800240325//-               · CHANGE - When changing a pay code to account type code, only the account type  -
043900240325//-                       code can be changed. To change the pay code you must add a new pay code  -
044000240325//-                       to account type code record, and delete the current pay code to account  -
044100240325//-                       type code if it is no longer valid.                                      -
044200240325//-               · DELETE - When deleting a pay code to account type code record, the user must   -
044300240325//-                       press the F9 function key to delete the record.                          -
044400240325//-               After changing or deleting data the screen will return to the previous screen so -
044500240325//-               that another record can be changed or deleted. After adding data, the screen     -
044600240325//-               will stay in the current window until F12 is pressed, so that the user can enter -
044700240325//-               multiple pay codes to account type codes quickly in succession.                  -
044800240325//--------------------------------------------------------------------------------------------------
044900240325Dcl-Proc ProcessScreen;
045000240325
045100240325  // Going down one level in the message queue......................................................
045200240325  MsgQNbr_Cur += 1;
045300240325
045400240325  // Process the account type add/change/delete window..............................................
045500240325  If AddCode_36 = *ON;
045600240325    VldAcTyPyCdDta();
045700240325    If DataErr_89 = *OFF;
045800240325      AddAcTyPyCdDta();                          // Add data to the Account Type Pay Code Chngs File
045900240325    EndIf;
046000240325  ElseIf F9_CfrmDlt = *ON;
046100240325    Chain(E) (AccTypCde : WDW_R.WdwPayCde) ATPR;
046200240325    If %FOUND and not %ERROR;
046300240325      DltAcTyPyCdDta();                          // Delete data from the Acct Type Pay Cde Chgs File
046400240325    EndIf;
046500240325  Else;
046600240325    VldAcTyPyCdDta();
046700240325    If DataErr_89 = *OFF;
046800240325      ChgAcTyPyCdDta();                          // Update data in the Acct Type Pay Code Chngs File
046900240325    EndIf;
047000240325  EndIf;
047100240325
047200240325  // Going up one level in the message queue........................................................
047300240325  MsgQNbr_Cur -= 1;
047400240325
047500240325End-Proc ProcessScreen;
047600240325
047700240325//--------------------------------------------------------------------------------------------------
047800240325//- SUBPROCEDURE: VldAcTyPyCdDta                                                                   -
047900240325//- FUNCTION....: Validate Changes Made To The Account Type Pay Code Changes Data                  -
048000240325//- EXPLANATION.: Check the data entered to make sure that it is valid before changes or additions -
048100240325//-               are made to the file.                                                            -
048200240325//--------------------------------------------------------------------------------------------------
048300240325Dcl-Proc VldAcTyPyCdDta;
048400240325
048500240325  // Going down one level in the message queue......................................................
048600240325  MsgQNbr_Cur += 1;
048700240325
048800240325  // See if the account type code and pay code combination already exist in the file................
048900240325  If AddCode_36 = *ON;
049000240325    SetLL(E) (AccTypCde : WDW_R.WdwPayCde) ATPR;
049100240325    If %Equal and not %Error;
049200240325      ERR0029.Field1 = AccTypCde + ' and ' + WDW_R.WdwPayCde;
049300240325      ERR0029.Field2 = AcTyPyCdF;
049400240325      SndPgmMsg( Err_KeyValu : MsgFile_Dft : Err0029 : %Len(Err0029) : MsgTy_Diag : MsgQ_Cur :
049500240325                 MsgQNbr_Cur : MsgKey : APIErrC );
049600240325      PayCode_41 = *ON;
049700240325      DataErr_89 = *ON;
049800240325    ElseIf %Error;
049900240325      CPF9898.Field1 = 'Issues checking the existance of the key in ' + %Trim(AcTyPyCdF);
050000240325      SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
050100240325                 MsgQNbr_Cur : MsgKey : APIErrC );
050200240325      DataErr_89 = *ON;
050300240325    EndIf;
050400240325  EndIf;
050500240325
050600240325  // Validate pay code and populate pay code description.....................................
050700240325  Chain(E) (WDW_R.WdwPayCde) PAYDR;
050800240325  If %Found and not %Error;
050900240325    WDW_R.WdwPyCdDsc = PADesc;
051000240325  ElseIf not %Found and not %Error;
051100240325    ERR0036.Field1 = 'Paycode Description';
051200240325    SndPgmMsg( Err_NotInFl : MsgFile_Dft : Err0036 : %Len(Err0036) : MsgTy_Diag : MsgQ_Cur :
051300240325               MsgQNbr_Cur : MsgKey : APIErrC );
051400240325    PayCode_41 = *ON;
051500240325    DataErr_89 = *ON;
051600240325  ElseIf %Error;
051700240325    CPF9898.Field1 = 'Issues checking the existance of the pay code in ' + %Trim(PayCdeF);
051800240325    SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
051900240325               MsgQNbr_Cur : MsgKey : APIErrC );
052000240325    DataErr_89 = *ON;
052100240325  Else;
052200240325    Clear WDW_R.WdwPyCdDsc;
052300240325  EndIf;
052400240325
052500240325  // Validate the account type code and populate the account type description.......................
052600240325  Chain(E) (WDW_R.WdwAccTyp) ATMR;
052700240325  If %Found and not %Error;
052800240325    WDW_R.WdwAcTyDsc = ATMADesc;
052900240325  ElseIf not %Found and not %Error;
053000240325    ERR0036.Field1 = 'Account Type Description';
053100240325    SndPgmMsg( Err_NotInFl : MsgFile_Dft : Err0036 : %Len(Err0036) : MsgTy_Diag : MsgQ_Cur :
053200240325               MsgQNbr_Cur : MsgKey : APIErrC );
053300240325    AccType_42 = *ON;
053400240325    DataErr_89 = *ON;
053500240325  ElseIf %Error;
053600240325   CPF9898.Field1 = 'Issues checking the existance of the account type in ' + %Trim(AccTypF);
053700240325    SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
053800240325               MsgQNbr_Cur : MsgKey : APIErrC );
053900240325    DataErr_89 = *ON;
054000240325  Else;
054100240325    Clear WDW_R.WdwPyCdDsc;
054200240325  EndIf;
054300240325
054400240325  // The account type change to code cannot be the same as the account type code....................
054500240325  If WDW_R.WdwAccTyp = AccTypCde;
054600240325    SndPgmMsg( Err_AcTyCdM : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag : MsgQ_Cur :
054700240325               MsgQNbr_Cur : MsgKey : APIErrC );
054800240325    AccType_42 = *ON;
054900240325    DataErr_89 = *ON;
055000240325  EndIf;
055100240325
055200240325  // Going up one level in the message queue........................................................
055300240325  MsgQNbr_Cur -= 1;
055400240325
055500240325End-Proc VldAcTyPyCdDta;
055600240325
055700240325//--------------------------------------------------------------------------------------------------
055800240325//- SUBPROCEDURE: ChgAcTyPyCdDta                                                                   -
055900240325//- FUNCTION....: Change The Account Type Code Associated With The Pay Code                        -
056000240325//- EXPLANATION.: Allow the changing of the account type code associated with the pay code. When   -
056100240325//-               making a change, the pay code is a protected field and cannot be edited, only    -
056200240325//-               the account type code can be changed. A before and after snapshot of the data    -
056300240325//-               is saved to the customer Miscellanous Codes Maintenance Audit File.              -
056400240325//--------------------------------------------------------------------------------------------------
056500240325Dcl-Proc ChgAcTyPyCdDta;
056600240325
056700240325  // Going down one level in the message queue......................................................
056800240325  MsgQNbr_Cur += 1;
056900240325
057000240325  // Retrieve the account type pay code change data from the Account Type Pay Code Changes file and
057100240325  // populate the file comparison data structure....................................................
057200240325  Chain(E) (AccTypCde : WDW_R.WDWPayCde) ATPR;
057300240325  If %Found and not %Error;
057400240325
057500240325    AudtDta1.ATPPayCd = ATPPAYCD;                // Pay code from file
057600240325    Chain(E) (ATPPAYCD) PAYDR;                   // Retrieve the pay code description
057700240325    If %Found and not %Error;
057800240325      AudtDta1.PADesc = PADesc;
057900240325    EndIf;
058000240325
058100240325    AudtDta1.ATPChgTyp   = ATPChgTyp;            // Change account type code from file
058200240325    Chain(E) (ATPChgTyp) ATMR;                   // Retrieve the change account type code desc
058300240325    If %Found and not %Error;
058400240325      AudtDta1.ChgTypDsc = ATMADesc;
058500240325    EndIf;
058600240325
058700240325    AudtDta1.ATPDatChg = %Char(ATPDatChg);       // Get from file for both the before and after so
058800240325    AudtDta1.ATPUsrChg = ATPUsrChg;              // it can be part of the audit data
058900240325  ElseIf not %Found;
059000240325    CPF9898.Field1 = 'Acct type code/pay code does not exist in the Acct Type Pay Code Chgs' +
059100240325                     ' file';
059200240325    DataErr_89 = *ON;
059300240325  ElseIf %Error;
059400240325    CPF9898.Field1 = 'Error retrieving ' + %Trim(AudtDta1.ATPAType) +
059500240325                     ' codes from the Acct Type Pay Code Chgs file';
059600240325    DataErr_89 = *ON;
059700240325  EndIf;
059800240325
059900240325  // Populate the screen comparison datastructure from the screen account type data.................
060000240325  If DataErr_89 = *OFF;
060100240325    AudtDta2.ATPPayCd  = WDW_R.WdwPayCde;
060200240325    AudtDta2.PADesc    = WDW_R.WDWPyCdDsc;
060300240325    AudtDta2.ATPChgTyp = WDW_R.WDWAccTyp;
060400240325    AudtDta2.ChgTypDsc = WDW_R.WDWAcTyDsc;
060500240325    AudtDta2.ATPDatChg = %Char(ATPDatChg);       // Used for both before and after data comparison
060600240325    AudtDta2.ATPUsrChg = ATPUsrChg;              // for audit data
060700240325
060800240325    // If the data has changed, then write create an audit file entry update Account Type file......
060900240325    If AudtDta1 <> AudtDta2;
061000240325      WrtAudDta( MyLDA.Group : RECID : AudtDta1.ATPAType : CHANGE : AudtDta1 : AudtDta2 :
061100240325                 WAD.ErrorMsg );
061200240325      If WAD.ErrorMsg <> *BLANKS;
061300240325        CPF9898.Field1 = WAD.ErrorMsg;
061400240325        SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
061500240325                   MsgQNbr_Cur : MsgKey : APIErrC );
061600240325        DataErr_89 = *ON;
061700240325      Else;
061800240325        ATPChgTyp = WDW_R.WdwAccTyp;
061900240325        ATPDatChg = %Dec(%Date():*USA);
062000240325        ATPUsrChg = JobUser;
062100240325        Update ATPR;
062200240325        RetMsgTyp = INFORM;
062300240325        RetPgmMsg = 'Change account type to code for pay code ' + %Trim(WDW_R.WdwPayCde) +
062400240325                    ' updated to ' + %Trim(WDW_R.WdwAccTyp);
062500240325        F12_Cancel = *ON;
062600240325      EndIf;
062700240325    Else;
062800240325      CPF9898.Field1 = 'No data changes where made to account type code ' +
062900240325                       %Trim(AudtDta1.ATPAType) + ' and pay code ' + %Trim(WDW_R.WdwPayCde);
063000240325      SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
063100240325                 MsgQNbr_Cur : MsgKey : APIErrC );
063200240325    EndIf;
063300240325  EndIf;
063400240325
063500240325  // Going up one level in the message queue........................................................
063600240325  MsgQNbr_Cur -= 1;
063700240325
063800240325End-Proc ChgAcTyPyCdDta;
063900240325
064000240325//--------------------------------------------------------------------------------------------------
064100240325//- SUBPROCEDURE: AddAcTyPyCdDta                                                                   -
064200240325//- FUNCTION....: Add Pay Code Change To Account Type Code Data To The File                        -
064300240325//- EXPLANATION.: For the account type add a pay code change to account type code to the Account   -
064400240325//-               Type Pay Code Changes file. Audit data is written to the customer Miscellaneous  -
064500240325//-               Codes Maintenance Audit File for each record that is added to the file. After    -
064600240325//-               each add the screen will return to the add screen, so that a number of adds can  -
064700240325//-               be done in a row, without having to press the F6 function key each time.         -
064800240325//--------------------------------------------------------------------------------------------------
064900240325Dcl-Proc AddAcTyPyCdDta;
065000240325
065100240325  // Going down one level in the message queue......................................................
065200240325  MsgQNbr_Cur += 1;
065300240325
065400240325  // Save the record to the audit file before adding the record to the Account Type file............
065500240325  Clear AudtDta2;
065600240325  AudtDta1.ATPPayCd  = WDW_R.WdwPayCde;
065700240325  AudtDta1.PADesc    = WDW_R.WDWPyCdDsc;
065800240325  AudtDta1.ATPChgTyp = WDW_R.WDWAccTyp;
065900240325  AudtDta1.ChgTypDsc = WDW_R.WDWAcTyDsc;
066000240325  AudtDta1.ATPDatChg = %Char(%Dec(%Date():*USA));
066100240325  AudtDta1.ATPUsrChg = JobUser;
066200240325
066300240325  WrtAudDta( MyLDA.Group : RECID : AudtDta1.ATPAType : ADD : AudtDta1 : AudtDta2 : WAD.ErrorMsg );
066400240325  If WAD.ErrorMsg <> *BLANKS;
066500240325    CPF9898.Field1 = WAD.ErrorMsg;
066600240325    SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
066700240325               MsgQNbr_Cur : MsgKey : APIErrC );
066800240325    DataErr_89 = *ON;
066900240325
067000240325  // Add the pay code to account type change data to the Account Type Pay Code Changes file.........
067100240325  Else;
067200240325    ATPAType  = AudtDta1.ATPAType;
067300240325    ATPChgTyp = WDW_R.WdwAccTyp;
067400240325    ATPPayCd  = WDW_R.WdwPayCde;
067500240325    ATPDatChg = %Dec(%Date():*USA);
067600240325    ATPUsrChg = JobUser;
067700240325    Write(E) ATPR;
067800240325    If not %Error;
067900240325      CPF9898.Field1 = 'Pay code ' + %Trim(WDW_R.WdwPayCde) + ' change to acct type ' +
068000240325                       %Trim(WDW_R.WdwAccTyp) + ' added to the Acct Type Pay Code Chgs file';
068100240325      F12_Cancel = *ON;
068200240325    Else;
068300240325      CPF9898.Field1 = 'Error adding the pay cde ' + %Trim(WDW_R.WdwPayCde) + ' chg to acct type ' +
068400240325                       %Trim(WDW_R.WdwAccTyp) + ' to Acct Type Pay Cde Chgs file';
068500240325    EndIf;
068600240325  EndIf;
068700240325
068800240325  // Show the action taken message..................................................................
068900240325  SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
069000240325  MsgQNbr_Cur : MsgKey : APIErrC );
069100240325
069200240325  // Going up one level in the message queue........................................................
069300240325  MsgQNbr_Cur -= 1;
069400240325
069500240325End-Proc AddAcTyPyCdDta;
069600240325
069700240325//--------------------------------------------------------------------------------------------------
069800240325//- SUBPROCEDURE: DltAcTyPyCdDta                                                                   -
069900240325//- FUNCTION....: Delete the Pay Code Change To Account Type Code Record From The File             -
070000240325//- EXPLANATION.: From the Account Type file, remove the pay code change to account type code      -
070100240325//-               record. Audit data is written to the customer Miscellaneous Codes Maintenance    -
070200240325//-               Audit file for each record that is deleted from the Account Type Pay Code        -
070300240325//-               Changes file.                                                                    -
070400240325//--------------------------------------------------------------------------------------------------
070500240325Dcl-Proc DltAcTyPyCdDta;
070600240325
070700240325  // Going down one level in the message queue......................................................
070800240325  MsgQNbr_Cur += 1;
070900240325
071000240325  // Save the record to the audit file before deleting the record from the file.....................
071100240325  Clear AudtDta2;
071200240325  AudtDta1.ATPPayCd  = WDW_R.WdwPayCde;
071300240325  AudtDta1.PADesc    = WDW_R.WDWPyCdDsc;
071400240325  AudtDta1.ATPChgTyp = WDW_R.WDWAccTyp;
071500240325  AudtDta1.ChgTypDsc = WDW_R.WDWAcTyDsc;
071600240325  AudtDta1.ATPDatChg = %Char(ATPDatChg);
071700240325  AudtDta1.ATPUsrChg = ATPUsrChg;
071800240325  WrtAudDta( MyLDA.Group : RECID : AudtDta1.ATPAType : DELETE : AudtDta1 : AudtDta2 : WAD.ErrorMsg );
071900240325
072000240325  // If unable to write the data to the audit file, do not delete the record........................
072100240325  If WAD.ErrorMsg <> *BLANKS;
072200240325    CPF9898.Field1 = WAD.ErrorMsg;
072300240325    SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
072400240325               MsgQNbr_Cur : MsgKey : APIErrC );
072500240325    DataErr_89 = *ON;
072600240325
072700240325  // Delete the pay code change to account type code record.........................................
072800240325  Else;
072900240325    Delete(E) ATPR;
073000240325    If not %Error;
073100240325      RetMsgTyp = INFORM;
073200240325      RetPgmMsg = 'Pay code ' + %Trim(WDW_R.WdwPayCde) + ' change to acct type ' +
073300240325                  %Trim(WDW_R.WDWAccTyp) + ' deleted from Acct Type Pay Code Chgs file';
073400240325      F12_Cancel = *ON;
073500240325    Else;
073600240325      CPF9898.Field1 = 'Error trying to delete the pay code ' + %Trim(WDW_R.WdwPayCde) +
073700240325                       ' change to account type ' + %Trim(WDW_R.WDWAccTyp) + ' from the file';
073800240325      SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
073900240325                 MsgQNbr_Cur : MsgKey : APIErrC );
074000240325    EndIf;
074100240325  Endif;
074200240325
074300240325  // Going up one level in the message queue........................................................
074400240325  MsgQNbr_Cur -= 1;
074500240325
074600240325End-Proc DltAcTyPyCdDta;
074700240325
074800240325//--------------------------------------------------------------------------------------------------
074900240325//- SUBPROCEDURE: CloseOpenFiles                                                                   -
075000240325//- FUNCTION....: Close Files Opened By This Program                                               -
075100240325//- EXPLANATION.: Some files were opened by this program so that the file could be overridden at   -
075200240325//-               the time it was opened. At the end of the program these files need to be closed. -
075300240325//--------------------------------------------------------------------------------------------------
075400240325Dcl-Proc CloseOpenFiles;
075500240325
075600240325  If %Open(ATM);
075700240325    Close(E) ATM;
075800240325  EndIf;
075900240325
076000240325  If %Open(ATP1);
076100240325    Close(E) ATP1;
076200240325  EndIf;
076300240325
076400240325  If %Open(PAYD);
076500240325    Close(E) PAYD;
076600240325  EndIf;
076700240325
076800240325End-Proc CloseOpenFiles;
076900240325
077000240325//--------------------------------------------------------------------------------------------------
077100240325// FUNCTION....: Center text within a field                                                        -
077200240325//--------------------------------------------------------------------------------------------------
077300240325/COPY QCPYSRC,F_CENTRTXT
