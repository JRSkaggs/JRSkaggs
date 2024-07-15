000100240313**free
000200240313Ctl-Opt COPYRIGHT('©EMMI Physician Service, Inc. - 2024')
000300240313DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')
000400240313OPTION(*SRCSTMT:*NODEBUGIO:*NOUNREF)
000500240313DECEDIT('0.') ExtBinInt(*YES) OPTIMIZE(*BASIC);
000600240313//*************************************************************************************************/
000700240313//                                   EMMI Physician Service, Inc.                                  /
000800240313//                                               ©2024                                             /
000900240313//*************************************************************************************************/
001000240313// CREATE DATE: 03/13/2024                                                                         /
001100240313// PROGRAMMER.: Johnny Skaggs                                                                      /
001200240313// PROGRAM....: MCM0100R                                                                           /
001300240313// SYNOPSIS...: Account Type Maintenance Selection                                                 /
001400240313// DESCRIPTION: Shows a screen that lists the unique account type codes for the customer. There is /
001500240313//              an option column at the front of account type codes that allows for the entry of a /
001600240313//              number to display or change the account type code details, or delete the account   /
001700240313//              type. To add a new account type code a funtion key is pressed. You must have the   /
001800240313//              authority to change, delete, or add account type codes; otherwise, you can only    /
001900240313//              view the account type data. If you delete an account type, then the corresponding  /
002000240313//              account type codes will be deleted from the Account Type Pay Code changes file     /
002100240313//              (Mxx.ATP). All actions performed on an account type, except display, will create a /
002200240313//              record in the customer Miscellaneous Codes Maintenance Audit file (Mxx.AUDM). A    /
002300240313//              check is done to make sure the data was changed before updating the data, so that  /
002400240313//              no unneccesary records are written to the audit file. If no modifications were     /
002500240313//              made to the data, then a message is displayed and nothing is done.                 /
002600240313//                                                                                                 /
002700240313//++++++++++++++++++++++++++++++++++++++  P R A M A T E R S  ++++++++++++++++++++++++++++++++++++++/
002800240313//      NAME      I/O                                  DESCRIPTION                                 /
002900240313// -------------- --- ---------------------------------------------------------------------------- /
003000240416//  RetFncKey       Out ·Function key pressed in this program that needs to be returned to the     /
003100240416//                       calling program (for example, F03=Exit back to menu)                      /
003200240416//  RetMsgTyp       Out ·Program message type: ERR=Error, INF=Informational, WRN=Warning           /
003300240416//  RetPgmMsg       Out ·Message returned by this program to the calling program                   /
003400240416//                                                                                                 /
003500240313//++++++++++++++++++++++++++++++++++++++++++  F I L E S  ++++++++++++++++++++++++++++++++++++++++++/
003600240313//    NAME     OVERRIDDEN                                DESCRIPTION                               /
003700240313// ----------  ----------  ----------------------------------------------------------------------- /
003800240313// Mxx.ATM     ATM         Account Type (Financial Class) File                                     /
003900240313// Mxx.ATP1    ATP1        Account Type-Pay Code Changes File                                      /
004000240313// Mxx.PAYD    PAYD        Pay Code Description File                                               /
004100240313//                                                                                                 /
004200240313//++++++++++++++++++++++++++++++++  D A T A  S T R U C T U R E S  +++++++++++++++++++++++++++++++++/
004300240313//      NAME      I/O                                  DESCRIPTION                                 /
004400240313// -------------- --- ---------------------------------------------------------------------------- /
004500240313// AuditData1     Out The data for the Account Type (Financial Class) file that is saved to the    /
004600240313//                    customer audit file (Mxx.AUDM).                                              /
004700240313// AuditData2     Out The data for the Account Type-Pay Code Changes file that is saved to the     /
004800240313//                    customer audit file (Mxx.AUDM).                                              /
004900240313// AudtDta1       I/O Stores the file data that corresponds to the screen data. This allows for    /
005000240313//                    the comparison of the screen data to the file data to see if it changed.     /
005100240313// AudtDta2       I/O Stores the screen data that corresponds to the file data.                    /
005200240313// AudtDta3       I/O Stores the file data that is going to be deleted from Account Type-Pay Code  /
005300240313//                    Change file, which is written to the audit file before it is deleted.        /
005400240313// DataIn         In  Allows the data to be retrieved from the input file by the SQL processing.   /
005500240313// MyLDA          In  Holds the data that is read in from the Local Data Area (LDA).               /
005600240313// WSInd          In  Since INDARA is used in the display file, mapping of the indicators must be  /
005700240313//                    done  in the program.  The indicators for the display are now accessed using /
005800240313//                    the  data structure. Turning on an indicator in the data structure will not  /
005900240313//                    turn on the corresponding *INxx indicator.                                   /
006000240313//                                                                                                 /
006100240313//+++++++++++++++++++++++++++++++++++++  C O N S T A N T S   ++++++++++++++++++++++++++++++++++++++/
006200240313//      NAME                                          DESCRIPTION                                  /
006300240313// --------------   ------------------------------------------------------------------------------ /
006400240313// ADD            - Add a record to the miscellaneous codes maintenance file                       /
006500240313// CHANGE         - Change a record in the miscellaneous codes maintenance file                    /
006600240313// DELETE         - Delete a record fromthe miscellaneous codes maintenance file                   /
006700240313// DISPLAY        - Display the data for the account type code                                     /
006800240313// ERROR          - Message passed back from program called is an error message                    /
006900240313// EXIT           - F03 passed back from calling program                                           /
007000240313// RECID          - Record identification                                                          /
007100240313// RTVBYCODE      - Retrieve records from file using miscellaneous code                            /
007200240313// RTVBYDESC      - Retrieve records from file using code description                              /
007300240313// RTVBYSRCH      - Retrieve records from file using search string                                 /
007400240313// SYSKEY         - System file key used to look up provider account information                   /
007500240313// YES            - Replacement for Y                                                              /
007600240313//                                                                                                 /
007700240313//++++++++++++++++++++++++++++++++++++++  V A R I A B L E S  ++++++++++++++++++++++++++++++++++++++/
007800240313//      NAME                                          DESCRIPTION                                  /
007900240313// --------------   ------------------------------------------------------------------------------ /
008000240313// AccTypF        - Override Mxx.ATM to this account type file name                                /
008100240313// CompanyName    - Name of the company who's data is being presented                              /
008200240313// SavRRN         - Save of the main display relative record number                                /
008300240313// ShowScreen     - Keeps track of what record format the screen is showing                        /
008400240313//                                                                                                 /
008500240313//++++++++++++++++++++  F U N C T I O N  K E Y S  A N D  I N D I C A T O R S  +++++++++++++++++++++/
008600240313//     NAME                                         DESCRIPTION                                    /
008700240313// ----------   ---------------------------------------------------------------------------------- /
008800240313// F1_Help    - Context sensitive help                                                             /
008900240313// F3_Exit    - Exit program                                                                       /
009000240313// F5_Refresh - Refresh the screen, setting it back to the way it looked when called initially     /
009100240313// F6_AddCode - Add a new account type code to the Account Type Financial Class file               /
009200240313// F11_Toggle - Toggle between the code and code description to sort and search on                 /
009300240313// F12_Cancel - Cancel current action and return to previous screen                                /
009400240313// F14_Toggle - Toggle between showing all accounts and showing only active accounts               /
009500240313// F16_BilDys - Call the Initial Billing Days After DOS program MCM0103R                           /
009600240313// F24_MorKys - Loop through the available function keys                                           /
009700240313// SFNxChg_25 - Mark subfile field as changed (SFLNXTCHG)                                          /
009800240313// ProtFld_28 - Protect the field from changes                                                     /
009900240313// InzSubF_29 - Initailze subfile (SFLINZ)                                                         /
010000240313// ClrSubF_30 - Subfile clear (SFLCLR)                                                             /
010100240313// DspCtlR_31 - Subfile Display Control (SFLDSPCTL)                                                /
010200240313// SortCol_34 - Highlight the column haeader of the data that is being sorted on                   /
010300240313// ScanMod_35 - Indicates that the search is in scan mode                                          /
010400240313// AddCode_36 - Add a new accounting type code                                                     /
010500240313// Inactiv_37 - Show/Hide inactive accounts                                                        /
010600240313// OnlyAct_38 - Show all or only active accounts                                                   /
010700240313// SubFEnd_39 - Display subfile more/bottom                                                        /
010800240313// OptNbrE_40 - Invalid option number entered                                                      /
010900240313// DataErr_89 - Data error found                                                                   /
011000240313// NxtFKys_91 - Show the next set of available function keys                                       /
011100240313//                                                                                                 /
011200240313//+++++++++++++++++++++++++++++++++  M O D I F I C A T I O N S  +++++++++++++++++++++++++++++++++++/
011300240313// DATE..: MM/DD/CCYY   PROGRAMMER: First and last name                                            /
011400240313// REASON: Project number or ticket number                                                         /
011500240313// MODS..: What changes were made to the program                                                   /
011600240313//*************************************************************************************************/
011700240313
011800240416// Passed parameters................................................................................
011900240416Dcl-PI *n;
012000240416  RetFncKey Char( 3);
012100240416  RetMsgTyp Char( 3);
012200240416  RetPgmMsg Char(78);
012300240416End-PI;
012400240416
012500240313// Declare, override and open files.................................................................
012600240313Dcl-F ATM  Disk Keyed Qualified Usage(*DELETE : *OUTPUT) ExtDesc('MXX.ATM') ExtFile(AccTypF) UsrOpn;
012700240313Dcl-F ATP1 Disk Keyed Qualified Usage(*DELETE) ExtDesc('MXX.ATP1') ExtFile(AcTyPyCdF) UsrOpn;
012800240313Dcl-F PAYD Disk Keyed Qualified Usage(*INPUT ) ExtDesc('MXX.PAYD') ExtFile(PayCodeF)  UsrOpn;
012900240313Dcl-F DSP  WorkStn Qualified ExtDesc('MCM0100D') ExtFile(*ExtDesc) InDDS(WsInd)
013000240313           SFile(MCM0100SF : SFRRN);
013100240313
013200240313// Data structure templates to deifine record formats...............................................
013300240313Dcl-DS ATM_T  LikeRec(ATM.ATMR       : *All) Template;
013400240313Dcl-DS ATP1_T LikeRec(ATP1.ATPR      : *All) Template;
013500240313Dcl-DS CTL_T  LikeRec(DSP.MCM0100CTL : *All) Template;
013600240313Dcl-DS FKYS_T LikeRec(DSP.MCM0100FKY : *All) Template;
013700240313Dcl-DS MSGC_T LikeRec(DSP.MSGCTL     : *All) Template;
013800240313Dcl-DS PAYD_T LikeRec(PAYD.PAYDR     : *All) Template;
013900240313Dcl-DS SFL_T  LikeRec(DSP.MCM0100SF  : *All) Template;
014000240313
014100240313// Like data structures used for the reading and writing of data....................................
014200240313Dcl-DS ATM_R  LikeDS(ATM_T );          // Accounting type (financial class)file record format
014300240313Dcl-DS ATP1_R LikeDS(ATP1_T);          // Account type pay code changes file record format
014400240313Dcl-DS CTL_R  LikeDS(CTL_T );          // Account type code selection screen control record format
014500240313Dcl-DS FKYS_R LikeDS(FKYS_T);          // Function keys screen record format
014600240313Dcl-DS MSGC_R LikeDS(MSGC_T);          // Error message screen record format
014700240313Dcl-DS PAYD_R LikeDS(PAYD_T);          // Pay code description file record format
014800240313Dcl-DS SFL_R  LikeDS(SFL_T );          // Accounting type code selection subfile record format
014900240313
015000240313// Define data structure for reading of batch control file using SQL................................
015100240313Dcl-DS DataIn ExtName('MXX.ATM') Qualified End-DS;
015200240313
015300240313// Functions keys and indicators data structure.....................................................
015400240313Dcl-DS WsInd Len(99);
015500240313  FuncKeyInd Char(24) Pos(01);         // Function key indicators...................................
015600240313    F3_Exit    Ind Pos(03);            // End program
015700240313    F4_Prompt  Ind Pos(04);            // A pop-up window which allows selection and return of data
015800240313    F5_Refresh Ind Pos(05);            // Refresh the data on the screen
015900240313    F6_AddCode Ind Pos(06);            // Add code to the Account Type file
016000240313    F11_Toggle Ind Pos(11);            // Toggle between the acct code and acct code description
016100240313    F12_Cancel Ind Pos(12);            // Cancel out of current window
016200240313    F14_Toggle Ind Pos(14);            // Toggle between showing all and only active pay codes
016300240313    F16_BilDys Ind Pos(16);            // Call the Initial Billing Days After DOS program MCM0103R
016400240313    F24_FunKys Ind Pos(24);            // Loop through the available function keys
016500240313  ScreenInd  Char(15) Pos(25);         // Screen manipulation indicators............................
016600240313    SFNxChg_25 Ind Pos(25);            // Mark subfile field as changed (SFLNXTCHG)
016700240313    ProtFld_28 Ind Pos(28);            // Protect the field from being changed
016800240313    InzSubF_29 Ind Pos(29);            // Initailze subfile (SFLINZ)
016900240313    ClrSubF_30 Ind Pos(30);            // Subfile clear (SFLCLR)
017000240313    DspCtlR_31 Ind Pos(31);            // Subfile Display Control (SFLDSPCTL)
017100240313    DspSubF_32 Ind Pos(32);            // Subfile Display (SFLDSP)
017200240313    SortCol_34 Ind Pos(34);            // Column subfile data is being sorted by when color pink
017300240313    ScanMod_35 Ind Pos(35);            // Indicates that the search is in scan mode
017400240313    AddCode_36 Ind Pos(36);            // Add a new account type code
017500240313    Inactiv_37 Ind Pos(37);            // Highlight inactive accounts
017600240313    OnlyAct_38 Ind Pos(38);            // Show all or only active accounts
017700240313    SubFEnd_39 Ind Pos(39);            // Subfile End (SFLEND)
017800240313  FldErrInd  Char(50) Pos(40);         // Error indicators..........................................
017900240313    OptNbrE_40 Ind Pos(40);            // Option number entered
018000240313    DataErr_89 Ind Pos(89);            // Data error found
018100240313  ProgramInd Char(10) Pos(90);         // Program flow indicators...................................
018200240313    NxtFKys_91 Ind Pos(91);            // Show the next set of available function keys
018300240313End-DS WsInd;
018400240313
018500240313// Declare data structures to store audit data......................................................
018600240313Dcl-DS AuditData1 Qualified;
018700240313  ATMAType  Like(ATM_R.ATMATYPE );     // Account Type
018800240313  ATMADesc  Like(ATM_R.ATMADESC );     // Type Description
018900240313  ATMAbrDsc Like(ATM_R.ATMABRDSC);     // Abbreviated Desc
019000240313  ATMAcrnym Like(ATM_R.ATMACRNYM);     // Acronym
019100240313  ATMInsFm  Like(ATM_R.ATMINSFM );     // Ins Claim (D,W,,M,N)
019200240313  ATMInsTyp Like(ATM_R.ATMINSTYP);     // Ins Type (0-7)
019300240313  ATMStmTyp Like(ATM_R.ATMSTMTYP);     // Stmnt Type (N,M,S)
019400240313  ATMMsgCr  Like(ATM_R.ATMMSGCR );     // Current Msg
019500240313  ATMMsg30  Like(ATM_R.ATMMSG30 );     // 30 Days Msg
019600240313  ATMMsg60  Like(ATM_R.ATMMSG60 );     // 60 Days Msg
019700240313  ATMMsg90  Like(ATM_R.ATMMSG90 );     // 90 Days Msg
019800240313  ATMMsg120 Like(ATM_R.ATMMSG120);     // 120 Days Msg
019900240313  ATMMsgDl  Like(ATM_R.ATMMSGDL );     // Delinquent Msg
020000240313  ATMDays48 Like(ATM_R.ATMDAYS48);     // Days Old for 48 Hr Not
020100240313  ATMStmt48 Like(ATM_R.ATMSTMT48);     // Print 48 Hr Stmt
020200240313  ATMPaper  Like(ATM_R.ATMPAPER );     // Paper Claim Only
020300240313  ATMAssign Like(ATM_R.ATMASSIGN);     // Accept Assignment-YN
020400240313  ATMOlDl   Like(ATM_R.ATMOLDL  );     // Days Old For Del Not
020500240313  ATMStmtDl Like(ATM_R.ATMSTMTDL);     // Print Stmt w/Delinq
020600240313  ATMColOld Like(ATM_R.ATMCOLOLD);     // Days Old for Collect
020700240313  ATMColStm Like(ATM_R.ATMCOLSTM);     // Print Stmt w/Coll
020800240313  ATMInitSt Like(ATM_R.ATMINITST);     // Days Old for 1st Stmt
020900240313  ATMIntMsg Like(ATM_R.ATMINTMSG);     // First Stmt After Msg
021000240313  ATMErrLvl Like(ATM_R.ATMERRLVL);     // Error Level
021100240313  ATMMsgFn  Like(ATM_R.ATMMSGFN );     // Final Notice Msg
021200240313  ATMFrmCd  Like(ATM_R.ATMFRMCD );     // Form Type Code
021300240313  ATMATMInt Like(ATM_R.ATMATMINT);     // Chg Int this Type
021400240313  ATMDatChg Like(ATM_R.ATMDATCHG);     // Last Change Date
021500240313  ATMUsrChg Like(ATM_R.ATMUSRCHG);     // Last Change User
021600240313  ATMOBRIRC Like(ATM_R.ATMOBRIRC);     // OBRA/IRCA? Y/N
021700240313  ATMATRfRq Like(ATM_R.ATMATRFRQ);     // Refer Phy Reqd-Y/N
021800240313  ATMSumTyp Like(ATM_R.ATMSUMTYP);     // Summary Account Type
021900240313  ATMInacDt Like(ATM_R.ATMINACDT);     // Inactive Date
022000240313End-DS AuditData1;
022100240313
022200240313Dcl-DS AuditData2 Qualified;
022300240313  ATPAType  Like(ATM_R.ATMATYPE  );    // Account type
022400240313  ATMADesc  Like(ATM_R.ATMADESC  );    // Account type description
022500240313  ATPPayCd  Like(ATP1_R.ATPPAYCD );    // Pay code
022600240313  PADesc    Like(ATM_R.ATMADESC  );    // Pay code description
022700240313  ATPChgTyp Like(ATP1_R.ATPCHGTYP);    // Change to account type
022800240313  ChgTypDsc Like(ATM_R.ATMADESC  );    // Change to account type description
022900240313  ATPDatChg Like(ATM_R.ATMDATCHG );    // Last Change Date
023000240313  ATPUsrChg Like(ATM_R.ATMUSRCHG );    // Last Change User
023100240313End-DS AuditData2;
023200240313
023300240313// Data structures used to see if the screen and file data are the same.............................
023400240313Dcl-DS AudtDta1 LikeDS(AuditData1);
023500240313Dcl-DS AudtDta2 LikeDS(AuditData1);
023600240313
023700240313// Data structure used to save the audit data for deleted account type pay code changes data........
023800240313Dcl-DS AudtDta3 LikeDS(AuditData2);
023900240313
024000240313// Declare data structre for reading in the Local Data Area (LDA)...................................
024100240313Dcl-DS MyLDA DtaAra(*LDA) Qualified;
024200240313  Entity   Char(3)  Pos(137);          // Used to open the correct account type file
024300240313  Group    Char(2)  Pos(138);          // Used as key to lookup customer information
024400240313  DeviceID Char(2)  Pos(494);          // Last two characters of device name
024500240313  UserID   Char(10) Pos(496);          // User identification of person running the job
024600240313  Customer Char(50) Pos(951);          // Customer company name
024700240313End-DS;
024800240313
024900240313// Declare constatnts...............................................................................
025000240313Dcl-C ADD       Const('ADD');
025100240313Dcl-C CHANGE    Const('CHG');
025200240313Dcl-C DELETE    Const('DLT');
025300240313Dcl-C DISPLAY   Const('DSP');
025400240313Dcl-C ERROR     Const('ERR');
025500240313Dcl-C EXIT      Const('F03');
025600240313Dcl-C RECID     Const('01');
025700240313Dcl-C RTVBYCODE Const('CODE');
025800240313Dcl-C RTVBYDESC Const('DESC');
025900240313Dcl-C RTVBYSRCH Const('SRCH');
026000240313Dcl-C SYSKEY    Const('01');
026100240313Dcl-C YES       Const('Y');
026200240313
026300240313// Declare variables...............................................................................
026400240313Dcl-S AccTypF     Char(10)      Inz;
026500240313Dcl-S AcTyPyCdF   Char(10)      Inz;
026600240313Dcl-S CompanyName Char(50)      Inz;
026700240313Dcl-S PayCodeF    Char(10)      Inz;
026800240313Dcl-S SavRRN      Packed(4:0);
026900240313Dcl-S SFRRN       Packed(4:0);
027000240313
027100240313// Prototype-Lookup the financial class account type from the Account Type file.....................
027200240313/COPY QCPYSRC,D_ACCTYPLU
027300240313
027400240313// Data structure-Contains any API interface errors.................................................
027500240313/COPY QCPYSRC,D_APIErrDS
027600240313
027700240313// Prototype-Account type Data detail maintenance...................................................
027800240313/COPY QCPYSRC,D_MCM0101R
027900240313
028000240313// Prototype-Initial billing days after the date of service.........................................
028100240313/COPY QCPYSRC,D_MCM0103C
028200240313
028300240313// Prototype-Send program message and clear program message queue...................................
028400240313/COPY QCPYSRC,D_PGMMSGS
028500240313
028600240313// Data structure-Contains the program information..................................................
028700240313/COPY QCPYSRC,D_PGMSTSDS
028800240313
028900240313// Constants and data structures-Human readable form of the message ID's and custom message parms...
029000240313/COPY QCPYSRC,D_PMSGIDS
029100240313
029200240313// Prototype-Retrieve security data from the User/Program Security file.............................
029300240313/COPY QCPYSRC,D_RTVSECDT
029400240313
029500240313// Prototype-Retrieve system control data from the System Control file..............................
029600240313/COPY QCPYSRC,D_RTVSYSDT
029700240313
029800240313// Prototype-Write the audit data to the correct audit file.........................................
029900240313/COPY QCPYSRC,D_WRTAUDTA
030000240313
030100240313//**************************************************************************************************
030200240313//************************************  M A I N  P R O G R A M  ************************************
030300240313//**************************************************************************************************
030400240313
030500240313// Stuff that only needs to be done once when the program is first run..............................
030600240313ProgramEntry();
030700240313
030800240313// Process the screen until F3 is pressed...........................................................
030900240313DoU F3_Exit or F12_Cancel;
031000240313
031100240313  // Display the account type code selection screen.................................................
031200240313  CTL_R.CompName = CompanyName;
031300240313  SubFEnd_39 = *ON;
031400240313  Write DSP.MCM0100FKY FKYS_R;
031500240313  Write DSP.MSGCTL MSGC_R;
031600240313  ExFmt DSP.MCM0100CTL CTL_R;
031700240313
031800240313  // Reset the error indicators and clear out any previously displayed messages.....................
031900240313  FldErrInd  = *OFF;
032000240313  ClrMsgQ(MsgQ_Cur : MsgQNbr_Cur : MsgKey_All :  MsgRmv_All : APIErrC);
032100240313
032200240313  // F3 - Exit out of program.......................................................................
032300240313  Select;
032400240313  When F3_Exit;
032500240313    Leave;
032600240313
032700240313  // F5 - Refresh the screen to appear as it did initially..........................................
032800240313  When F5_Refresh;
032900240313    Clear CTL_R.SRCH4TEXT;                       // Clear out any search values
033000240313    Clear SFL_R;                                 // Clear out option data entered
033100240313    ClrSFData();                                 // Clear out subfile data
033200240313    SortCol_34 = *ON;                            // Set to sort on code column indicator
033300240313    ScanMod_35 = *OFF;                           // Turn off scan mode
033400240313    OnlyAct_38 = *OFF;                           // Turn off show only active accounts
033500240313    RtvAccTypCds(RTVBYCODE);
033600240313
033700240313  // F6 - Add a new code to the Account Type (Financial Class) file.................................
033800240313  When F6_AddCode;
033900240313    If not ProtFld_28;                           // Must have the security to add codes
034000240313      ProcAccTyp(MyLDA.Group : SFL_R.ATMATYPE : ADD : PAT.RetFncKey : PAT.RetMsgTyp : PAT.RetPgmMsg);
034100240313      If PAT.RetFncKey = EXIT;                   // Exit out of program passed back
034200240313        Leave;
034300240313      ElseIf PAT.RetPgmMsg <> *BLANKS;
034400240313        CPF9898.Field1 = PAT.RetPgmMsg;
034500240313        SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
034600240313                   MsgQNbr_Cur : MsgKey : APIErrC);
034700240313        If PAT.RetMsgTyp = ERROR;                // Error message passed back from program called
034800240313          DataErr_89 = *ON;
034900240313        EndIf;
035000240313      Else;                                      // Set everything back to its initial state
035100240313        Clear CTL_R.SRCH4TEXT;                   // Clear out any search values
035200240313        Clear SFL_R;                             // Clear out option data entered
035300240313        ClrSFData();                             // Clear out subfile data
035400240313        SortCol_34 = *ON;                        // Set to sort on code column indicator
035500240313        ScanMod_35 = *OFF;                       // Turn off scan mode
035600240313        OnlyAct_38 = *OFF;                       // Turn off show only active accounts
035700240313        RtvAccTypCds(RTVBYCODE);
035800240313      EndIf;
035900240313    Else;
036000240313      SndPgmMsg(Err_CodeAdd : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
036100240313                 MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC);
036200240313      DataErr_89 = *ON;
036300240313    EndIf;
036400240313
036500240313  // F11 - Toggle between sorting by code and sorting by description................................
036600240313  When F11_Toggle;
036700240313    ClrSFData();
036800240313    If SortCol_34 = *ON;                         // Data currently sorting by code
036900240313      SortCol_34 = *OFF;                         // Change the description column header to pink
037000240313      If %SubSt(CTL_R.SRCH4TEXT:1:1) = '?';      // Data is being retrieved by character match
037100240313        ScanMod_35 = *ON;                        // Show scan mode on the display
037200240313        RtvAccTypCds(RTVBYSRCH);                 // Retrieve data by scan method
037300240313      Else;
037400240313        ScanMod_35 = *OFF;                       // Turn off scan mode notification on screen
037500240313        RtvAccTypCds(RTVBYDESC);                 // Retrieve data by description
037600240313      EndIf;
037700240313    Else;
037800240313      SortCol_34 = *ON;                          // Change the code column header to pink
037900240313      If %SubSt(CTL_R.SRCH4TEXT:1:1) = '?';      // Data is being retrieved by character match
038000240313        ScanMod_35 = *ON;                        // Show scan mode on the display
038100240313        RtvAccTypCds(RTVBYSRCH);                 // Retrieve data by scan method
038200240313      Else;
038300240313        ScanMod_35 = *OFF;                       // Stop showing scan mode on the display
038400240313        RtvAccTypCds(RTVBYCODE);                 // Retrieve data by code
038500240313      EndIf;
038600240313    EndIf;
038700240313    If CTL_R.SRCH4TEXT <> *BLANKS and not ScanMod_35;
038800240313      PositionTo();
038900240313    EndIf;
039000240313
039100240313  // F12 - Go back to previous screen (exit the program since this is the first screen).............
039200240313  When F12_Cancel;
039300240313    Leave;
039400240313
039500240313  // F14 - Toggle between displaying all account type codes and active account type codes...........
039600240313  When F14_Toggle;
039700240313    ClrSFData();
039800240313    If OnlyAct_38 = *OFF;                        // Currently not showing inactive accounts
039900240313       OnlyAct_38 = *ON;
040000240313    Else;
040100240313       OnlyAct_38 = *OFF;
040200240313    EndIf;
040300240313    If SortCol_34 = *ON;                         // Currently sorting by code
040400240313      If %SubSt(CTL_R.SRCH4TEXT:1:1) = '?';      // Data is being retrieved by character match
040500240313        ScanMod_35 = *ON;                        // Show scan mode notification on screen
040600240313        RtvAccTypCds(RTVBYSRCH);                 // Retrieve data by scan method
040700240313      Else;
040800240313        ScanMod_35 = *OFF;                       // Turn off scan mode notification on screen
040900240313        RtvAccTypCds(RTVBYDESC);                 // Retrieve data by description
041000240313      EndIf;
041100240313    Else;
041200240313      If %SubSt(CTL_R.SRCH4TEXT:1:1) = '?';      // Data is being retrieved by character match
041300240313        ScanMod_35 = *ON;                        // Show scan mode notification on screen
041400240313        RtvAccTypCds(RTVBYSRCH);                 // Retrieve data by scan method
041500240313      Else;
041600240313        ScanMod_35 = *OFF;                       // Turn off scan mode notification on screen
041700240313        RtvAccTypCds(RTVBYCODE);                 // Retrieve data by description
041800240313      EndIf;
041900240313    EndIf;
042000240313    If CTL_R.SRCH4TEXT <> *BLANKS and not ScanMod_35;
042100240313      PositionTo();
042200240313    EndIf;
042300240313
042400240313  // F16 - Execute program initial billing days after date of service...............................
042500240313  When F16_BilDys;
042600240313    InitBillDys(MyLDA.Entity : PAT.RetFncKey);
042700240313    If PAT.RetFncKey=EXIT;                       // If exit passed back by program called, then exit
042800240313      Leave;                                     // out of this program
042900240313    EndIf;
043000240313
043100240313  // F24 - Rotate displaying the different function keys............................................
043200240313  When F24_FunKys;
043300240313    If NxtFKys_91 = *OFF;
043400240313      NxtFKys_91 = *ON;
043500240313    Else;
043600240313      NxtFKys_91 = *OFF;
043700240313    EndIf;
043800240313
043900240313  // Enter - Process all option numbers entered.....................................................
044000240313  Other;
044100240313    ProcessScreen();
044200240313    If F3_Exit;                                  // If exit passed back by program called, then exit
044300240313      Leave;                                     // out of this program
044400240313    EndIf;
044500240313  EndSL;
044600240313
044700240313EndDo;                                           // DoU F3_Exit or F12_Cancel
044800240313
044900240313// Close files that were opened by this program.....................................................
045000240313CloseOpenFiles();
045100240313
045200240313//--------------------------------------------------------------------------------------------------
045300240313//- SUBPROCEDURE: ProgramEntry                                                                     -
045400240313//- FUNCTION....: Tasks Done When The Prorgam Is First Run                                         -
045500240313//- EXPLANATION.: Process all of the tasks that only need to done when the program is first run.   -
045600240313//-               Such as, getting user privileges, opening files, initializing variables, etc.    -
045700240313//--------------------------------------------------------------------------------------------------
045800240313Dcl-Proc ProgramEntry;
045900240313
046000240313  // Going down one level in the message queue......................................................
046100240313  MsgQNbr_Cur += 1;
046200240313
046300240313  // Set program name for error message screen and initialize the error message screen..............
046400240313  *INLR = *ON;
046500240313  MSGC_R.PGMNAME = PgmName;                      // Required because of screen record format DS
046600240313  ClrMsgQ(MsgQ_Cur : MsgQNbr_Cur : MsgKey_All :  MsgRmv_All : APIErrC);
046700240313
046800240313  // Retrieve the user security information from the program security file..........................
046900240313  RtvSecDta(PgmName : JobUser : RSECD.SecFileDta : RSECD.ErrorMsg);
047000240313  If RSECD.ErrorMsg = *BLANKS;
047100240313    If RSECD.SecFileDta.SEC02 <> YES;            // Pay code data edit security
047200240313      ProtFld_28 = *ON;                          // Do not allow editing of pay code data
047300240313    EndIf;
047400240313  Else;
047500240313    CPF9898.Field1 = RSECD.ErrorMsg;
047600240313    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
047700240313               MsgQNbr_Cur : MsgKey : APIErrC);
047800240313    ProtFld_28 = *ON;
047900240313    DataErr_89 = *ON;
048000240313  EndIf;
048100240313
048200240313  // Open the customer Account Type (Financial Class) file..........................................
048300240313  In MyLDA;
048400240313  If %Len(%Trim(MyLDA.Entity)) = 3;
048500240313    AccTypF = MyLDA.Entity + '.ATM';
048600240313    If not %Open(ATM);
048700240313      Open(E) ATM;
048800240313      If %Error;
048900240313        CPF9898.Field1 = 'The program could not open the file ' + AccTypF + '. Contact IT for help';
049000240313        SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
049100240313                   MsgQNbr_Cur : MsgKey : APIErrC);
049200240313        DataErr_89  = *ON;
049300240313      EndIf;
049400240313    EndIf;
049500240313
049600240313    // Open the customer Account Type-Pay Code Changes by Type,Pay Cd file..........................
049700240313    AcTyPyCdF = MyLDA.Entity + '.ATP1';
049800240313    If not %Open(ATP1);
049900240313      Open(E) ATP1;
050000240313      If %Error;
050100240313        CPF9898.Field1 = 'The program could not open the file ' + AcTyPyCdF + '. Contact IT for help';
050200240313        SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
050300240313                   MsgQNbr_Cur : MsgKey : APIErrC);
050400240313        DataErr_89  = *ON;
050500240313      EndIf;
050600240313    EndIf;
050700240313
050800240313    // Open the pay code description file...........................................................
050900240313    PayCodeF = MyLDA.Entity + '.PAYD';
051000240313    If not %Open(PAYD);
051100240313      Open(E) PAYD;
051200240313      If %Error;
051300240313        CPF9898.Field1 = 'The program could not open the file ' + PayCodeF + '. Contact IT for help';
051400240313        SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
051500240313                   MsgQNbr_Cur : MsgKey : APIErrC);
051600240313        DataErr_89  = *ON;
051700240313      EndIf;
051800240313    EndIf;
051900240313
052000240313  Else;
052100240313    CPF9898.Field1 = 'LDA missing data. Cannot open correct file. Contact IT for help';
052200240313    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
052300240313               MsgQNbr_Cur : MsgKey : APIErrC);
052400240313    DataErr_89  = *ON;
052500240313  EndIf;
052600240313
052700240313  // Retrieve the customer company and center it in the field.......................................
052800240313  RtvSysDta(MyLDA.Group : SYSKEY : RSYSD.SysFileDta : RSYSD.ErrorMsg);
052900240313  If RSYSD.ErrorMsg = *BLANKS;
053000240313    CompanyName = CenterText(RSYSD.SysFileDta.SYSNAM);
053100240313  Else;
053200240313    CPF9898.Field1 = RSYSD.ErrorMsg;
053300240313    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
053400240313               MsgQNbr_Cur : MsgKey : APIErrC);
053500240313    DataErr_89 = *ON;
053600240313  EndIf;
053700240313
053800240313  // Load the file data to the screen...............................................................
053900240313  InzSubFile();
054000240313  ClrSFData();
054100240313  SortCol_34 = *ON;
054200240313  RtvAccTypCds(RTVBYCODE);
054300240313
054400240313  // Going up one level in the message queue........................................................
054500240313  MsgQNbr_Cur -= 1;
054600240313
054700240313End-Proc ProgramEntry;
054800240313
054900240313//--------------------------------------------------------------------------------------------------
055000240313//- SUBPROCEDURE: InzSubFile                                                                       -
055100240313//- FUNCTION....: Initialize The Fields In The Subfile                                             -
055200240313//- EXPLANATION.: Set all the input capable fields to their default values.                        -
055300240313//--------------------------------------------------------------------------------------------------
055400240313Dcl-Proc InzSubFile;
055500240313
055600240313  // Set the indicators to initialize the subfile display...........................................
055700240313  InzSubF_29   = *ON;
055800240313  CTL_R.SFREC# = 1;
055900240313
056000240313  // Write the subfile control record to clear out the subfile display..............................
056100240313  Write DSP.MCM0100CTL CTL_R;
056200240313
056300240313  // Set indicators and fields to show that the subfile is empty....................................
056400240313  InzSubF_29 = *OFF;
056500240313  DspCtlR_31 = *ON;
056600240313  DspSubF_32 = *ON;
056700240313
056800240313End-Proc InzSubFile;
056900240313
057000240313//--------------------------------------------------------------------------------------------------
057100240313//- SUBPROCEDURE: ClrSubFile                                                                       -
057200240313//- FUNCTION....: Clear Out The Data In Subfile Display                                            -
057300240313//- EXPLANATION.: Remove all the data in the display subfile so that it does not contain any data  -
057400240313//-               before more data is written to the subfile.                                      -
057500240313//--------------------------------------------------------------------------------------------------
057600240313Dcl-Proc ClrSFData;
057700240313
057800240313  // Set the indicators to clear out the subfile display............................................
057900240313  ClrSubF_30 = *ON;
058000240313  DspCtlR_31 = *OFF;
058100240313  DspSubF_32 = *OFF;
058200240313
058300240313  // Write the subfile control record to clear out the subfile display..............................
058400240313  Write DSP.MCM0100CTL CTL_R;
058500240313
058600240313  // Set indicators and fields to show that the subfile is empty....................................
058700240313  ClrSubF_30   = *OFF;
058800240313  DspCtlR_31   = *ON;
058900240313  SavRRN       = *ZERO;
059000240313  CTL_R.SFREC# = *ZERO;
059100240313  SFRRN        = *ZERO;
059200240313  SubFEnd_39   = *OFF;
059300240313
059400240313End-Proc ClrSFData;
059500240313
059600240313//--------------------------------------------------------------------------------------------------
059700240313//- SUBPROCEDURE: RtvAccTypCds                                                                     -
059800240313//- FUNCTION....: Retrieve Data To Load Into The Subfile Display                                   -
059900240313//- EXPLANATION.: Retrieve the data from the Account Type file to populate the subfile display.    -
060000240313//-               For the initial screen, the code header will be highlighted and the data will    -
060100240313//-               be sorted by the code. Additionally, the data can be sorted by the code          -
060200240313//-               description. Also, there is the ability to populate the subfile display based    -
060300240313//-               upon matching the search characters with characters in the code or code          -
060400240313//-               description. This is accomplished by placing a question mark at the beginning of -
060500240313//-               the characters in the search field. The SFLEND indicator is set ON so that the   -
060600240313//-               display will handle the MORE and BOTTOM that appear at the end of the subfile    -
060700240313//-               display.                                                                         -
060800240313//-                                                                                                -
060900240313//- - - - - - - - - - - - - - - - - -   P A R A M E T E R S  - - - - - - - - - - - - - - - - - - - -
061000240313//      Name      I/O                                  Description                                 -
061100240313// -------------- --- ---------------------------------------------------------------------------- -
061200240313//- HowToRtv      In  How the data is to be retrieved: By code, description or search string       -
061300240313//-                                                                                                -
061400240313//- - - - - - - - - - - - - - - - - - -  C O N S T A N T S   - - - - - - - - - - - - - - - - - - - -
061500240313//-      Name                                          Description                                 -
061600240313//- --------------   ----------------------------------------------------------------------------- -
061700240313//- ASCENDING        Sort the returned SQL data in ascending sequence                              -
061800240313//- DESCENDING       Sort the returned SQL data in descending sequence                             -
061900240313//- MAXSFREC         Maximum number of records in the main subfile                                 -
062000240313//- SPACE            Used to put spaces inbetween the different clauses of the SQL statement       -
062100240313//- SQLOK            Status of good SQL processing                                                 -
062200240313//- SQLEOF           SQL end of file indicator                                                     -
062300240313//- SQUOTE           Single quote to put around character values in the SQL statement              -
062400240313//-                                                                                                -
062500240313//- - - - - - - - - - - - - - - - - - -  V A R I A B L E S   - - - - - - - - - - - - - - - - - - - -
062600240313//-      Name                                          Description                                 -
062700240313//- --------------   ----------------------------------------------------------------------------- -
062800240313//- ForClause        Dynamic SQL FOR clause (not required; however, it is recommended)             -
062900240313//- GroupByClause    Dynamic SQL GROUP BY clause used to get unique values for the field           -
063000240313//- OrderByClause    Dynamic SQL ORDER BY clause (not required)                                    -
063100240313//- SelectClause     Dynamic SQL SELECT clause (also update, delete, etc)                          -
063200240313//- SortSeq          Sequence in which the data is sorted (ascending or descending)                -
063300240313//- SQLStmt          Complete dynamic SQL stament to be executed                                   -
063400240313//- WhereClause      Dynamic SQL WHERE clause                                                      -
063500240313//--------------------------------------------------------------------------------------------------
063600240313Dcl-Proc RtvAccTypCds;
063700240313
063800240313  // Parameters passed..............................................................................
063900240313  Dcl-PI *n;
064000240313    HowToRtv Char(4) Value;
064100240313  End-PI;
064200240313
064300240313  // Declare constants..............................................................................
064400240313  Dcl-C ASCENDING  Const('ASC');
064500240313  Dcl-C DESCENDING Const('DESC');
064600240418  Dcl-C MAXSFREC   Const(1200);
064700240313  Dcl-C SPACE      Const(' ');
064800240313  Dcl-C SQLOK      Const('00000');
064900240313  Dcl-C SQLEOF     Const('02000');
065000240313  Dcl-C SQUOTE     Const('''');
065100240313
065200240313  // Declare standalone variables...................................................................
065300240313  Dcl-S ForClause     Char( 64);
065400240313  Dcl-S GroupByClause Char(128);
065500240313  Dcl-S OrderByClause Char(128);
065600240313  Dcl-S SelectClause  Char(256);
065700240313  Dcl-S SortSeqAsc    Char(  4)  Inz(ASCENDING);
065800240313  Dcl-S SortSeqDsc    Char(  4)  Inz(DESCENDING);
065900240313  Dcl-S SQLStmt       Char(1024);
066000240313  Dcl-S WhereClause   Char(256);
066100240313
066200240313  // Going down one level in the message queue......................................................
066300240313  MsgQNbr_Cur += 1;
066400240313
066500240313  // Build the SQL select clause....................................................................
066600240313  SelectClause = 'select * from "' + %Trim(AccTypF) + '"';
066700240313
066800240313  // Build the SQL where clause.....................................................................
066900240313  If HowToRtv = RTVBYSRCH;
067000240313    If SortCol_34 = *ON;
067100240313      WhereClause = 'where ATMATYPE like ';
067200240313    Else;
067300240313      WhereClause = 'where ATMADESC like ';
067400240313    EndIf;
067500240313      WhereClause = %Trim(WhereClause) + SPACE + SQUOTE + '%' + %Trim(CTL_R.SRCH4TEXT : '? ') +
067600240313                    '%' + SQUOTE;
067700240313  EndIf;
067800240313  If OnlyAct_38 = *ON and HowToRtv = RTVBYSRCH;                 // Show only active accounts
067900240313    WhereClause = %Trim(WhereClause) + ' and ATMINACDT = 0';
068000240313  ElseIf OnlyAct_38 = *ON;
068100240313    WhereClause = 'where ATMINACDT = 0';
068200240313  EndIf;
068300240313
068400240313  // Build the SQL group by clause(not needed)......................................................
068500240313  GroupByClause = SPACE;
068600240313
068700240313  // Build the SQL order by clause..................................................................
068800240313  If SortCol_34 = *ON;
068900240313    OrderByClause = 'order by ATMATYPE ' + SortSeqAsc;          // Order by account type code
069000240313  Else;
069100240313    OrderByClause = 'order by ATMADESC ' + SortSeqAsc;          // Order by account type code desc
069200240313  EndIf;
069300240313
069400240313  // Build the SQL for clause.......................................................................
069500240313  ForClause = 'for read only';
069600240313
069700240313  // Build the SQL statement separating each clause by a space......................................
069800240313  SQLStmt = %Trim(SelectClause) + SPACE + %Trim(WhereClause) + SPACE + %Trim(GroupByClause) +
069900240313            SPACE + %Trim(OrderByClause) + SPACE + %TrimR(ForClause);
070000240313
070100240313  // Commit must be set to none since table is not journaled........................................
070200240313  Exec SQL Set Option Commit = *NONE, Closqlcsr = *ENDMOD;
070300240313
070400240313  // Declare the cursor for dynamic SQL statement...................................................
070500240313  Exec SQL Declare InputFile cursor for DynSQLStmt;
070600240313
070700240313  // Prepare the declared dynamic SQL cursor to receive data........................................
070800240313  Exec SQL Prepare DynSQLStmt from :SQLStmt;
070900240313
071000240313  // Open the dynamic SQL cursor for reading of the data and check to see that data was retrieved...
071100240313  Exec SQL Open InputFile;
071200240313  If SQLState <> SQLOK;
071300240313    Wrn0000.Field1 = SQLStmt;
071400240313    SndPgmMsg(Wrn_NoDtaRt : MsgFile_Dft : Wrn0000 : %Len(Wrn0000) : MsgTy_Diag : MsgQ_Cur :
071500240313               MsgQNbr_Cur : MsgKey : APIErrC);
071600240313    DataErr_89 = *ON;
071700240313  EndIf;
071800240313
071900240313  // Read the file data into the data structure and write the data to the display subfile...........
072000240313  If SQLState = SQLOK and DataErr_89 = *OFF;
072100240313    Exec SQL Fetch next from InputFile into :DataIn;
072200240313
072300240313    DoW SQLState = SQLOK and SQLState <> SQLEOF and SFRRN <= MAXSFREC;
072400240313      SFRRN += 1;
072500240313      SFL_R.ATMATYPE = DataIn.ATMATYPE;
072600240313      SFL_R.ATMADESC = DataIn.ATMADESC;
072700240313      If DataIn.ATMINACDT = *ZERO;               // Active account type records
072800240313        SFL_R.ATMINACDT = DataIn.ATMINACDT;
072900240313        Inactiv_37 = *OFF;
073000240313      Else;                                      // Inactive account type records
073100240313        SFL_R.ATMINACDT = %Dec(%Char(%Date(DataIn.ATMINACDT:*ISO):*USA0):8:0);
073200240313        Inactiv_37 = *ON;                        // Make subfile line text red(Danger Will Robinson)
073300240313      EndIf;
073400240313      Write DSP.MCM0100SF SFL_R;
073500240313      Exec SQL Fetch next from InputFile into :DataIn;
073600240313    EndDo;
073700240313  EndIf;
073800240313
073900240313  // Close the cursor once all the file data has been read..........................................
074000240313  Exec SQL Close InputFile;
074100240313
074200240313  // No records read from input file, so show warning message.......................................
074300240313  If SQLState <> SQLOK;
074400240313    CPF9898.Field1 = 'No data found for account type code. Contact IT if problem persists';
074500240313    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
074600240313               MsgQNbr_Cur : MsgKey : APIErrC);
074700240313    DataErr_89  = *ON;
074800240313  EndIf;
074900240313
075000240313  // Disiplay the subfile even if it does not contain data..........................................
075100240313  DspSFData();
075200240313
075300240313  // Going up one level in the message queue........................................................
075400240313  MsgQNbr_Cur -= 1;
075500240313
075600240313End-Proc RtvAccTypCds;
075700240313
075800240313//--------------------------------------------------------------------------------------------------
075900240313//- SUBPROCEDURE: DspSFData                                                                        -
076000240313//- FUNCTION....: Display The Subfile                                                              -
076100240313//- EXPLANATION.: Set the indicators to display the subile even if it does not have any records.   -
076200240313//-               Note:  If you try to display an empty subfile that has not been initialized, the -
076300240313//-               program will error out.                                                          -
076400240313//--------------------------------------------------------------------------------------------------
076500240313Dcl-Proc DspSFData;
076600240313
076700240313  // Display the subfile if there are records to display............................................
076800240313  If SFRRN > *ZERO;
076900240313    DspSubF_32   = *ON;
077000240313    CTL_R.SFRec# = SavRRN + 1;
077100240313  Else;
077200240313    DspSubF_32   = *OFF;
077300240313    CTL_R.SFRec# = *ZERO;
077400240313  EndIF;
077500240313
077600240313  // Do not allow the subfile page to position beyond the last subfile page.........................
077700240313  If CTL_R.SFRec# > SFRRN;
077800240313    CTL_R.SFRec# = SavRRN;
077900240313  EndIf;
078000240313
078100240313  // Save the last subfile record to be able to position to the last subfile page...................
078200240313  SavRRN = SFRRN;
078300240313
078400240313End-Proc DspSFData;
078500240313
078600240313//--------------------------------------------------------------------------------------------------
078700240313//- SUBPROCEDURE: ProcessScreen                                                                    -
078800240313//- FUNCTION....: Process The Screen                                                               -
078900240313//- EXPLANATION.: Determine what needs to happen next from what was entered on the screen. You     -
079000240313//-               have the ability to position to a code or description, or select codes or select -
079100240313//-               codes or desctiptions based upon finding the matching characters that were       -
079200240313//-               entered into the search. By entering an option number in front of a account type -
079300240313//-               code, you can change, delete or display an account type code and any additional  -
079400240313//-               data.                                                                            -
079500240313//--------------------------------------------------------------------------------------------------
079600240313Dcl-Proc ProcessScreen;
079700240313
079800240313  // Going down one level in the message queue......................................................
079900240313  MsgQNbr_Cur += 1;
080000240313
080100240313  // Process the code selection screen..............................................................
080200240313    ReadC(E) DSP.MCM0100SF SFL_R;                // Check for option number being entered first
080300240313    If not %EOF or %ERROR;
080400240313      ProcCdeSelScn();                           // Process the change/delete/display for the code
080500240313    ElseIf %Error;
080600240313      CPF9898.Field1 = 'An error occured while reading the subfile display data';
080700240313      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
080800240313                 MsgQNbr_Cur : MsgKey : APIErrC);
080900240313
081000240313    ElseIf CTL_R.SRCH4TEXT <> *BLANKS;           // Code or description search requested
081100240313      If %SubSt(CTL_R.SRCH4TEXT:1:1) = '?';      // Return results containing the characters entered
081200240313        ClrSFData();
081300240313        ScanMod_35 = *ON;                        // Turn on searching by scan method
081400240313        RtvAccTypCds(RTVBYSRCH);                 // Retrieve data by scan method
081500240313
081600240313      ElseIf ScanMod_35 and %SubSt(CTL_R.SRCH4TEXT:1:1) <> '?';  // Scan method no longer used
081700240313        ScanMod_35 = *OFF;
081800240313        ClrSFData();
081900240313        If  SortCol_34 = *ON;                    // If currently selecting by code
082000240313          RtvAccTypCds(RTVBYCODE);               // Retrieve data by codes
082100240313        Else;
082200240313          RtvAccTypCds(RTVBYDESC);               // Retrieve data by description
082300240313        EndIf;
082400240313        PositionTo();                            // Begin subfile at what was entered in the search
082500240313
082600240313      Else;                                      // Just position to code or description
082700240313        PositionTo();
082800240313      EndIf;
082900240313
083000240313    EndIf;
083100240313
083200240313  // Going up one level in the message queue........................................................
083300240313  MsgQNbr_Cur -= 1;
083400240313
083500240313End-Proc ProcessScreen;
083600240313
083700240313//--------------------------------------------------------------------------------------------------
083800240313//- SUBPROCEDURE: ProcCdeSelScn                                                                    -
083900240313//- FUNCTION....: Process The Code Selection Screen Request                                        -
084000240313//- EXPLANATION.: Verify that the user has the authority to perform a change or delete of the      -
084100240313//-               account type code data. If display data was selected, then display the account   -
084200240313//-               type code data, because everyone can display the data.                           -
084300240313//--------------------------------------------------------------------------------------------------
084400240313Dcl-Proc ProcCdeSelScn;
084500240313
084600240313  // Going down one level in the message queue......................................................
084700240313  MsgQNbr_Cur += 1;
084800240313
084900240313  // Process the option entered for the code........................................................
085000240313  DoW not %EOF and not %Error;
085100240313
085200240313    // Change the account type code data............................................................
085300240313    If SFL_R.OPTION = '2';
085400240313      If not ProtFld_28;                         // Authority required to modify the data
085500240313        ProcAccTyp(MyLDA.Group : SFL_R.ATMATYPE : CHANGE : PAT.RetFncKey : PAT.RetMsgTyp :
085600240313                   PAT.RetPgmMsg);
085700240313        If PAT.RetFncKey = EXIT;                 // Exit out of program passed back
085800240313          F3_Exit = *ON;
085900240313        ElseIf PAT.RetPgmMsg <> *BLANKS;
086000240313          CPF9898.Field1 = PAT.RetPgmMsg;
086100240313          SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
086200240313                     MsgQNbr_Cur : MsgKey : APIErrC);
086300240313          If PAT.RetMsgTyp = ERROR;              // Error message passed back from program called
086400240313            DataErr_89 = *ON;
086500240313          EndIf;
086600240313        Else;                                    // Set everything back to its initial state
086700240313          Clear CTL_R.SRCH4TEXT;                 // Clear out any search values
086800240313          Clear SFL_R;                           // Clear out option data entered
086900240313          ClrSFData();                           // Clear out subfile data
087000240313          SortCol_34 = *ON;                      // Set to sort on code column indicator
087100240313          ScanMod_35 = *OFF;                     // Turn off scan mode
087200240313          OnlyAct_38 = *OFF;                     // Turn off show only active accounts
087300240313          RtvAccTypCds(RTVBYCODE);
087400240313        EndIf;
087500240313      Else;
087600240313        SndPgmMsg(Err_CodeChg : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
087700240313                   MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC);
087800240313        DataErr_89 = *ON;
087900240313      EndIf;
088000240313
088100240313    // Delete the account type code data............................................................
088200240313    ElseIf SFL_R.OPTION = '4';
088300240313      If not ProtFld_28;                         // Authority required to delete the data
088400240313        Chain(E) (SFL_R.ATMATYPE) ATM.ATMR ATM_R;
088500240313        If %Found and not %ERROR;
088600240313          DltTypCdeDta();
088700240313        Else;
088800240313          CPF9898.Field1 = 'An error occured while retrieving data from the Account Type File';
088900240313          SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
089000240313                     MsgQNbr_Cur : MsgKey : APIErrC);
089100240313        EndIf;
089200240313      Else;
089300240313        SndPgmMsg(Err_CodeDlt : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
089400240313                   MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC);
089500240313        DataErr_89 = *ON;
089600240313      EndIf;
089700240313
089800240313    // Display account type code detail data........................................................
089900240313    ElseIf SFL_R.OPTION = '5';
090000240313      ProcAccTyp(MyLDA.Group : SFL_R.ATMATYPE : DISPLAY : PAT.RetFncKey : PAT.RetMsgTyp :
090100240313                 PAT.RetPgmMsg);
090200240313        If PAT.RetFncKey = EXIT;                 // Exit out of program passed back
090300240313          F3_Exit = *ON;
090400240313        ElseIf PAT.RetPgmMsg <> *BLANKS;
090500240313          CPF9898.Field1 = PAT.RetPgmMsg;
090600240313          SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
090700240313                     MsgQNbr_Cur : MsgKey : APIErrC);
090800240313          If PAT.RetMsgTyp = ERROR;              // Error message passed back from program called
090900240313            DataErr_89 = *ON;
091000240313          EndIf;
091100240313        Else;                                    // Set everything back to its initial state
091200240313          Clear CTL_R.SRCH4TEXT;                 // Clear out any search values
091300240313          Clear SFL_R;                           // Clear out option data entered
091400240313          ClrSFData();                           // Clear out subfile data
091500240313          SortCol_34 = *ON;                      // Set to sort on code column indicator
091600240313          ScanMod_35 = *OFF;                     // Turn off scan mode
091700240313          OnlyAct_38 = *OFF;                     // Turn off show only active accounts
091800240313          RtvAccTypCds(RTVBYCODE);
091900240313        EndIf;
092000240313    EndIf;
092100240313    ReadC(E) DSP.MCM0100SF SFL_R;
092200240313  EndDo;
092300240313
092400240313  // Error occured while processing the subfile.....................................................
092500240313  If %ERROR;
092600240313    CPF9898.Field1 = 'An error occured while processing the subfile display data';
092700240313    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
092800240313               MsgQNbr_Cur : MsgKey : APIErrC);
092900240313  EndIf;
093000240313
093100240313  // Going up one level in the message queue........................................................
093200240313  MsgQNbr_Cur -= 1;
093300240313
093400240313End-Proc ProcCdeSelScn;
093500240313
093600240313//--------------------------------------------------------------------------------------------------
093700240313//- SUBPROCEDURE: PositionTo                                                                       -
093800240313//- FUNCTION....: Position The Subfile Display                                                     -
093900240313//- EXPLANATION.: The user has entered a search value that they want the to appear as the first    -
094000240313//-               record in the subfile.  Each record in the subfile is read until the search      -
094100240313//-               value exceeds the corresponding subfile value.  The subfile record number is     -
094200240313//-               set to the current value, which will cause it to be displayed at the top of the  -
094300240313//-               subfile. If the subfile index exceeds the number of subfile records, then the    -
094400240313//-               search value entered has not been found in the subfile and no positioning should -
094500240313//-               be done.                                                                         -
094600240313//- - - - - - - - - - - - - - - - - - -  V A R I A B L E S   - - - - - - - - - - - - - - - - - - - -
094700240313//-      Name                                          Description                                 -
094800240313//- --------------   ----------------------------------------------------------------------------- -
094900240313//- SFIdx            Counter used as a subfile index to get the subfile data                       -
095000240313//--------------------------------------------------------------------------------------------------
095100240313Dcl-Proc PositionTo;
095200240313
095300240313  Dcl-S SFIdx Like(SFRRN) Inz(1);
095400240313
095500240313  // Going down one level in the message queue......................................................
095600240313  MsgQNbr_Cur += 1;
095700240313
095800240313  // Read though the subfile to find where to postion it to.........................................
095900240313  DoU SFIdx > SavRRN;
096000240313    Chain(E) SFIdx DSP.MCM0100SF SFL_R;
096100240313    If SortCol_34 and SFL_R.ATMATYPE >= CTL_R.SRCH4TEXT or not SortCol_34 and
096200240313       SFL_R.ATMADESC >= CTL_R.SRCH4TEXT;
096300240313      CTL_R.SFRec# = SFIdx;
096400240313      Update DSP.MCM0100SF SFL_R;
096500240313      Leave;
096600240313    ElseIf %Error;
096700240313      CPF9898.Field1 = 'Error occured when trying to reading through the subfile data';
096800240313      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
096900240313                 MsgQNbr_Cur : MsgKey : APIErrC);
097000240313      DataErr_89  = *ON;
097100240313      Leave;
097200240313    EndIf;
097300240313    SFIdx +=1;
097400240313  EndDo;
097500240313
097600240313  // No value found to position the subfile to......................................................
097700240313  If SFIdx > SavRRN;
097800240313    CPF9898.Field1 = 'Not able to positon to code based upon what was entered';
097900240313    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
098000240313               MsgQNbr_Cur : MsgKey : APIErrC);
098100240313  EndIf;
098200240313
098300240313  // Going up one level in the message queue........................................................
098400240313  MsgQNbr_Cur -= 1;
098500240313
098600240313End-Proc PositionTo;
098700240313
098800240313//--------------------------------------------------------------------------------------------------
098900240313//- SUBPROCEDURE: DltTypCdeDta                                                                     -
099000240313//- FUNCTION....: Delete the Account Type Code And Account Type-Pay Code Change Data               -
099100240313//- EXPLANATION.: Remove the account type code from the Account Type file and the associated data  -
099200240313//-               in the Account Type-Pay Code Changes file. Before any data is deleted from       -
099300240313//-               either file, a snapshot of the data to be deleted is saved to the customer       -
099400240313//-               Miscellaneous Codes Maintenance Audit file.                                      -
099500240313//--------------------------------------------------------------------------------------------------
099600240313Dcl-Proc DltTypCdeDta;
099700240313
099800240313  // Going down one level in the message queue......................................................
099900240313  MsgQNbr_Cur += 1;
100000240313
100100240313  // Save the deleted record to the audit file before deleting the record...........................
100200240313  Eval-Corr AudtDta1 = ATM_R;
100300240313  WrtAudDta(MyLDA.Group : RECID : SFL_R.ATMATYPE : DELETE : AudtDta1 : AudtDta2 : WAD.ErrorMsg);
100400240313  If WAD.ErrorMsg <> *BLANKS;                  // Issues saving the audit data?
100500240313    CPF9898.Field1 = WAD.ErrorMsg;
100600240313    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
100700240313               MsgQNbr_Cur : MsgKey : APIErrC);
100800240313    DataErr_89 = *ON;
100900240313  Else;
101000240313
101100240313    // Delete the account type code from the Account Type (Financial Class) file....................
101200240313    Chain(E) (SFL_R.ATMATYPE) ATM.ATMR ATM_R;
101300240313    If %Found(ATM) and not %Error;
101400240313      Delete ATM.ATMR;
101500240313      CPF9898.Field1 = 'Account type code ' + %Trim(SFL_R.ATMATYPE) + ' deleted from the Account +
101600240313                        Type file';
101700240313      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
101800240313      MsgQNbr_Cur : MsgKey : APIErrC);
101900240313
102000240313      // Delete any corresponding records from the Account Type-Pay Code Changes file...............
102100240313      Clear AudtDta2;
102200240313      SetLL(E) (SFL_R.ATMATYPE) ATP1.ATPR;
102300240313      ReadE(E) (SFL_R.ATMATYPE) ATP1.ATPR ATP1_R;
102400240313      DoW not %EOF and not %Error;
102500240313        Eval-Corr AudtDta3 = ATP1_R;
102600240313        AudtDta3.ATPAType  = SFL_R.ATMATYPE;
102700240313        AudtDta3.ATMADesc  = SFL_R.ATMADESC;
102800240313        Clear AudtDta3.PADesc;
102900240313        Chain(E) (ATP1_R.ATPPayCd) PAYD.PAYDR PAYD_R;
103000240313        If %Found and not %Error;
103100240313          AudtDta3.PADesc = PAYD_R.PADesc;
103200240313        EndIf;
103300240313        Clear AudtDta3.ChgTypDsc;
103400240313        Chain(E) (ATP1_R.ATPChgTyp) ATM.ATMR ATM_R;
103500240313        If %Found and not %Error;
103600240313          AudtDta3.ChgTypDsc = ATM_R.ATMADesc;
103700240313        EndIf;
103800240313        WrtAudDta(MyLDA.Group : RECID : SFL_R.ATMATYPE : DELETE : AudtDta3 : AudtDta2 : WAD.ErrorMsg);
103900240313        If WAD.ErrorMsg <> *BLANKS;
104000240313          CPF9898.Field1 = WAD.ErrorMsg;
104100240313          SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
104200240313                     MsgQNbr_Cur : MsgKey : APIErrC);
104300240313        EndIf;
104400240313        Delete ATP1.ATPR;
104500240313        ReadE(E) (SFL_R.ATMATYPE) ATP1.ATPR ATP1_R;
104600240313      EndDo;
104700240313      If %Error;
104800240313        CPF9898.Field1 = 'Error occured when deleting ' + %Trim(SFL_R.ATMATYPE) + ' from the Account +
104900240313        Type Pay Code Changes file';
105000240313        DataErr_89 = *ON;
105100240313      EndIf;
105200240313
105300240313    ElseIF not %Equal;
105400240313      CPF9898.Field1 = 'No account type code exists for ' + %Trim(SFL_R.ATMATYPE) +
105500240313                       ' in the Account Type file';
105600240313      DataErr_89 = *ON;
105700240313    Else;
105800240313      CPF9898.Field1 = 'Error occured when deleting the type code ' + %Trim(SFL_R.ATMATYPE) +
105900240313      ' from the Account Type file';
106000240313      DataErr_89 = *ON;
106100240313    EndIf;
106200240313  EndIf;
106300240313
106400240313  // Show the action taken message..................................................................
106500240313  SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
106600240313    MsgQNbr_Cur : MsgKey : APIErrC);
106700240313
106800240313  // If delete of the data was successful, clear out data on the main screen........................
106900240313  If DataErr_89 = *OFF;
107000240313    Clear CTL_R.SRCH4TEXT;                       // Clear out any search values
107100240313    Clear SFL_R;                                 // Clear out option data entered
107200240313    ClrSFData();                                 // Clear out subfile data
107300240313    SortCol_34 = *ON;                            // Set to sort on code column indicator
107400240313    ScanMod_35 = *OFF;                           // Turn off scan mode
107500240313    OnlyAct_38 = *OFF;                           // Turn off show only active accounts
107600240313    RtvAccTypCds(RTVBYCODE);
107700240313  EndIf;
107800240313
107900240313  // Going up one level in the message queue........................................................
108000240313  MsgQNbr_Cur -= 1;
108100240313
108200240313End-Proc DltTypCdeDta;
108300240313
108400240313//--------------------------------------------------------------------------------------------------
108500240313//- SUBPROCEDURE: CloseOpenFiles                                                                   -
108600240313//- FUNCTION....: Close Files Opened By This Program                                               -
108700240313//- EXPLANATION.: Some files were opened by this program so that the file could be overridden at   -
108800240313//-               the time it was opened. At the end of the program these files need to be closed. -
108900240313//--------------------------------------------------------------------------------------------------
109000240313Dcl-Proc CloseOpenFiles;
109100240313
109200240313  // Close the Account Type (Financial Class) file..................................................
109300240313  If %Open(ATM);
109400240313    Close(E) ATM;
109500240313  EndIf;
109600240313
109700240313  // Close the Account Type-Pay Code Changes file...................................................
109800240313  If %Open(ATP1);
109900240313    Close(E) ATP1;
110000240313  EndIf;
110100240313
110200240313  // Close the Pay Code Description file............................................................
110300240313  If %Open(PAYD);
110400240313    Close(E) PAYD;
110500240313  EndIf;
110600240313
110700240313End-Proc CloseOpenFiles;
110800240313
110900240313//--------------------------------------------------------------------------------------------------
111000240313// FUNCTION....: Center text within a field                                                        -
111100240313//--------------------------------------------------------------------------------------------------
111200240313/COPY QCPYSRC,F_CENTRTXT
