000100240111**free
000200240111Ctl-Opt COPYRIGHT('©EMMI Physician Service, Inc. - 2024')
000300240111DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')
000400240111OPTION(*SRCSTMT:*NODEBUGIO:*NOUNREF)
000500240111DECEDIT('0.') ExtBinInt(*YES) OPTIMIZE(*BASIC);
000600240111//*************************************************************************************************/
000700240111//                                   EMMI Physician Service, Inc.                                  /
000800240111//                                               ©2024                                             /
000900240111//*************************************************************************************************/
001000240111// CREATE DATE: 01/11/2024                                                                         /
001100240111// PROGRAMMER.: Johnny Skaggs                                                                      /
001200240111// PROGRAM....: MCM0102R                                                                           /
001300240111// SYNOPSIS...: Pay Code To Account Type Maintenance                                               /
001400240111// DESCRIPTION: A screen displays the pay code and corresponding change to account type for the    /
001500240111//              account type. The account type conversions by pay code are unique to each          /
001600240111//              customer. If the user has the correct authority, they are able to add, change or   /
001700240111//              delete account type conversions; otherwise, the user only has the ability to view  /
001800240111//              the account type conversions. All additions, changes and deletions are done in a   /
001900240111//              pop-up window.  Deletions require a confirmation step by pressing F9 to confirm    /
002000240111//              the deletion. If an account type is deleted from Account Type file (Mxx.ATM), then /
002100240111//              all of the account type conversions will be deleted from the Account Type Pay Code /
002200240111//              Changes file (Mxx.ATP). All actions performed on an account type conversion,       /
002300240111//              except display, will cause a record to be written to the customer Miscellaneous    /
002400240111//              Codes Maintenance Audit file (Mxx.AUDM). The program checks to make sure that a    /
002500240111//              change was made to the data before proceeding with changing the data. If no change /
002600240111//              was made to the data a message is displayed saying that no data changes were made. /
002700240111//              The F4 key is used on the pay code and account type code fields to call a program  /
002800240111//              that brings up a window that allows searching to find and return the desired       /
002900240111//              value.                                                                             /
003000240111//                                                                                                 /
003100240111//++++++++++++++++++++++++++++++++++++++  P R A M A T E R S  ++++++++++++++++++++++++++++++++++++++/
003200240111//      NAME      I/O                                  DESCRIPTION                                 /
003300240111// -------------- --- ---------------------------------------------------------------------------- /
003400240111//  CustCode        In  ·Group code used to identify the customer                                  /
003500240111//  AcctType        In  ·Financial class account type                                              /
003600240111//  RetFncKey       Out ·Function key pressed in calling program that needs to be passed back to   /
003700240111//                       the current program: F3=Exit out of all programs and back to menu         /
003800240111//  RetMsgTyp       Out ·Program message type: ERR=Error, INF=Informational, WRN=Warning           /
003900240111//  RetPgmMsg       Out ·Message returned by the program called                                    /
004000240111//                                                                                                 /
004100240111//++++++++++++++++++++++++++++++++++++++++++  F I L E S  ++++++++++++++++++++++++++++++++++++++++++/
004200240111//    NAME     OVERRIDDEN                                DESCRIPTION                               /
004300240111// ----------  ----------  ----------------------------------------------------------------------- /
004400240111// Mxx.ATM     ATM         Account Type (Financial Class) File                                     /
004500240111// Mxx.ATP1    ATP1        Account Type-Pay Code Changes File                                      /
004600240111// M.MSG       MSG         Message File                                                            /
004700240111// Mxx.PAYD    PAYD        Pay Code Description File                                               /
004800240111//                                                                                                 /
004900240111//++++++++++++++++++++++++++++++++  D A T A  S T R U C T U R E S  +++++++++++++++++++++++++++++++++/
005000240111//      NAME      I/O                                  DESCRIPTION                                 /
005100240111// -------------- --- ---------------------------------------------------------------------------- /
005200240111// AuditData      Out Allows the moving of the audit data into the audit file without having to    /
005300240111//                    move each individual field.                                                  /
005400240111// AudtDta1       I/O Used to store the file data that corresponds to the screen data. This allows /
005500240111//                    the comparison of the screen data to the file data to see if it changed.     /
005600240111// AudtDta2       I/O Used to store the screen data that corresponds to the file data.             /
005700240111// DataIn         In  Allows the data to be retrieved from the input file by the SQL processing.   /
005800240111// MyLDA          In  Holds the data that is read in from the Local Data Area (LDA).               /
005900240111// WSInd          In  Since INDARA is used in the display file, mapping of the indicators must be  /
006000240111//                    done  in the program.  The indicators for the display are now accessed using /
006100240111//                    the  data structure. Turning on an indicator in the data structure will not  /
006200240111//                    turn on the corresponding *INxx indicator.                                   /
006300240111//                                                                                                 /
006400240111//+++++++++++++++++++++++++++++++++++++  C O N S T A N T S   ++++++++++++++++++++++++++++++++++++++/
006500240111//      NAME                                          DESCRIPTION                                  /
006600240111// --------------   ------------------------------------------------------------------------------ /
006700240111// ACCTYPELU      - Perform a lookup on the account type code                                      /
006800240111// ADD            - Add a record to the miscellaneous codes maintenance file                       /
006900240111// CHANGE         - Change a record in the miscellaneous codes maintenance file                    /
007000240111// DELETE         - Delete a record fromthe miscellaneous codes maintenance file                   /
007100240111// DISPLAY        - Display the data for the account type code                                     /
007200240111// EXIT           - Show that the function key F3 was pressed to exit the calling program          /
007300240111// RECID          - Record identification                                                          /
007400240111// RTVBYCODE      - Retrieve records from file using miscellaneous code                            /
007500240111// RTVBYDESC      - Retrieve records from file using code description                              /
007600240111// RTVBYSRCH      - Retrieve records from file using search string                                 /
007700240111// SYSKEY         - System file key used to look up provider account information                   /
007800240111// UPDATED        - Record updated in the miscellaneous codes maintenance file                     /
007900240111// YES            - Replacement for Y                                                              /
008000240111//                                                                                                 /
008100240111//++++++++++++++++++++++++++++++++++++++  V A R I A B L E S  ++++++++++++++++++++++++++++++++++++++/
008200240111//      NAME                                          DESCRIPTION                                  /
008300240111// --------------   ------------------------------------------------------------------------------ /
008400240111// AccTypSec      - Account type security. Used to determine what actions a user can perform       /
008500240111// AccTypF        - Override Mxx.ATM to this account type file name                                /
008600240111// AcTyPyCdF      - Override Mxx.ATP1 to this account type to pay code changes by type file name   /
008700240111// CompanyName    - Name of the company who's data is being presented                              /
008800240111// PayCdeF        - Override Mxx.PAYD to this paycode description file name                        /
008900240111// SavRRN1        - Save of the main display relative record number                                /
009000240111// SFIdx          - Counter used to retrieve data from the subfile display records                 /
009100240111//                                                                                                 /
009200240111//++++++++++++++++++++  F U N C T I O N  K E Y S  A N D  I N D I C A T O R S  +++++++++++++++++++++/
009300240111//     NAME                                         DESCRIPTION                                    /
009400240111// ----------   ---------------------------------------------------------------------------------- /
009500240111// F1_Help    - Context sensitive help                                                             /
009600240111// F3_Exit    - Exit program                                                                       /
009700240111// F4_Prompt  - Prompt the field to show data selection window                                     /
009800240111// F5_Refresh - Refresh the screen by setting everything back to its initial state                 /
009900240111// F6_AddCode - Add a new account type to pay code change to the Account Type Financial Class file /
010000240111// F10_AdInfo - Additional information (subfile fold)                                              /
010100240111// F12_Cancel - Cancel current action and return to previous screen                                /
010200240111// SFNxChg_25 - Mark subfile field as changed (SFLNXTCHG)                                          /
010300240111// ProtFld_28 - Protect the field from changes                                                     /
010400240111// InzSubF_29 - Initailze subfile (SFLINZ)                                                         /
010500240111// ClrSubF_30 - Subfile clear (SFLCLR)                                                             /
010600240111// DspCtlR_31 - Subfile Display Control (SFLDSPCTL)                                                /
010700240111// AddCode_36 - Add a new accounting type code                                                     /
010800240111// InactDt_37 - Account inactive date                                                              /
010900240111// SubFEnd_39 - Display subfile more/bottom                                                        /
011000240111// DataErr_89 - Data error found                                                                   /
011100240111//                                                                                                 /
011200240111//+++++++++++++++++++++++++++++++++  M O D I F I C A T I O N S  +++++++++++++++++++++++++++++++++++/
011300240111// DATE..: MM/DD/CCYY   PROGRAMMER: First and last name                                            /
011400240111// REASON: Project number or ticket number                                                         /
011500240111// MODS..: What changes were made to the program                                                   /
011600240111//*************************************************************************************************/
011700240111
011800240111
011900240111// Passed parameters when called from MCM0100R......................................................
012000240111Dcl-PI *n;
012100240111  CustCode  Char(02) Const;
012200240111  AcctTyCde Char(02) Const;
012300240111  AddChgDsp Char(03) Const;
012400240111  RetFncKey Char(03);
012500240111  RetMsgTyp Char(03);
012600240111  RetPgmMsg Char(78);
012700240111End-PI;
012800240111
012900240111// Declare, override and open files.................................................................
013000240111Dcl-F ATM   Disk Keyed Usage(*INPUT) ExtDesc('MXX.ATM') ExtFile(AccTypF) UsrOpn;
013100240111Dcl-F ATP1  Disk Keyed Qualified Usage(*DELETE:*OUTPUT) ExtDesc('MXX.ATP1') ExtFile(AcTyPyCdF) UsrOpn;
013200240111Dcl-F MSG   Disk Keyed Usage(*INPUT) ExtDesc('M.MSG') ExtFile(*ExtDesc);
013300240111Dcl-F PAYD  Disk Keyed Usage(*INPUT) ExtDesc('MXX.PAYD') ExtFile(PayCdeF) UsrOpn;
013400240111Dcl-F DSP   WorkStn Qualified ExtDesc('MCM0102D') ExtFile(*ExtDesc) SFile(MCM0102SF:SFL_R.SFRRN1)
013500240111             InDDS(WsInd);
013600240111
013700240111// Data structure templates to deifine record formats...............................................
013800240111Dcl-DS ATP1_T LikeRec(ATP1.ATPR     :*All) Template;
013900240111Dcl-DS CTL_T  LikeRec(DSP.MCM0102CTL:*All) Template;
014000240111Dcl-DS FKY_T  LikeRec(DSP.FKEYS     :*All) Template;
014100240111Dcl-DS MSGC_T LikeRec(DSP.MSGCTL    :*All) Template;
014200240111Dcl-DS SFL_T  LikeRec(DSP.MCM0102SF :*All) Template;
014300240111
014400240111// Like data structures used for the reading and writing of data....................................
014500240111Dcl-DS ATP1_R LikeDS(ATP1_T);          // Account type pay code changes
014600240111Dcl-DS CTL_R  LikeDS(CTL_T );          // Accounting type code selection control format
014700240111Dcl-DS FKY_R  LikeDS(FKY_T );          // Function keys
014800240111Dcl-DS MSGC_R LikeDS(MSGC_T);          // Error message screen format
014900240111Dcl-DS SFL_R  LikeDS(SFL_T );          // Accounting type code selction subfile format
015000240111
015100240111// Define data structure for reading of batch control file using SQL................................
015200240111Dcl-DS DataIn ExtName('MXX.ATP1') Qualified End-DS;
015300240111
015400240111// Functions keys and indicators data structure.....................................................
015500240111Dcl-DS WsInd Len(99);
015600240111  FuncKeyInd Char(24) Pos(01);         // Function key indicators...................................
015700240111    F3_Exit    Ind Pos(03);            // Exit
015800240111    F4_Prompt  Ind Pos(04);            // Prompt the field to show data selection window
015900240111    F5_Refresh Ind Pos(05);            // Make the main screen appear like it did initially
016000240111    F6_AddCode Ind Pos(06);            // Print
016100240111    F10_Toggle Ind Pos(10);            // Show/Hide subfile fold additional information
016200240111    F12_Cancel Ind Pos(12);            // Cancel
016300240111  ScreenInd  Char(15) Pos(25);         // Screen manipulation indicators............................
016400240111    SFNxChg_25 Ind Pos(25);            // Mark subfile field as changed (SFLNXTCHG)
016500240111    ProtFld_28 Ind Pos(28);            // Protect the field(s) from being changed
016600240111    InzSubF_29 Ind Pos(29);            // Initailze subfile (SFLINZ)
016700240111    ClrSubF_30 Ind Pos(30);            // Subfile clear (SFLCLR)
016800240111    DspCtlR_31 Ind Pos(31);            // Subfile Display Control (SFLDSPCTL)
016900240111    DspSubF_32 Ind Pos(32);            // Subfile Display (SFLDSP)
017000240111    AccCdeC_34 Ind Pos(34);            // Account type code changed
017100240111    ProtWdw_35 Ind Pos(35);            // Protect window fields from being changed
017200240111    AddCode_36 Ind Pos(36);            // Add a new change account type to based on pay code
017300240111    InactDt_37 Ind Pos(37);            // Inactive date
017400240111    SubFEnd_39 Ind Pos(39);            // Subfile End (SFLEND)
017500240111  FldErrInd  Char(50) Pos(40);         // Error indicators..........................................
017600240111    AcTySel_40 Ind Pos(40);            // Account type selection
017700240111    DataErr_89 Ind Pos(89);            // Data error found
017800240111  ProgramInd Char(10) Pos(90);         // Program flow indicators...................................
017900240111End-DS WsInd;
018000240111
018100240111// Declare data structure to store audit data.......................................................
018200240111Dcl-DS AuditData Qualified;
018300240111  ATPAType  Like(ATP1_R.ATPATYPE );    // Account type code
018400240111  ATMADESC  Like(ATMADESC        );    // Account type description
018500240111  ATPPayCd  Like(ATP1_R.ATPPAYCD );    // Pay code
018600240111  ATPChgTyp Like(ATP1_R.ATPCHGTYP);    // Change to account type
018700240111  ATPDatChg Like(ATP1_R.ATPDATCHG);    // Last change date
018800240111  ATPUsrChg Like(ATP1_R.ATPUSRCHG);    // Last change user
018900240111End-DS AuditData;
019000240111
019100240111// Like data structures used to see if the data has changed.........................................
019200240111Dcl-DS AudtDta1 LikeDS(AuditData);
019300240111Dcl-DS AudtDta2 LikeDS(AuditData);
019400240111
019500240111// Declare data structre for reading in the Local Data Area (LDA)...................................
019600240111Dcl-DS MyLDA DtaAra(*LDA) Qualified;
019700240111  Entity   Char(3)  Pos(137);          // Used to open the correct account type file
019800240111  Group    Char(2)  Pos(138);          // Used as key to lookup customer information
019900240111  DeviceID Char(2)  Pos(494);          // Last two characters of device name
020000240111  UserID   Char(10) Pos(496);          // User identification of person running the job
020100240111  Customer Char(50) Pos(951);          // Customer company name
020200240111End-DS;
020300240111
020400240111// Declare constatnts...............................................................................
020500240111Dcl-C ACCTYPELU Const('ACC');
020600240111Dcl-C ADD       Const('ADD');
020700240111Dcl-C CHANGE    Const('CHG');
020800240111Dcl-C DELETE    Const('DLT');
020900240111Dcl-C DISPLAY   Const('DSP');
021000240111Dcl-C EXIT      Const('F03');
021100240111Dcl-C ERROR     Const('ERR');
021200240111Dcl-C RECID     Const('01');
021300240111Dcl-C SYSKEY    Const('01');
021400240111Dcl-C YES       Const('Y');
021500240111
021600240111// Declare variables...............................................................................
021700240111Dcl-S AccTypSec  Char(01)    Inz;
021800240111Dcl-S AccTypF    Char(10)    Inz;
021900240111Dcl-S AcTyPyCdF  Char(10)    Inz;
022000240111Dcl-S PayCdeF    Char(10)    Inz;
022100240111Dcl-S SavRRN1    Packed(4:0) Inz;
022200240111Dcl-S SFIdx      Packed(4:0) Inz;
022300240111
022400240111// Prototype-Lookup the financial class account type from the Account Type file.....................
022500240111/COPY QCPYSRC,D_ACCTYPLU
022600240111
022700240111// Data structure-Contains any API interface errors.................................................
022800240111/COPY QCPYSRC,D_APIErrDS
022900240111
023000240111// Prototype-Add/Change/Delete the account type based on the associated pay code....................
023100240111/COPY QCPYSRC,D_MCM0104R
023200240111
023300240111// Prototype-Lookup the pay code from the Pay Code Description file.................................
023400240111/COPY QCPYSRC,D_PAYCDELU
023500240111
023600240111// Prototype-Send program message and clear program message queue...................................
023700240111/COPY QCPYSRC,D_PGMMSGS
023800240111
023900240111// Data structure-Contains the program information..................................................
024000240111/COPY QCPYSRC,D_PGMSTSDS
024100240111
024200240111// Constants-Human readable form for the program message identifiers................................
024300240111/COPY QCPYSRC,D_PMSGIDS
024400240111
024500240111// Prototype-Retrieve security data from the User/Program Security file.............................
024600240111/COPY QCPYSRC,D_RTVSECDT
024700240111
024800240111// Prototype-Retrieve system control data from the System Control file..............................
024900240111/COPY QCPYSRC,D_RTVSYSDT
025000240111
025100240111// Prototype-Write the audit data to the correct audit file.........................................
025200240111/COPY QCPYSRC,D_WRTAUDTA
025300240111
025400240111//**************************************************************************************************
025500240111//************************************  M A I N  P R O G R A M  ************************************
025600240111//**************************************************************************************************
025700240111
025800240111// Stuff that only needs to be done once when the program is first run..............................
025900240111ProgramEntry();
026000240111
026100240111// Process the screen until F3 is pressed...........................................................
026200240111DoU F3_Exit;
026300240111
026400240111  // Display the pay code to account type maintenance screen........................................
026500240111  SubFEnd_39 = *ON;
026600240111  Write DSP.MSGCTL MSGC_R;
026700240111  Clear WAD;                                     // Clear out the audit data fields
026800240111  Clear AudtDta1;                                // Clear out the comparison data structures
026900240111  Clear AudtDta2;
027000240111  AddCode_36 = *OFF;                             // Turn off record add indicator
027100240111  Write DSP.FKEYS FKY_R;
027200240111  ExFmt DSP.MCM0102CTL CTL_R;
027300240111
027400240111  // Reset the error indicators and clear out any previously displayed messages.....................
027500240111  FldErrInd = *OFF;
027600240111  ClrMsgQ(MsgQ_Cur : MsgQNbr_Cur : MsgKey_All :  MsgRmv_All : APIErrC);
027700240111
027800240111  // F3 - Exit out of program.......................................................................
027900240111  Select;
028000240111  When F3_Exit;
028100240111    RetFncKey = EXIT;
028200240111    Leave;
028300240111
028400240111  // F4 - Process prompt request for information lookup.............................................
028500240111  When F4_Prompt;
028600240111    If CTL_R.CurFld = 'SELACCTYCD';
028700240111      ProcPrompt(ACCTYPELU);
028800240111    Else;
028900240111      CPF9898.Field1 = 'The location of your cursor does not allow for prompting';
029000240111      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
029100240111                 MsgQNbr_Cur : MsgKey : APIErrC);
029200240111      DataErr_89  = *ON;
029300240111    EndIf;
029400240111
029500240111  // F5 - Set the screen to the way it was when it first came up....................................
029600240111  When F5_Refresh;
029700240111    InzSubFile();
029800240111    ClrSFData();
029900240111    RtvPayCdeChgs();
030000240111
030100240111  // F6 - Add a new code to the Account Type Pay Code Changes file..................................
030200240111  When F6_AddCode and ProtFld_28 = *OFF;
030300240111    If AccTypSec = YES;                          // Must have the security to add codes
030400240111      VldAcTyPyCdDta();
030500240111      If DataErr_89 = *OFF;
030600240111        DOU PCAT.ExitAdd <> *BLANKS;
030700240111          PayCdeAccTyp(CustCode : CTL_R.SELACCTYCD : *BLANKS : *BLANKS : ADD : PCAT.ExitAdd :
030800240111                       PCAT.RetMsgTyp : PCAT.RetPgmMsg);
030900240111          AddCode_36 = *ON;
031000240111          Clear SFL_R.Option;                    // Incorporate any additions to the display data
031100240111          ClrSFData();
031200240111          RtvPayCdeChgs();
031300240111        EndDo;
031400240111      EndIf;
031500240111    Else;
031600240111      SndPgmMsg(Err_CodeAdd : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
031700240111                 MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC);
031800240111      DataErr_89 = *ON;
031900240111    EndIf;
032000240111
032100240111  // F12 - Go back to previous screen...............................................................
032200240111  When F12_Cancel;
032300240111    Leave;
032400240111
032500240111  // Enter - Process the different screens if the user has the permissions to modify the data.......
032600240111  Other;
032700240111    If ProtFld_28 = *OFF;                        // User can modify data
032800240111      ProcessScreen();
032900240111    Else;
033000240111      VldAcTyPyCdDta();                          // User is only allowed to view data
033100240111      If DataErr_89 = *OFF;
033200240111        ClrSFData();
033300240111        RtvPayCdeChgs();
033400240111      EndIf;
033500240111    EndIf;
033600240111  EndSL;
033700240111
033800240111EndDo;                                           // DoU F3_Exit
033900240111
034000240111// Close files that were opened by this program.....................................................
034100240111CloseOpenFiles();
034200240111
034300240111//--------------------------------------------------------------------------------------------------
034400240111//- SUBPROCEDURE: ProgramEntry                                                                     -
034500240111//- FUNCTION....: Tasks Done When The Prorgam Is First Run                                         -
034600240111//- EXPLANATION.: Process all of the tasks that only need to done when the program is first run.   -
034700240111//-               Such as, getting user privileges, opening files, initializing variables, etc.    -
034800240111//--------------------------------------------------------------------------------------------------
034900240111Dcl-Proc ProgramEntry;
035000240111
035100240111  // Set program name for error message screen and initialize the error message screen..............
035200240111  *INLR = *ON;
035300240111  MSGC_R.PGMNAME = PgmName;                      // Required because of screen record format DS
035400240111  ClrMsgQ(MsgQ_Cur : MsgQNbr_Cur : MsgKey_All :  MsgRmv_All : APIErrC);
035500240111
035600240111  // Account for the possiblity of not having any subfile data when the subfile screen is displayed.
035700240111  InzSubFile();
035800240111  ClrSFData();
035900240111
036000240111  // Retrieve the user security information from the program security file..........................
036100240111  If AddChgDsp = DISPLAY;
036200240111     ProtFld_28 = *ON;
036300240111  ElseIf AddChgDsp = CHANGE or AddChgDsp = ADD;
036400240111    AccTypSec = YES;
036500240111  ElseIf AddChgDsp = *BLANKS;
036600240111    RtvSecDta(PgmName : JobUser : RSECD.SecFileDta : RSECD.ErrorMsg);
036700240111    If RSECD.ErrorMsg = *BLANKS;
036800240111      AccTypSec =  RSECD.SecFileDta.SEC01;
036900240111      If RSECD.SecFileDta.SEC01 <> YES;            // Pay code data edit security
037000240111        ProtFld_28 = *ON;                          // Do not allow editing of pay code data
037100240111      EndIf;
037200240111    Else;
037300240111      CPF9898.Field1 = RSECD.ErrorMsg;
037400240111      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
037500240111                 MsgQNbr_Cur : MsgKey : APIErrC);
037600240111      ProtFld_28 = *ON;
037700240111      DataErr_89 = *ON;
037800240111    EndIf;
037900240111  EndIf;
038000240111
038100240111  // Open the files with the appropriate name.......................................................
038200240111  In MyLDA;
038300240111  If %Len(%Trim(MyLDA.Entity)) = 3;
038400240111    AccTypF = MyLDA.Entity + '.ATM';
038500240111    If not %Open(ATM);
038600240111      Open(E) ATM;
038700240111      If %Error;
038800240111        CPF9898.Field1 = 'The program could not open the file ' + AccTypF + '. Contact IT for help';
038900240111        SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
039000240111                   MsgQNbr_Cur : MsgKey : APIErrC);
039100240111        DataErr_89 = *ON;
039200240111      EndIf;
039300240111    EndIf;
039400240111
039500240111    AcTyPyCdF = MyLDA.Entity + '.ATP1';
039600240111    If not %Open(ATP1);
039700240111      Open(E) ATP1;
039800240111      If %Error;
039900240111        CPF9898.Field1 = 'The program could not open the file ' + AcTyPyCdF + '. Contact IT for help';
040000240111        SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
040100240111                   MsgQNbr_Cur : MsgKey : APIErrC);
040200240111        DataErr_89 = *ON;
040300240111      EndIf;
040400240111    EndIf;
040500240111
040600240111    PayCdeF = MyLDA.Entity + '.PAYD';
040700240111    If not %Open(PAYD);
040800240111      Open(E) PAYD;
040900240111      If %Error;
041000240111        CPF9898.Field1 = 'The program could not open the file ' + PayCdeF + '. Contact IT for help';
041100240111        SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
041200240111                   MsgQNbr_Cur : MsgKey : APIErrC);
041300240111        DataErr_89 = *ON;
041400240111      EndIf;
041500240111    EndIf;
041600240111
041700240111  // Retrieve the customer company and center it in the field.......................................
041800240111  RtvSysDta(MyLDA.Group : SYSKEY : RSYSD.SysFileDta : RSYSD.ErrorMsg);
041900240111  If RSYSD.ErrorMsg = *BLANKS;
042000240111    CTL_R.AcctName = CenterText(RSYSD.SysFileDta.SYSNAM);
042100240111  Else;
042200240111    CPF9898.Field1 = RSYSD.ErrorMsg;
042300240111    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
042400240111               MsgQNbr_Cur : MsgKey : APIErrC);
042500240111    DataErr_89 = *ON;
042600240111  EndIf;
042700240111
042800240111  Else;
042900240111    CPF9898.Field1 = 'LDA missing data. Cannot open correct file. Contact IT for help';
043000240111    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
043100240111               MsgQNbr_Cur : MsgKey : APIErrC);
043200240111    DataErr_89 = *ON;
043300240111  EndIf;
043400240111
043500240111  // Retrieve the pay code data for the account type code...........................................
043600240111  If not DataErr_89;
043700240111    CTL_R.SelAccTyCd = AcctTyCde;
043800240111    Chain(E) (AcctTyCde) ATMR;                   // Retrieve the account type code description
043900240111    If %Found and not %Error;
044000240111      CTL_R.SelAccTyDs = ATMADesc;
044100240111    EndIf;
044200240111    RtvPayCdeChgs();
044300240111  EndIf;
044400240111
044500240111End-Proc ProgramEntry;
044600240111
044700240111//--------------------------------------------------------------------------------------------------
044800240111//- SUBPROCEDURE: InzSubFile
044900240111//- FUNCTION....: Initialize The Fields In The Subfile                                             -
045000240111//- EXPLANATION.: Set all the input capable fields to their default values for data entry.         -
045100240111//--------------------------------------------------------------------------------------------------
045200240111Dcl-Proc InzSubFile;
045300240111
045400240111  // Set the indicators to initialize the subfile display...........................................
045500240111  InzSubF_29   = *ON;
045600240111  CTL_R.SFRec# = 1;
045700240111  SFL_R.SFRRN1 = *ZERO;
045800240111
045900240111  // Write the subfile control record to clear out the subfile display..............................
046000240111  Write DSP.MCM0102CTL CTL_R;
046100240111
046200240111  // Set indicators and fields to show that the subfile is empty....................................
046300240111  InzSubF_29 = *OFF;
046400240111  DspCtlR_31 = *ON;
046500240111  DspSubF_32 = *ON;
046600240111
046700240111End-Proc InzSubFile;
046800240111
046900240111//--------------------------------------------------------------------------------------------------
047000240111//- SUBPROCEDURE: ClrSFData                                                                        -
047100240111//- FUNCTION....: Clear Out The Data In Subfile Display                                            -
047200240111//- EXPLANATION.: Remove all the data in the display subfile so that it does not contain any data  -
047300240111//-               before more data is written to the subfile.                                      -
047400240111//--------------------------------------------------------------------------------------------------
047500240111Dcl-Proc ClrSFData;
047600240111
047700240111  // Set the indicators to clear out the subfile display............................................
047800240111  ClrSubF_30 = *ON;
047900240111  DspCtlR_31 = *OFF;
048000240111  DspSubF_32 = *OFF;
048100240111
048200240111  // Write the subfile control record to clear out the subfile display..............................
048300240111  Write DSP.MCM0102CTL CTL_R;
048400240111
048500240111  // Set indicators and fields to show that the subfile is empty....................................
048600240111  CTL_R.SFRec# = *ZERO;
048700240111  ClrSubF_30   = *OFF;
048800240111  DspCtlR_31   = *ON;
048900240111  SavRRN1      = *ZERO;
049000240111  SFL_R.SFRRN1 = *ZERO;
049100240111  SubFEnd_39   = *OFF;
049200240111
049300240111End-Proc ClrSFData;
049400240111
049500240111//--------------------------------------------------------------------------------------------------
049600240111//- SUBPROCEDURE: RtvPayCdeChgs                                                                    -
049700240111//- FUNCTION....: Retrieve Data To Load Into The Subfile Display                                   -
049800240111//- EXPLANATION.: Retrieve the data from the Account Type file to populate the subfile display.    -
049900240111//-               Retrieve the data from the Account Type file to populate the subfile display.    -
050000240111//-                                                                                                -
050100240111//-               For the initial screen, the code header will be highlighted and the data will    -
050200240111//-               be sorted by the code. Additionally, the data can be sorted by the code          -
050300240111//-               description. Also, there is the ability to populate the subfile display based    -
050400240111//-               upon matching the search characters with characters in the code or code          -
050500240111//-               description. This is accomplished by placing a question mark at the beginning of -
050600240111//-               the characters in the search field. The SFLEND indicator is set ON so that the   -
050700240111//-               display will handle the MORE and BOTTOM that appear at the end of the subfile    -
050800240111//-               display.                                                                         -
050900240111//-                                                                                                -
051000240111//- - - - - - - - - - - - - - - - - - -  C O N S T A N T S   - - - - - - - - - - - - - - - - - - - -
051100240111//-      Name                                          Description                                 -
051200240111//- --------------   ----------------------------------------------------------------------------- -
051300240111//- ASCENDING        Sort the returned SQL data in ascending sequence                              -
051400240111//- DESCENDING       Sort the returned SQL data in descending sequence                             -
051500240111//- MAXSFREC         Maximum number of records in the main subfile                                 -
051600240111//- SPACE            Used to put spaces inbetween the different clauses of the SQL statement       -
051700240111//- SQLOK            Status of good SQL processing                                                 -
051800240111//- SQLEOF           SQL end of file indicator                                                     -
051900240111//- SQUOTE           Single quote to put around character values in the SQL statement              -
052000240111//-                                                                                                -
052100240111//- - - - - - - - - - - - - - - - - - -  V A R I A B L E S   - - - - - - - - - - - - - - - - - - - -
052200240111//-      Name                                          Description                                 -
052300240111//- --------------   ----------------------------------------------------------------------------- -
052400240111//- ForClause        Dynamic SQL FOR clause (not required; however, it is recommended)             -
052500240111//- GroupByClause    Dynamic SQL GROUP BY clause used to get unique values for the field           -
052600240111//- OrderByClause    Dynamic SQL ORDER BY clause (not required)                                    -
052700240111//- SelectClause     Dynamic SQL SELECT clause (also update, delete, etc)                          -
052800240111//- SortSeq          Sequence in which the data is sorted (ascending or descending)                -
052900240111//- SQLStmt          Complete dynamic SQL stament to be executed                                   -
053000240111//- WhereClause      Dynamic SQL WHERE clause                                                      -
053100240111//--------------------------------------------------------------------------------------------------
053200240111Dcl-Proc RtvPayCdeChgs;
053300240111
053400240111  // Declare constants..............................................................................
053500240111  Dcl-C ASCENDING  Const('ASC');
053600240111  Dcl-C DESCENDING Const('DESC');
053700240111  Dcl-C MAXSFREC   Const(1400);
053800240111  Dcl-C SPACE      Const(' ');
053900240111  Dcl-C SQLOK      Const('00000');
054000240111  Dcl-C SQLEOF     Const('02000');
054100240111  Dcl-C SQUOTE     Const('''');
054200240111
054300240111  // Declare standalone variables...................................................................
054400240111  Dcl-S ForClause     Char( 64);
054500240111  Dcl-S GroupByClause Char(128);
054600240111  Dcl-S OrderByClause Char(128);
054700240111  Dcl-S SelectClause  Char(256);
054800240111  Dcl-S SortSeqAsc    Char(  4)  Inz(ASCENDING);
054900240111  Dcl-S SortSeqDsc    Char(  4)  Inz(DESCENDING);
055000240111  Dcl-S SQLStmt       Char(1024);
055100240111  Dcl-S WhereClause   Char(256);
055200240111
055300240111  // Going down one level in the message queue......................................................
055400240111  MsgQNbr_Cur += 1;
055500240111
055600240111  // Build the SQL select clause....................................................................
055700240111  SelectClause = 'select * from "' + %Trim(AcTyPyCdF) + '"';
055800240111
055900240111  // Build the SQL where clause.....................................................................
056000240111  WhereClause = 'where ATPATYPE = ' + SQUOTE + CTL_R.SelAccTyCd + SQUOTE;
056100240111
056200240111  // Build the SQL group by clause(not needed)......................................................
056300240111  GroupByClause = SPACE;
056400240111
056500240111  // Build the SQL order by clause..................................................................
056600240111  OrderByClause = 'order by ATPATYPE ' + SortSeqAsc + ', ATPPAYCD ' + SortSeqAsc;
056700240111
056800240111  // Build the SQL for clause.......................................................................
056900240111  ForClause = 'for read only';
057000240111
057100240111  // Build the SQL statement separating each clause by a space......................................
057200240111  SQLStmt   = %Trim(SelectClause) + SPACE + %Trim(WhereClause) + SPACE + %Trim(GroupByClause) +
057300240111              SPACE + %Trim(OrderByClause) + SPACE + %TrimR(ForClause);
057400240111
057500240111  // Commit must be set to none since table is not journaled........................................
057600240111  Exec SQL Set Option Commit = *NONE, Closqlcsr = *ENDMOD;
057700240111
057800240111  // Declare the cursor for dynamic SQL statement...................................................
057900240111  Exec SQL Declare InputFile cursor for DynSQLStmt;
058000240111
058100240111  // Prepare the declared dynamic SQL cursor to receive data........................................
058200240111  Exec SQL Prepare DynSQLStmt from :SQLStmt;
058300240111
058400240111  // Open the cursor for reading of the data and make sure data was retrieved.......................
058500240111  Exec SQL Open InputFile;
058600240111  If SQLState <> SQLOK;
058700240111    Wrn0000.Field1 = SQLStmt;
058800240111    SndPgmMsg(Wrn_NoDtaRt : MsgFile_Dft : Wrn0000 : %Len(Wrn0000) : MsgTy_Diag : MsgQ_Cur :
058900240111               MsgQNbr_Cur : MsgKey : APIErrC);
059000240111    DataErr_89 = *ON;
059100240111  EndIf;
059200240111
059300240111  // Read the data into the data structure and wrtie it to the subfile display......................
059400240111  If SQLState = SQLOK and DataErr_89 = *OFF;
059500240111    Exec SQL Fetch next from InputFile into :DataIn;
059600240111
059700240111    DoW SQLState = SQLOK and SQLState <> SQLEOF and SFL_R.SFRRN1 <= MAXSFREC;
059800240111      SFL_R.SFRRN1 += 1;
059900240111      EVAL-Corr SFL_R = DataIn;
060000240111
060100240111      Clear SFL_R.PADesc;                        // Retrieve the pay code description
060200240111      Chain(E) (SFL_R.ATPPayCd) PAYDR;
060300240111      If %Found and not %Error;
060400240111        SFL_R.PADesc = PADesc;
060500240111      EndIf;
060600240111
060700240111      Clear SFL_R.ATMADesc;                      // Retrieve the account type code description
060800240111      Chain(E) (SFL_R.ATPChgTyp) ATMR;
060900240111      If %Found and not %Error;
061000240111        SFL_R.ATMADesc = ATMADesc;
061100240111      EndIf;
061200240111
061300240111      Write DSP.MCM0102SF SFL_R;
061400240111      Exec SQL Fetch next from InputFile into :DataIn;
061500240111    EndDo;
061600240111  EndIf;
061700240111
061800240111  // Close the cursor once the data has been read...................................................
061900240111  Exec SQL Close InputFile;
062000240111
062100240111  // No records read from input file, so show warning message.......................................
062200240111  If SFL_R.SFRRN1 = *ZERO;
062300240111    CPF9898.Field1 = 'No data found for account type code. Ignore warning if new account code';
062400240111    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
062500240111               MsgQNbr_Cur : MsgKey : APIErrC);
062600240111    DataErr_89  = *ON;
062700240111  EndIf;
062800240111
062900240111  // // Disiplay the subfile even if it does not contain data..........................................
063000240111  DspSFData();
063100240111
063200240111  // Going up one level in the message queue........................................................
063300240111  MsgQNbr_Cur -= 1;
063400240111
063500240111End-Proc RtvPayCdeChgs;
063600240111
063700240111//--------------------------------------------------------------------------------------------------
063800240111//- SUBPROCEDURE: DspSFData                                                                        -
063900240111//- FUNCTION....: Display The Subfile If It Contains Data                                          -
064000240111//- EXPLANATION.: Set the indicators to display the subile even if it does not have any records.   -
064100240111//-               Note:  If you try to display an empty subfile that has not been initialized, the -
064200240111//-               program will error out.                                                          -
064300240111//--------------------------------------------------------------------------------------------------
064400240111Dcl-Proc DspSFData;
064500240111
064600240111  // Display the subfile if there are records to display............................................
064700240111  If SFL_R.SFRRN1 > *ZERO;
064800240111    DspSubF_32  = *ON;
064900240111    CTL_R.SFRec# = SavRRN1 + 1;
065000240111  Else;
065100240111    DspSubF_32  = *OFF;
065200240111    CTL_R.SFRec# = *ZERO;
065300240111  EndIF;
065400240111
065500240111  // Do not allow the subfile page to position beyond the last subfile page.........................
065600240111  If CTL_R.SFRec# > SFL_R.SFRRN1;
065700240111    CTL_R.SFRec# = SavRRN1;
065800240111  EndIf;
065900240111
066000240111  // Save the last subfile record to be able to position to the last subfile page...................
066100240111  SavRRN1 = SFL_R.SFRRN1;
066200240111
066300240111End-Proc DspSFData;
066400240111
066500240111//--------------------------------------------------------------------------------------------------
066600240111//- SUBPROCEDURE: ProcPrompt                                                                       -
066700240111//- FUNCTION....: Process The F4 Prompt Command                                                    -
066800240111//- EXPLANATION.: Disply the correct lookup window based upon what field the cursor was in when    -
066900240111//-               the prompt key was pressed.  The account type code and the pay code can be       -
067000240111//-               prompted. If a code is passed back, then move it to the correct field.           -
067100240111//- - - - - - - - - - - - - - - - - -   P A R A M E T E R S  - - - - - - - - - - - - - - - - - - - -
067200240111//      Name      I/O                                  Description                                 -
067300240111// -------------- --- ---------------------------------------------------------------------------- -
067400240111//- LookUp        In  What kind of data lookup needs to be done (account type only)                -
067500240111//--------------------------------------------------------------------------------------------------
067600240111Dcl-Proc ProcPrompt;
067700240111  Dcl-PI *n;
067800240111    Lookup Char(9) Value;
067900240111  End-PI;
068000240111
068100240111  // Account type code lookup.......................................................................
068200240111  If Lookup = ACCTYPELU;
068300240111    AccTypLkUp(MyLDA.Group : AT.AcctType : AT.AccTypDsc : AT.ErrorMsg);
068400240111    If AT.AcctType <> *BLANKS and AT.ErrorMsg = *BLANKS;
068500240111      CTL_R.SelAccTyCd = AT.AcctType;
068600240111      CTL_R.SelAccTyDs = AT.AccTypDsc;
068700240111      VldAcTyPyCdDta();
068800240111      RtvPayCdeChgs();
068900240111    ElseIf AT.ErrorMsg <> *BLANKS;
069000240111      CPF9898.Field1 = AT.ErrorMsg;
069100240111      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
069200240111                 MsgQNbr_Cur : MsgKey : APIErrC);
069300240111      DataErr_89  = *ON;
069400240111    EndIf;
069500240111  EndIf;
069600240111
069700240111
069800240111End-Proc ProcPrompt;
069900240111
070000240111//--------------------------------------------------------------------------------------------------
070100240111//- SUBPROCEDURE: ProcessScreen                                                                    -
070200240111//- FUNCTION....: Process The Screen                                                               -
070300240111//- EXPLANATION.: Determine what needs to happen next from what was entered on the screen or what  -
070400240111//-               key was pressed. The pay code to account type options allow the user to change   -
070500240111//-               or delete the pay code to account type data. Additional pay code to account      -
070600240111//-               types cna be added with the function key F6. The user must have authority to     -
070700240111//-               make additions, changes, or deletions; otherwise, the user can only view the     -
070800240111//-               data.                                                                            -
070900240111//--------------------------------------------------------------------------------------------------
071000240111Dcl-Proc ProcessScreen;
071100240111
071200240111  // Going down one level in the message queue......................................................
071300240111  MsgQNbr_Cur += 1;
071400240111
071500240111  // Process the account type code screen...........................................................
071600240111  If AccCdeC_34 = *ON;
071700240111    VldAcTyPyCdDta();
071800240111    RtvPayCdeChgs();
071900240111  Else;
072000240111    ReadC(E) DSP.MCM0102SF SFL_R;                // Check for option number being entered first
072100240111    If not %EOF or %ERROR;
072200240111      VldAcTyPyCdDta();
072300240111      If DataErr_89 = *OFF;
072400240111        ProcOptEntered();                        // Process the change/delete/display for the code
072500240111      EndIf;
072600240111    ElseIf %Error;
072700240111      CPF9898.Field1 = 'An error occured while reading the subfile display data';
072800240111      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
072900240111                 MsgQNbr_Cur : MsgKey : APIErrC);
073000240111    EndIf;
073100240111  EndIf;
073200240111
073300240111  // Going up one level in the message queue........................................................
073400240111  MsgQNbr_Cur -= 1;
073500240111
073600240111End-Proc ProcessScreen;
073700240111
073800240111//--------------------------------------------------------------------------------------------------
073900240111//- SUBPROCEDURE: ProcOptEntered                                                                   -
074000240111//- FUNCTION....: Process The Option Number Entered                                                -
074100240111//- EXPLANATION.: Validate that the data the user is trying to change or delete exists in the      -
074200240111//-               Account Type Pay Code Changes file. If the user is not trying to change the      -
074300240111//-               data, then it is assumed that they are trying to delete it, because change and   -
074400240111//-               delete are the only two option numbers allowed.                                  -
074500240111//--------------------------------------------------------------------------------------------------
074600240111Dcl-Proc
074700240111  ProcOptEntered;
074800240111
074900240111  // Going down one level in the message queue......................................................
075000240111  MsgQNbr_Cur += 1;
075100240111
075200240111  // Process the option entered for the pay code....................................................
075300240111  DoW not %EOF and not %Error;
075400240111
075500240111    // Change or delete account type pay code changes data..........................................
075600240111    If SFL_R.OPTION = '2' or SFL_R.OPTION = '4';
075700240111      Chain(E) SFL_R.SFRRN1 DSP.MCM0102SF SFL_R;
075800240111      If %FOUND and not %ERROR;
075900240111        If SFL_R.Option = '2';
076000240111          PayCdeAccTyp(CustCode : CTL_R.SELACCTYCD : SFL_R.ATPPayCd : SFL_R.ATPChgTyp : CHANGE :
076100240111                       PCAT.ExitAdd : PCAT.RetMsgTyp : PCAT.RetPgmMsg);
076200240111          Clear SFL_R.Option;                          // Incorporate any changes to the display data
076300240111          ClrSFData();
076400240111          RtvPayCdeChgs();
076500240111          If PCAT.RetPgmMsg <> *BLANKS;
076600240111            CPF9898.Field1 = PCAT.RetPgmMsg;
076700240111            SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
076800240111                      MsgQNbr_Cur : MsgKey : APIErrC);
076900240111          EndIf;
077000240111        Else;                                          // Not a change, so delete is assumed
077100240111          PayCdeAccTyp(CustCode : CTL_R.SELACCTYCD : SFL_R.ATPPayCd : SFL_R.ATPChgTyp : DELETE :
077200240111                       PCAT.ExitAdd : PCAT.RetMsgTyp : PCAT.RetPgmMsg);
077300240111          Clear SFL_R.Option;                          // Incorporate any deletions to the display data
077400240111          ClrSFData();
077500240111          RtvPayCdeChgs();
077600240111          If PCAT.RetPgmMsg <> *BLANKS;
077700240111            CPF9898.Field1 = PCAT.RetPgmMsg;
077800240111            SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
077900240111                      MsgQNbr_Cur : MsgKey : APIErrC);
078000240111          EndIf;
078100240111        EndIf;
078200240111      Else;
078300240111        CPF9898.Field1 = 'An error occured when retrieving the subfile data';
078400240111        SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
078500240111                  MsgQNbr_Cur : MsgKey : APIErrC);
078600240111        Leave;
078700240111      EndIf;
078800240111    EndIf;
078900240111
079000240111    ReadC(E) DSP.MCM0102SF SFL_R;
079100240111  EndDo;
079200240111
079300240111  // Error occured while processing the subfile.....................................................
079400240111  If %ERROR;
079500240111    CPF9898.Field1 = 'An error occured while processing the subfile display data';
079600240111    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
079700240111    MsgQNbr_Cur : MsgKey : APIErrC);
079800240111  EndIf;
079900240111
080000240111  // Going up one level in the message queue........................................................
080100240111  MsgQNbr_Cur -= 1;
080200240111
080300240111End-Proc ProcOptEntered;
080400240111
080500240111//--------------------------------------------------------------------------------------------------
080600240111//- SUBPROCEDURE: VldAcTyPyCdDta                                                                   -
080700240111//- FUNCTION....: Validate Changes Made To The Account Type Pay Code Changes Data                  -
080800240111//- EXPLANATION.: Check the data entered to make sure that it is valid before changes or additions -
080900240111//-               are made to the file.                                                            -
081000240111//--------------------------------------------------------------------------------------------------
081100240111Dcl-Proc VldAcTyPyCdDta;
081200240111
081300240111  // Going down one level in the message queue......................................................
081400240111  MsgQNbr_Cur += 1;
081500240111
081600240111  // Account type cannot be blank...................................................................
081700240111  If CTL_R.SelAccTyCd = *BLANKS;
081800240111    ERR0024.Field1 = 'Account Type';
081900240111    SndPgmMsg(Err_MisValu : MsgFile_Dft : Err0024 : %Len(Err0024) : MsgTy_Diag : MsgQ_Cur :
082000240111             MsgQNbr_Cur : MsgKey : APIErrC);
082100240111    AcTySel_40 = *ON;
082200240111    DataErr_89 = *ON;
082300240111  Else;
082400240111
082500240111    // Validate account type........................................................................
082600240111    InactDt_37 = *OFF;
082700240111    Clear CTL_R.SelAccTyDs;
082800240111    Clear CTL_R.InactDate;
082900240111    Chain(E) (CTL_R.SelAccTyCd) ATMR;
083000240111    If %Found and not %Error;
083100240111      CTL_R.SelAccTyDs = ATMADesc;
083200240111      If ATMInacDt <> *ZERO;
083300240111        CTL_R.InactDate  = %Dec(%Char(%Date(ATMInacDt:*ISO):*USA0):8:0);
083400240111        InactDt_37 = *ON;
083500240111      EndIf;
083600240111    ElseIf not %Found and not %Error;
083700240111      ERR0036.Field1 = 'Account Type (Financial Class)';
083800240111      SndPgmMsg(Err_NotInFl : MsgFile_Dft : Err0036 : %Len(Err0036) : MsgTy_Diag : MsgQ_Cur :
083900240111                 MsgQNbr_Cur : MsgKey : APIErrC);
084000240111      AcTySel_40 = *ON;
084100240111      DataErr_89 = *ON;
084200240111    ElseIf %Error;
084300240111      CPF9898.Field1 = 'Issues checking the existance of the account type in ' + AccTypF;
084400240111      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
084500240111                 MsgQNbr_Cur : MsgKey : APIErrC);
084600240111      DataErr_89 = *ON;
084700240111    EndIf;
084800240111  EndIf;
084900240111
085000240111  // Going up one level in the message queue........................................................
085100240111  MsgQNbr_Cur -= 1;
085200240111
085300240111End-Proc VldAcTyPyCdDta;
085400240111
085500240111//--------------------------------------------------------------------------------------------------
085600240111//- SUBPROCEDURE: CloseOpenFiles                                                                   -
085700240111//- FUNCTION....: Close Files Opened By This Program                                               -
085800240111//- EXPLANATION.: Some files were opened by this program so that the file could be overridden at   -
085900240111//-               the time it was opened. At the end of the program these files need to be closed. -
086000240111//--------------------------------------------------------------------------------------------------
086100240111Dcl-Proc CloseOpenFiles;
086200240111
086300240111  If %Open(ATM);
086400240111    Close(E) ATM;
086500240111  EndIf;
086600240111
086700240111  If %Open(ATP1);
086800240111    Close(E) ATP1;
086900240111  EndIf;
087000240111
087100240111  If %Open(PAYD);
087200240111    Close(E) PAYD;
087300240111  EndIf;
087400240111
087500240111  If %Open(SYS);
087600240111    Close(E) SYS;
087700240111  EndIf;
087800240111
087900240111End-Proc CloseOpenFiles;
088000240111
088100240111//--------------------------------------------------------------------------------------------------
088200240111// FUNCTION....: Center text within a field                                                        -
088300240111//--------------------------------------------------------------------------------------------------
088400240111/COPY QCPYSRC,F_CENTRTXT
