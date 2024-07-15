000100240417**free
000200240220Ctl-Opt COPYRIGHT('©EMMI Physician Service, Inc. - 2024')
000300240220DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')
000400240220OPTION(*SRCSTMT:*NODEBUGIO:*NOUNREF)
000500240220DECEDIT('0.') ExtBinInt(*YES) OPTIMIZE(*BASIC);
000600240220//*************************************************************************************************/
000700240220//                                   EMMI Physician Service, Inc.                                  /
000800240220//                                               ©2024                                             /
000900240220//*************************************************************************************************/
001000240220// CREATE DATE: 02/20/2024                                                                         /
001100240220// PROGRAMMER.: Johnny Skaggs                                                                      /
001200240220// PROGRAM....: MCM0201R                                                                           /
001300240220// SYNOPSIS...: Pay Code Maintenance                                                               /
001400240220// DESCRIPTION: Displays a screen of the information for the pay code.  The pay code must be       /
001500240220//              filled in before the any pay code information is displayed.  Pay codes are unique  /
001600240220//              to each of the customers. If you have the correct authority, you can add, change   /
001700240220//              or delete a pay code for the customer; otherwise, you will be only able to view    /
001800240220//              pay code data. If you try to delete a pay code, and there is payment activity      /
001900240220//              against the pay code, you will not be able to delete the pay code.  All actions    /
002000240220//              performed on a oay code, except display, will cause a record to be written to the  /
002100240220//              customer Miscellaneous Codes Maintenance Audit file (Mxx.AUDM). The program checks /
002200240220//              to make sure that a change was made to the data before proceeding with changing    /
002300240220//              the data. If no change was made to the data, a message is displayed saying that no /
002400240220//              data changes were made.                                                            /
002500240220//                                                                                                 /
002600240220//++++++++++++++++++++++++++++++++++++++  P R A M A T E R S  ++++++++++++++++++++++++++++++++++++++/
002700240220//      NAME      I/O                                  DESCRIPTION                                 /
002800240220// -------------- --- ---------------------------------------------------------------------------- /
002900240418//  CustCode      In  ·Group code used to identify the customer                                    /
003000240418//  PayCode       In  ·Pay code                                                                    /
003100240418//  AddChgDsp     In  ·Add, change or display the pay code description data                        /
003200240418//  RetFncKey     Out ·Function key pressed in calling program that needs to be passed back to     /
003300240418//                     the current program: F3=Exit out of all programs and back to menu           /
003400240418//  RetMsgTyp     Out ·Program message type: ERR=Error, INF=Informational, WRN=Warning             /
003500240418//  RetPgmMsg     Out ·Message returned by the program called                                      /
003600240416//                                                                                                 /
003700240220//++++++++++++++++++++++++++++++++++++++++++  F I L E S  ++++++++++++++++++++++++++++++++++++++++++/
003800240220//    NAME     OVERRIDDEN                                DESCRIPTION                               /
003900240220// ----------  ----------  ----------------------------------------------------------------------- /
004000240220// Mxx.PAYD    PAYD        Pay Code Description File                                               /
004100240220// Mxx.PCD     PCD         Generic Pay Code File                                                   /
004200240220// Mxx.PMS4    PMS4        Nonrevenue Payment Logical                                              /
004300240220// Mxx.PMT4    PMT4        Revenue Payment Logical                                                 /
004400240220// Mxx.PYD2    PYD2        Paycode Generic Pay Code Cross-Reference Logical                        /
004500240220// Mxx.RPT     RPT         Report file                                                             /
004600240220//                                                                                                 /
004700240220//++++++++++++++++++++++++++++++++  D A T A  S T R U C T U R E S  +++++++++++++++++++++++++++++++++/
004800240220//      NAME      I/O                                  DESCRIPTION                                 /
004900240220// -------------- --- ---------------------------------------------------------------------------- /
005000240220// AuditData      Out Allows the moving of the audit data into the audit file without having to    /
005100240220//                    move each individual field.                                                  /
005200240220// AudtDta1       I/O Used to store the file data that corresponds to the screen data. This allows /
005300240220//                    the comparison of the screen data to the file data to see if it changed.     /
005400240220// AudtDta2       I/O Used to store the screen data that corresponds to the file data.             /
005500240220// DataIn         In  Allows the data to be retrieved from the input file by the SQL processing.   /
005600240220// MyLDA          In  Holds the data that is read in from the Local Data Area (LDA).               /
005700240220// WSInd          In  Since INDARA is used in the display file, mapping of the indicators must be  /
005800240220//                    done  in the program.  The indicators for the display are now accessed using /
005900240220//                    the  data structure. Turning on an indicator in the data structure will not  /
006000240220//                    turn on the corresponding *INxx indicator.                                   /
006100240220//                                                                                                 /
006200240220//+++++++++++++++++++++++++++++++++++++  C O N S T A N T S   ++++++++++++++++++++++++++++++++++++++/
006300240220//      NAME                                          DESCRIPTION                                  /
006400240220// --------------   ------------------------------------------------------------------------------ /
006500240220// ADD            - Add a record to the miscellaneous codes maintenance file                       /
006600240220// CHANGE         - Change a record in the miscellaneous codes maintenance file                    /
006700240220// DELETE         - Delete a record fromthe miscellaneous codes maintenance file                   /
006800240416// DISPLAY        - Display the data for the account type code                                     /
006900240416// EXIT           - Show that the function key F3 was pressed to exit the calling program          /
007000240416// ERROR          - Message passed back from program called is an error message                    /
007100240416// NO             - Readability replacement for N                                                  /
007200240220// RECID          - Record identification                                                          /
007300240220// RTVBYCODE      - Retrieve records from file using miscellaneous code                            /
007400240220// RTVBYDESC      - Retrieve records from file using code description                              /
007500240220// RTVBYSRCH      - Retrieve records from file using search string                                 /
007600240220// SYSKEY         - System file key used to look up provider account information                   /
007700240220// YES            - Replacement for Y                                                              /
007800240220//                                                                                                 /
007900240220//++++++++++++++++++++++++++++++++++++++  V A R I A B L E S  ++++++++++++++++++++++++++++++++++++++/
008000240220//      NAME                                          DESCRIPTION                                  /
008100240220// --------------   ------------------------------------------------------------------------------ /
008200240220// CompanyName    - Name of the company who's data is being presented                              /
008300240416// DataAdded      - Data that was entered into the screen was added to the file                    /
008400240220// PayCodeF       - Pay code description file PAYD overridden to this file Mxx.PAYD                /
008500240220// PCGenXRefF     - Pay code generic pay code cross-reference logical Mxx.PYD2                     /
008600240220// PmtNonRevF     - Nonrevenue payment logical PMS4 overridden to this logical Mxx.PMS4            /
008700240220// PmtRevenuF     - Revenue payment logical PMT4 overridden to this logical Mxx.PMT4               /
008800240220// ReportF        - Report file RPT overrididden to this file Mxx.RPT                              /
008900240220// SavPayClass    - Save the pay class for comparison purposes if it should get changed            /
009000240220//                                                                                                 /
009100240220//++++++++++++++++++++  F U N C T I O N  K E Y S  A N D  I N D I C A T O R S  +++++++++++++++++++++/
009200240220//     NAME                                         DESCRIPTION                                    /
009300240220// ----------   ---------------------------------------------------------------------------------- /
009400240220// F1_Help    - Context sensitive help                                                             /
009500240220// F3_Exit    - Exit program                                                                       /
009600240220// F4_Prompt  - Prompt the field to show data selection window                                     /
009700240220// F12_Cancel - Cancel current action and return to previous screen                                /
009800240220// ProtFld_28 - Protect the field from changes                                                     /
009900240220// AddCode_36 - Add a new accounting type code                                                     /
010000240220// PayCode_40 - Pay code missing when adding data                                                  /
010100240220// InactDt_41 - Inactive date is invalid                                                           /
010200240220// PyCdDsc_42 - Pay code description error                                                         /
010300240220// PyCdTyp_43 - Pay code type error                                                                /
010400240220// PyCdCls_44 - Pay code class error                                                               /
010500240220// IgnrStm_45 - Ignore on statement error                                                          /
010600240220// Post2GL_46 - Post to the general ledger error                                                   /
010700240220// SRStmnt_47 - Stop/Reinstate on statement error                                                  /
010800240220// AltPyCd_48 - Alternate pay code error                                                           /
010900240220// SRAutoR_49 - Stop/Reinstate automatic rebilling error                                           /
011000240220// ReblDys_50 - Override automatic rebill days error                                               /
011100240220// InsPymt_51 - Allow installment payments error                                                   /
011200240220// PrtMB68_52 - Print on MBM068 form error                                                         /
011300240220// GenPyCd_53 - Generic pay code error                                                             /
011400240220// FlUpDys_54 - Follow up number of days error                                                     /
011500240220// MBM577E_55 - Column MBM577 error                                                                /
011600240220// MBM578E_56 - Column MBM578 error                                                                /
011700240220// MBM579E_57 - Column MBM579 error                                                                /
011800240220// DataErr_89 - Data error found                                                                   /
011900240416// DataChg_91 - Data was changed on the display                                                    /
012000240418// P2AltPC_92 - Position to alternate pay code                                                     /
012100240418// P2GenXR_93 - Position to generic cross reference code                                           /
012200240220//                                                                                                 /
012300240220//+++++++++++++++++++++++++++++++++  M O D I F I C A T I O N S  +++++++++++++++++++++++++++++++++++/
012400240220// DATE..: MM/DD/CCYY   PROGRAMMER: First and last name                                            /
012500240220// REASON: Project number or ticket number                                                         /
012600240220// MODS..: What changes were made to the program                                                   /
012700240220//*************************************************************************************************/
012800240220
012900240416// Passed parameters................................................................................
013000240416Dcl-PI *n;
013100240416  CustCode  Char( 2) Const;
013200240416  PayCode   Char( 2) Const;
013300240416  AddChgDsp Char( 3) Const;
013400240416  RetFncKey Char( 3);
013500240416  RetMsgTyp Char( 3);
013600240416  RetPgmMsg Char(78);
013700240416End-PI;
013800240416
013900240220// Declare, override and open files.................................................................
014000240220Dcl-F DSP  WorkStn Qualified ExtDesc('MCM0201D') ExtFile(*ExtDesc) InDDS(WsInd);
014100240418Dcl-F PAYD Disk Keyed Usage(*DELETE:*OUTPUT) ExtDesc('MXX.PAYD') ExtFile(PayCodeF) Qualified UsrOpn;
014200240418Dcl-F PCD  Disk Keyed Usage(*INPUT) ExtDesc('M.PCD'   ) ExtFile('M.PCD'   ) UsrOpn;
014300240418Dcl-F PMS4 Disk Keyed Usage(*INPUT) ExtDesc('MXX.PMS4') ExtFile(PmtNonRevF) UsrOpn;
014400240418Dcl-F PMT4 Disk Keyed Usage(*INPUT) ExtDesc('MXX.PMT4') ExtFile(PmtRevenuF) UsrOpn;
014500240418Dcl-F PYD2 Disk Keyed Usage(*INPUT) ExtDesc('MXX.PYD2') ExtFile(PCGenXRefF) Rename(PAYDR:PYD2R)
014600240220      UsrOpn;
014700240418Dcl-F RPT  Disk Keyed Usage(*INPUT) ExtDesc('MXX.RPT' ) ExtFile(ReportF   ) UsrOpn;
014800240220
014900240220// Data structure templates to deifine record formats...............................................
015000240418Dcl-DS PAYD_T LikeRec(PAYD.PAYDR :*All) Template;
015100240418Dcl-DS INFO_T LikeRec(DSP.MCM0201:*All) Template;
015200240418Dcl-DS MSGC_T LikeRec(DSP.MSGCTL :*All) Template;
015300240220
015400240220// Like data structures used for the reading and writing of data....................................
015500240418Dcl-DS PAYD_R LikeDS(PAYD_T);          // Pay code description file format
015600240418Dcl-DS INFO_R LikeDS(INFO_T);          // Pay code information display format
015700240418Dcl-DS MSGC_R LikeDS(MSGC_T);          // Error message screen format
015800240220
015900240220// Define data structure for reading of batch control file using SQL................................
016000240220Dcl-DS DataIn ExtName('MXX.PAYD') Qualified End-DS;
016100240220
016200240220// Functions keys and indicators data structure.....................................................
016300240220Dcl-DS WsInd Len(99);
016400240220  FuncKeyInd Char(24) Pos(01);         // Function key indicators...................................
016500240220    F3_Exit    Ind Pos(03);            // Exit
016600240220    F4_Prompt  Ind Pos(04);            // Prompt the field to show pop-up window to select code
016700240220    F12_Cancel Ind Pos(12);            // Cancel
016800240220  ScreenInd  Char(15) Pos(25);         // Screen manipulation indicators............................
016900240220    ProtFld_28 Ind Pos(28);            // Protect the field from being changed
017000240220    AddCode_36 Ind Pos(36);            // Add a new account type code
017100240220    Inactiv_37 Ind Pos(37);            // Show/Hide inactive accounts
017200240220    SubFEnd_39 Ind Pos(39);            // Subfile End (SFLEND)
017300240220  FldErrInd  Char(50) Pos(40);         // Error indicators..........................................
017400240220    PayCode_40 Ind Pos(40);            // Pay code missing when adding data
017500240220    InactDt_41 Ind Pos(41);            // Inactive date is invalid
017600240220    PyCdDsc_42 Ind Pos(42);            // Pay code description error
017700240220    PyCdTyp_43 Ind Pos(43);            // Pay code type error
017800240220    PyCdCls_44 Ind Pos(44);            // Pay code class error
017900240220    IgnrStm_45 Ind Pos(45);            // Ignore on statement error
018000240220    Post2GL_46 Ind Pos(46);            // Post to the general ledger error
018100240220    SRStmnt_47 Ind Pos(47);            // Stop/Reinstate on statement error
018200240220    AltPyCd_48 Ind Pos(48);            // Alternate pay code error
018300240220    SRAutoR_49 Ind Pos(49);            // Stop/Reinstate automatic rebilling error
018400240220    ReblDys_50 Ind Pos(50);            // Override automatic rebill days error
018500240220    InsPymt_51 Ind Pos(51);            // Allow installment payments error
018600240220    PrtMB68_52 Ind Pos(52);            // Print on MBM068 form error
018700240220    GenPyCd_53 Ind Pos(53);            // Generic pay code error
018800240220    FlUpDys_54 Ind Pos(54);            // Follow up number of days error
018900240220    MBM577E_55 Ind Pos(55);            // Column MBM577 error
019000240220    MBM578E_56 Ind Pos(56);            // Column MBM578 error
019100240220    MBM579E_57 Ind Pos(57);            // Column MBM579 error
019200240220    DataErr_89 Ind Pos(89);            // Data error found
019300240220  ProgramInd Char(10) Pos(90);         // Program flow indicators...................................
019400240416    DataChg_91 Ind Pos(91);            // Data was changed on the display
019500240418    P2AltPC_92 Ind Pos(92);            // Position to alternate pay code
019600240418    P2GenXR_93 Ind Pos(93);            // Position to generic cross reference code
019700240220End-DS WsInd;
019800240220
019900240220// Audit data to save data structure................................................................
020000240220Dcl-DS AuditData1;
020100240220  PAPAYCODE  Like(PAYD_R.PAPAYCODE );  // Pay code
020200240220  PADESC     Like(PAYD_R.PADESC    );  // Pay code description
020300240220  PATYPE     Like(PAYD_R.PATYPE    );  // Type
020400240220  PACLASS    Like(PAYD_R.PACLASS   );  // Pay class
020500240220  PAPOSTGL   Like(PAYD_R.PAPOSTGL  );  // Post to general ledger
020600240220  PAIGNORE   Like(PAYD_R.PAIGNORE  );  // Ignore on statement
020700240220  PASTOP     Like(PAYD_R.PASTOP    );  // Stop statement
020800240220  PACHGDAT   Like(PAYD_R.PACHGDAT  );  // Last Change date
020900240220  PACHGUSR   Like(PAYD_R.PACHGUSR  );  // Last Change user
021000240220  PAACTPAYCD Like(PAYD_R.PAACTPAYCD);  // Activity pay code(not used)
021100240220  PAALTPAYCD Like(PAYD_R.PAALTPAYCD);  // Alternate pay code
021200240220  PARBLBYPAS Like(PAYD_R.PARBLBYPAS);  // Auto rebill bypass
021300240220  PARBLDAYS  Like(PAYD_R.PARBLDAYS );  // Auto rebill days
021400240220  PAINSTLMNT Like(PAYD_R.PAINSTLMNT);  // Installment pay code
021500240220  PAPRT068   Like(PAYD_R.PAPRT068  );  // Print on MB068 report (explanation of pay code report)
021600240418  PAGENXREF  Like(PAYD_R.PAGENXREF );  // Generic cross reference code
021700240220  PAINACDT   Like(PAYD_R.PAINACDT  );  // Inactive Date
021800240220  PAMBM577   Like(PAYD_R.PAMBM577  );  // MBM577 column code
021900240220  PAMBM578   Like(PAYD_R.PAMBM578  );  // MBM578 column code
022000240220  PAFLWUP    Like(PAYD_R.PAFLWUP   );  // Follow-up number of days
022100240220  PAMBM579   Like(PAYD_R.PAMBM579  );  // MBM579 column code
022200240220End-DS AuditData1;
022300240220
022400240220
022500240220// Like data structures used to see if the data has changed.........................................
022600240220Dcl-DS AudtDta1 LikeDS(AuditData1);
022700240220Dcl-DS AudtDta2 LikeDS(AuditData1);
022800240220
022900240220// Declare data structre for reading in the Local Data Area (LDA)...................................
023000240220Dcl-DS MyLDA DtaAra(*LDA) Qualified;
023100240220  Entity   Char( 3) Pos(137);          // Used to open the correct account type file
023200240220  Group    Char( 2) Pos(138);          // Used as key to lookup customer information
023300240220  DeviceID Char( 2) Pos(494);          // Last two characters of device name
023400240220  UserID   Char(10) Pos(496);          // User identification of person running the job
023500240220  Customer Char(50) Pos(951);          // Customer company name
023600240220End-DS;
023700240220
023800240220// Declare constatnts...............................................................................
023900240416Dcl-C ADD     Const('ADD');
024000240416Dcl-C CHANGE  Const('CHG');
024100240416Dcl-C DELETE  Const('DLT');
024200240416Dcl-C DISPLAY Const('DSP');
024300240416Dcl-C EXIT    Const('F03');
024400240416Dcl-C ERROR   Const('ERR');
024500240416Dcl-C NO      Const('N');
024600240418Dcl-C RECID   Const('02');
024700240416Dcl-C SYSKEY  Const('01');
024800240416Dcl-C YES     Const('Y');
024900240220
025000240220// Declare variables...............................................................................
025100240220Dcl-S CompanyName Char(50) Inz;
025200240416Dcl-S DataAdded   Char( 1) Inz(NO);
025300240416Dcl-S PayCodeF    Char(10) Inz;
025400240220Dcl-S PCGenXRefF  Char(10) Inz;
025500240220Dcl-S PmtNonRevF  Char(10) Inz;
025600240220Dcl-S PmtRevenuF  Char(10) Inz;
025700240220Dcl-S ReportF     Char(10) Inz;
025800240220Dcl-S SavPayClass Char( 1) Inz;
025900240220
026000240220// Data structure-Contains any API interface errors.................................................
026100240220/COPY QCPYSRC,D_APIERRDS
026200240220
026300240220// Prototype-Lookup the generic pay code from the Generic Pay Code file.............................
026400240220/COPY QCPYSRC,D_GENPYCLU
026500240220
026600240220// Prototype-Lookup the pay code from the Pay Code Description file.................................
026700240220/COPY QCPYSRC,D_PAYCDELU
026800240220
026900240220// Prototype-Send program message and clear program message queue...................................
027000240220/COPY QCPYSRC,D_PGMMSGS
027100240220
027200240220// Data structure-Contains the program information..................................................
027300240220/COPY QCPYSRC,D_PGMSTSDS
027400240220
027500240220// Constants-Human readable form for the program message identifiers................................
027600240220/COPY QCPYSRC,D_PMSGIDS
027700240220
027800240220// Prototype-Retrieve security data from the User/Program Security file.............................
027900240220/COPY QCPYSRC,D_RTVSECDT
028000240220
028100240220// Prototype-Retrieve system control data from the System Control file..............................
028200240220/COPY QCPYSRC,D_RTVSYSDT
028300240220
028400240220// Prototype-Write the audit data to the correct audit file.........................................
028500240220/COPY QCPYSRC,D_WRTAUDTA
028600240220
028700240220//**************************************************************************************************
028800240220//************************************  M A I N  P R O G R A M  ************************************
028900240220//**************************************************************************************************
029000240220
029100240220// Stuff that only needs to be done once when the program is first run..............................
029200240416ProgramEntry();
029300240220
029400240220// Process the screen until F3 is pressed...........................................................
029500240220DoU F3_Exit or F12_Cancel;
029600240220
029700240220  // Display the correct screen.....................................................................
029800240220  INFO_R.CompName = CompanyName;                 // Record format clear requires company name here
029900240418  If DataErr_89 and AddChgDsp = ADD;
030000240418    AddCode_36 = *ON;                            // Turn back on the add if an error occured
030100240418  EndIf;
030200240418  Write DSP.MSGCTL MSGC_R;
030300240220  ExFmt DSP.MCM0201 INFO_R;
030400240220
030500240220  // Reset the error indicators and clear out any previously displayed messages.....................
030600240220  AddCode_36 = *OFF;                             // Turn off record add indicator
030700240418  P2AltPC_92 = *OFF;                             // Turn off position to alternate pay code
030800240418  P2GenXR_93 = *OFF;                             // Turn off position to generic cross reference cde
030900240220  FldErrInd  = *OFF;
031000240220  ClrMsgQ( MsgQ_Cur : MsgQNbr_Cur : MsgKey_All :  MsgRmv_All : APIErrC );
031100240220
031200240220  // F3 - Exit out of program.......................................................................
031300240220  Select;
031400240220  When F3_Exit;
031500240416    RetFncKey = EXIT;
031600240416    Leave;
031700240220
031800240220  // F4 - Process prompt request for information lookup.............................................
031900240418  When F4_Prompt;
032000240418    If INFO_R.CurFld = 'PAALTPAYCD' or INFO_R.CURFLD = 'PAGENXREF';
032100240416      ProcessPrompt(INFO_R.CurFld);
032200240220    Else;
032300240220      CPF9898.Field1 = 'The location of your cursor does not allow for prompting';
032400240220      SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
032500240220                 MsgQNbr_Cur : MsgKey : APIErrC );
032600240220      DataErr_89 = *ON;
032700240220    EndIf;
032800240220
032900240220  // F12 - Go back to previous screen...............................................................
033000240220  When F12_Cancel;
033100240220    Leave;
033200240220
033300240220  // Enter - Process the different screens..........................................................
033400240416  Other;
033500240418    If AddChgDsp = ADD and DataAdded <> YES;
033600240416      If ProtFld_28 = *OFF;                        // Must have the security to add pay codes
033700240416        AddCode_36 = *ON;
033800240416        VldPayCodeData();
033900240416        If not DataErr_89;
034000240416          AddPayCodeData();
034100240416        EndIf;
034200240416      Else;
034300240416        SndPgmMsg(Err_CodeAdd : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
034400240416                   MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC);
034500240416        DataErr_89 = *ON;
034600240416      EndIf;
034700240418    ElseIf AddChgDsp = CHANGE or AddChgDsp = ADD and DataAdded = YES;
034800240416      If ProtFld_28 = *OFF;
034900240416        VldPayCodeData();
035000240416        If DataErr_89 = *OFF;
035100240416          ChgPayCodeData();                        // Update the data in the Pay Code Description file
035200240416        EndIf;
035300240416      Else;
035400240416        SndPgmMsg(Err_CodeChg : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
035500240416                   MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC);
035600240416        DataErr_89 = *ON;
035700240416      EndIf;
035800240416    EndIf;
035900240416  EndSL;
036000240220
036100240220EndDo;                                           // DoU F3_Exit or F12_Cancel
036200240220
036300240220// Close files that were opened by this program.....................................................
036400240220CloseOpenFiles();
036500240220
036600240220//--------------------------------------------------------------------------------------------------
036700240416//- SUBPROCEDURE: ProgramEntry                                                                     -
036800240220//- FUNCTION....: Program Initialization                                                           -
036900240220//- EXPLANATION.: Process all of the things that need to be done only once the when the program is -
037000240220//-               first run.                                                                       -
037100240418//-                                                                                                -
037200240418//- - - - - - - - - - - - - - - - - - -  C O N S T A N T S   - - - - - - - - - - - - - - - - - - - -
037300240418//-      Name                                          Description                                 -
037400240418//- --------------   ----------------------------------------------------------------------------- -
037500240418//- ACTIVE           Data record is active                                                         -
037600240416//-                                                                                                -
037700240416//- - - - - - - - - - - - - - - - - - -  V A R I A B L E S   - - - - - - - - - - - - - - - - - - - -
037800240416//-      Name                                          Description                                 -
037900240416//- --------------   ----------------------------------------------------------------------------- -
038000240416//- FilePrefix       Prefix needed for the file to open the correct customer file (Mxx)            -
038100240220//--------------------------------------------------------------------------------------------------
038200240416Dcl-Proc ProgramEntry;
038300240418
038400240418  // Declare constants..............................................................................
038500240418  Dcl-C ACTIVE Const('A');
038600240220
038700240416  // Declare standalone variables...................................................................
038800240416  Dcl-S FilePrefix Char(3);
038900240416
039000240220  // Going down one level in the message queue......................................................
039100240220  MsgQNbr_Cur += 1;
039200240220
039300240220  // Set program name for error message screen and initialize the error message screen..............
039400240220  *INLR = *ON;
039500240220  Clear INFO_R;
039600240220  MSGC_R.PGMNAME = PgmName;                      // Required because of screen record format DS
039700240220  ClrMsgQ( MsgQ_Cur : MsgQNbr_Cur : MsgKey_All :  MsgRmv_All : APIErrC );
039800240220
039900240220  // Retrieve the user security information from the program security file..........................
040000240416  If AddChgDsp = *BLANKS;
040100240416  RtvSecDta(PgmName : JobUser : RSECD.SecFileDta : RSECD.ErrorMsg);
040200240416    If RSECD.ErrorMsg = *BLANKS;
040300240416      If RSECD.SecFileDta.SEC02 <> YES;          // Pay code data edit security
040400240416        ProtFld_28 = *ON;                        // Do not allow editing of pay code data
040500240416      EndIf;
040600240416    Else;
040700240416      CPF9898.Field1 = RSECD.ErrorMsg;
040800240416      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
040900240416                 MsgQNbr_Cur : MsgKey : APIErrC);
041000240416      ProtFld_28 = *ON;
041100240416      DataErr_89 = *ON;
041200240416    EndIf;
041300240416  ElseIf AddChgDsp = DISPLAY;
041400240416    ProtFld_28 = *ON;
041500240416  EndIf;
041600240416
041700240416  // Customer code needed to open the correct files.................................................
041800240416  If %Len(%Trim(CustCode)) = 2;
041900240416    FilePrefix = 'M' + CustCode;
042000240416    MyLDA.Group = CustCode;
042100240416  Else;
042200240416    In MyLDA;
042300240416    FilePrefix = MyLDA.Entity;
042400240416  EndIf;
042500240416
042600240220  // Open the correct pay code description file.....................................................
042700240418  If %Len(%Trim(FilePrefix)) = 3;
042800240418    PayCodeF = FilePrefix + '.PAYD';
042900240220    If not %Open(PAYD);
043000240220      Open(E) PAYD;
043100240220      If %Error;
043200240220        CPF9898.Field1 = 'The program could not open the file ' + PayCodeF + '. Contact IT for help';
043300240220        SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
043400240220                   MsgQNbr_Cur : MsgKey : APIErrC );
043500240220        DataErr_89 = *ON;
043600240220      EndIf;
043700240220    EndIf;
043800240220
043900240220    // Open the generic pay code file...............................................................
044000240220    If not %Open(PCD);
044100240220      Open(E) PCD;
044200240220      If %Error;
044300240220        CPF9898.Field1 = 'The program could not open the file M.PCD. Contact IT for help';
044400240220        SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
044500240220                   MsgQNbr_Cur : MsgKey : APIErrC );
044600240220        DataErr_89 = *ON;
044700240220      EndIf;
044800240220    EndIf;
044900240220
045000240220    // Open the correct nonrevenue payment file.....................................................
045100240418    PmtNonRevF = FilePrefix + '.PMS4';
045200240220    If not %Open(PMS4);
045300240220      Open(E) PMS4;
045400240220      If %Error;
045500240220        CPF9898.Field1 = 'The program could not open the file ' + PmtNonRevF + '. Contact IT for help';
045600240220        SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
045700240220                   MsgQNbr_Cur : MsgKey : APIErrC );
045800240220        DataErr_89 = *ON;
045900240220      EndIf;
046000240220    EndIf;
046100240220
046200240220    // Open the correct revenue payment file........................................................
046300240418    PmtRevenuF = FilePrefix + '.PMT4';
046400240220    If not %Open(PMT4);
046500240220      Open(E) PMT4;
046600240220      If %Error;
046700240220        CPF9898.Field1 = 'The program could not open the file ' + PmtNonRevF + '. Contact IT for help';
046800240220        SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
046900240220                   MsgQNbr_Cur : MsgKey : APIErrC );
047000240220        DataErr_89 = *ON;
047100240220      EndIf;
047200240220    EndIf;
047300240220
047400240220    // Open the correct pay code generic pay code cross reference file..............................
047500240418    PCGenXRefF = FilePrefix + '.PYD2';
047600240220    If not %Open(PYD2);
047700240220      Open(E) PYD2;
047800240220      If %Error;
047900240220        CPF9898.Field1 = 'The program could not open the file ' + PCGenXRefF + '. Contact IT for help';
048000240220        SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
048100240220                   MsgQNbr_Cur : MsgKey : APIErrC );
048200240220        DataErr_89 = *ON;
048300240220      EndIf;
048400240220    EndIf;
048500240220
048600240220    // Open the correct pay code generic pay code cross reference file..............................
048700240418    ReportF = FilePrefix + '.RPT';
048800240220    If not %Open(RPT);
048900240220      Open(E) RPT;
049000240220      If %Error;
049100240220        CPF9898.Field1 = 'The program could not open the file ' + ReportF + '. Contact IT for help';
049200240220        SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
049300240220                   MsgQNbr_Cur : MsgKey : APIErrC );
049400240220        DataErr_89 = *ON;
049500240220      EndIf;
049600240220    EndIf;
049700240220
049800240220    // Retrieve the customer company and center it in the field.....................................
049900240220    RtvSysDta( MyLDA.Group : SYSKEY : RSYSD.SysFileDta : RSYSD.ErrorMsg );
050000240220    If RSYSD.ErrorMsg = *BLANKS;
050100240220      CompanyName = CenterText(RSYSD.SysFileDta.SYSNAM);
050200240220    Else;
050300240220      CPF9898.Field1 = RSYSD.ErrorMsg;
050400240220      SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
050500240220                 MsgQNbr_Cur : MsgKey : APIErrC );
050600240220      DataErr_89 = *ON;
050700240220    EndIf;
050800240220
050900240220  Else;
051000240220    CPF9898.Field1 = 'LDA missing data. Cannot open correct file. Contact IT for help';
051100240220    SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
051200240220               MsgQNbr_Cur : MsgKey : APIErrC );
051300240220    DataErr_89 = *ON;
051400240220  EndIf;
051500240220
051600240416  // Retrieve the detail data for the account type code.............................................
051700240416  If not DataErr_89 and AddChgDsp <> ADD;
051800240416    INFO_R.PAPAYCODE = PayCode;
051900240416    RtvPayCodes();
052000240416  ElseIf not DataErr_89 and AddChgDsp = ADD;
052100240418    INFO_R.PADSCA = ACTIVE;
052200240416    AddCode_36 = *ON;
052300240416  EndIf;
052400240416
052500240220  // Going up one level in the message queue........................................................
052600240220  MsgQNbr_Cur -= 1;
052700240220
052800240416End-Proc ProgramEntry;
052900240220
053000240220//--------------------------------------------------------------------------------------------------
053100240220//- SUBPROCEDURE: RtvPayCodes                                                                      -
053200240220//- FUNCTION....: Retrieve Data To Load Into The Subfile Display                                   -
053300240220//- EXPLANATION.: Retrieve the data from the Pay Code Description file to populate the subfile     -
053400240220//-               display. For this subprocedure to retrieve the data from the file, the pay code  -
053500240220//-               must be filled in on the display.                                                -
053600240220//-                                                                                                -
053700240220//- - - - - - - - - - - - - - - - - - -  C O N S T A N T S   - - - - - - - - - - - - - - - - - - - -
053800240220//-      Name                                          Description                                 -
053900240220//- --------------   ----------------------------------------------------------------------------- -
054000240220//- ASCENDING        Sort the returned SQL data in ascending sequence                              -
054100240220//- DESCENDING       Sort the returned SQL data in descending sequence                             -
054200240220//- SPACE            Used to put spaces inbetween the different clauses of the SQL statement       -
054300240220//- SQLOK            Status of good SQL processing                                                 -
054400240220//- SQLEOF           SQL end of file indicator                                                     -
054500240220//- SQUOTE           Single quote to put around character values in the SQL statement              -
054600240220//-                                                                                                -
054700240220//- - - - - - - - - - - - - - - - - - -  V A R I A B L E S   - - - - - - - - - - - - - - - - - - - -
054800240220//-      Name                                          Description                                 -
054900240220//- --------------   ----------------------------------------------------------------------------- -
055000240220//- ForClause        Dynamic SQL FOR clause (not required; however, it is recommended)             -
055100240220//- GroupByClause    Dynamic SQL GROUP BY clause used to get unique values for the field           -
055200240220//- OrderByClause    Dynamic SQL ORDER BY clause (not required)                                    -
055300240220//- SelectClause     Dynamic SQL SELECT clause (also update, delete, etc)                          -
055400240220//- SortSeq          Sequence in which the data is sorted (ascending or descending)                -
055500240220//- SQLStmt          Complete dynamic SQL stament to be executed                                   -
055600240220//- WhereClause      Dynamic SQL WHERE clause                                                      -
055700240220//--------------------------------------------------------------------------------------------------
055800240220Dcl-Proc RtvPayCodes;
055900240220
056000240220  // Declare constants..............................................................................
056100240220  Dcl-C ASCENDING  Const('ASC');
056200240220  Dcl-C DESCENDING Const('DESC');
056300240220  Dcl-C SPACE      Const(' ');
056400240220  Dcl-C SQLOK      Const('00000');
056500240220  Dcl-C SQLEOF     Const('02000');
056600240220  Dcl-C SQUOTE     Const('''');
056700240220
056800240220  // Declare standalone variables...................................................................
056900240220  Dcl-S ForClause     Char(  64);
057000240220  Dcl-S GroupByClause Char( 128);
057100240220  Dcl-S OrderByClause Char( 128);
057200240220  Dcl-S SelectClause  Char( 256);
057300240220  Dcl-S SortSeqAsc    Char(   4)  Inz(ASCENDING);
057400240220  Dcl-S SortSeqDsc    Char(   4)  Inz(DESCENDING);
057500240220  Dcl-S SQLStmt       Char(1024);
057600240220  Dcl-S WhereClause   Char( 256);
057700240220
057800240220  // Going down one level in the message queue......................................................
057900240220  MsgQNbr_Cur += 1;
058000240220
058100240220  // Build the SQL select clause....................................................................
058200240220  SelectClause = 'select * from "' + PayCodeF + '"';
058300240220
058400240220  // Build the SQL where clause.....................................................................
058500240220  WhereClause = ' where PAPAYCODE = ' + SQUOTE + INFO_R.PAPAYCODE + SQUOTE;
058600240220
058700240220  // Build the SQL group by clause(not needed)......................................................
058800240220  GroupByClause = SPACE;
058900240220
059000240220  // Build the SQL order by clause..................................................................
059100240220  OrderByClause = 'order by PAPAYCODE ' + SortSeqAsc;
059200240220
059300240220  // Build the SQL for clause.......................................................................
059400240220  ForClause = 'for read only';
059500240220
059600240220  // Build the SQL statement separating each clause by a space......................................
059700240220  SQLStmt = %Trim(SelectClause) + SPACE + %Trim(WhereClause) + SPACE + %Trim(GroupByClause) +
059800240220            SPACE + %Trim(OrderByClause) + SPACE + %TrimR(ForClause);
059900240220
060000240220  // Commit must be set to none since table is not journaled........................................
060100240220  Exec SQL Set Option Commit = *NONE, Closqlcsr = *ENDMOD;
060200240220
060300240220  // Declare the cursor for SQLStmt.................................................................
060400240220  Exec SQL Declare InputFile cursor for DynSQLStmt;
060500240220
060600240220  // Prepare the SQLStmt as initialized in the declare setion.......................................
060700240220  Exec SQL Prepare DynSQLStmt from :SQLStmt;
060800240220
060900240220  // Open the cursor for reading of the data and make sure data was retrieved.......................
061000240220  Exec SQL Open InputFile;
061100240220  If SQLState <> SQLOK;
061200240220    Wrn0000.Field1 = SQLStmt;
061300240220    SndPgmMsg( Wrn_NoDtaRt : MsgFile_Dft : Wrn0000 : %Len(Wrn0000) : MsgTy_Diag : MsgQ_Cur :
061400240220               MsgQNbr_Cur : MsgKey : APIErrC );
061500240220    DataErr_89 = *ON;
061600240220  EndIf;
061700240220
061800240220  // Read the data into the data structure and wrtie it to the file.................................
061900240220  If SQLState = SQLOK and DataErr_89 = *OFF;
062000240220    Exec SQL Fetch next from InputFile into :DataIn;
062100240220
062200240220    DoW SQLState = SQLOK and SQLState <> SQLEOF;
062300240220      EVAL-Corr INFO_R = DataIn;
062400240419      SavPayClass      = DataIn.PACLASS;         // Need to save original value to check for change
062500240419      If DataIn.PAGENXREF <> *BLANKS;
062600240419        Chain(E) (DataIn.PAGENXREF) PCDR;
062700240419        If %Found and not %Error;
062800240419          INFO_R.PCDDESC = PCDDESC;              // Populate the generic pay code description
062900240419        EndIf;
063000240419      EndIf;
063100240220      Write DSP.MCM0201 INFO_R;
063200240220      Exec SQL Fetch next from InputFile into :DataIn;
063300240220    EndDo;
063400240220
063500240220  EndIf;
063600240220
063700240220  // Close the cursor once the data has been read...................................................
063800240220  Exec SQL Close InputFile;
063900240220
064000240417  // No records read from input file, so show warning message.......................................
064100240220  If SQLState <> SQLOK;
064200240220    CPF9898.Field1 = 'No data found for pay code. Contact IT if problem persists';
064300240220    SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
064400240220               MsgQNbr_Cur : MsgKey : APIErrC );
064500240220    DataErr_89 = *ON;
064600240220  EndIf;
064700240220
064800240220  // Going up one level in the message queue........................................................
064900240220  MsgQNbr_Cur -= 1;
065000240220
065100240220End-Proc RtvPayCodes;
065200240220
065300240220//--------------------------------------------------------------------------------------------------
065400240416//- SUBPROCEDURE: ProcessPrompt                                                                    -
065500240220//- FUNCTION....: Process The F4 Prompt Command                                                    -
065600240418//- EXPLANATION.: Display the pay code lookup window or the generic pay code lookup window based   -
065700240418//-               upon the field being prompted. If a code is passed back, then fill in the        -
065800240418//-               corresponding field with the correct value. If a code is not passed back, then   -
065900240418//-               do nothing.                                                                      -
066000240220//-                                                                                                -
066100240220//- - - - - - - - - - - - - - - - - -   P A R A M E T E R S  - - - - - - - - - - - - - - - - - - - -
066200240220//      Name      I/O                                  Description                                 -
066300240220// -------------- --- ---------------------------------------------------------------------------- -
066400240220//- PromptField   In  The field that the cursor was on when F4 was pressed                         -
066500240220//-                                                                                                -
066600240220//- - - - - - - - - - - - - - - - - - -  C O N S T A N T S   - - - - - - - - - - - - - - - - - - - -
066700240220//-      Name                                          Description                                 -
066800240220//- --------------   ----------------------------------------------------------------------------- -
066900240418//- ALTPAYCDEFLD     Alternate Pay code field PAALTPAYCD being prompted                            -
067000240418//- GENPAYCDEFLD     Generic pay code field PAGENXREF being prompted                               -
067100240220//--------------------------------------------------------------------------------------------------
067200240416Dcl-Proc ProcessPrompt;
067300240220
067400240220  // Parameters passed to subprocedure..............................................................
067500240220  Dcl-PI *n;
067600240220    PromptField Char(10) Value;
067700240220  End-PI;
067800240220
067900240220  // Declare constants..............................................................................
068000240418  Dcl-C ALTPAYCDEFLD Const('PAALTPAYCD');
068100240418  Dcl-C GENPAYCDEFLD Const('PAGENXREF ');
068200240220
068300240220  // Going down one level in the message queue......................................................
068400240220  MsgQNbr_Cur += 1;
068500240220
068600240418  // Alternate pay code lookup......................................................................
068700240418  If PromptField = ALTPAYCDEFLD;
068800240418    PayCdeLkUp( MyLDA.Group : PC.PayCode : PC.PayCdeDsc : PC.ErrorMsg );
068900240418    If PC.PayCode <> *BLANKS and PC.ErrorMsg = *BLANKS;
069000240418      INFO_R.PAALTPAYCD = PC.PayCode;
069100240418      P2AltPC_92 = *ON;                          // Turn on position to alternate pay code
069200240418    ElseIf PC.ErrorMsg <> *BLANKS;
069300240418      CPF9898.Field1 = PC.ErrorMsg;
069400240418      SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
069500240418                 MsgQNbr_Cur : MsgKey : APIErrC );
069600240418      DataErr_89 = *ON;
069700240418    Else;
069800240418      P2AltPC_92 = *ON;                          // Turn on position to alternate pay code
069900240418    EndIf;
070000240418
070100240418  // Generic pay code lookup........................................................................
070200240418  ElseIf PromptField = GENPAYCDEFLD;
070300240220    GenPayCdeLkUp( GPC.GenPayCde : GPC.GenPyCdDsc : GPC.ErrorMsg );
070400240220    If GPC.GenPayCde <> *BLANKS and GPC.ErrorMsg = *BLANKS;
070500240220      INFO_R.PAGENXREF = GPC.GenPayCde;
070600240419      INFO_R.PCDDESC   = GPC.GenPyCdDsc;
070700240418      P2GenXR_93 = *ON;                          // Turn on position to generic cross reference code
070800240220    ElseIf PC.ErrorMsg <> *BLANKS;
070900240220      CPF9898.Field1 = GPC.ErrorMsg;
071000240220      SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
071100240220                 MsgQNbr_Cur : MsgKey : APIErrC );
071200240220      DataErr_89 = *ON;
071300240418    Else;
071400240418      P2GenXR_93 = *ON;                          // Turn on position to generic cross reference code
071500240220    EndIf;
071600240220  EndIf;
071700240418
071800240418  // Add indicator needs to be turned on again when adding record if there is no error..............
071900240418  If not DataErr_89 and AddChgDsp = ADD;
072000240418    AddCode_36 = *ON;
072100240418  EndIf;
072200240220
072300240220  // Going up one level in the message queue........................................................
072400240220  MsgQNbr_Cur -= 1;
072500240220
072600240416End-Proc ProcessPrompt;
072700240220
072800240220//--------------------------------------------------------------------------------------------------
072900240416//- SUBPROCEDURE: VldPayCodeData                                                                   -
073000240220//- FUNCTION....: Validate Changes Made To The Pay Code Data                                       -
073100240416//- EXPLANATION.: The pay code data needs to be validated before it is written to the file. When   -
073200240416//-               adding pay codes to the file, the pay code being added needs to be checked to    -
073300240416//-               make sure that it is not already in the file. When the pay code data is being    -
073400240416//-               changed, the pay code cannot be modified.                                        -
073500240220//-                                                                                                -
073600240220//- - - - - - - - - - - - - - - - - - -  C O N S T A N T S   - - - - - - - - - - - - - - - - - - - -
073700240220//-      Name                                          Description                                 -
073800240220//- --------------   ----------------------------------------------------------------------------- -
073900240220//- PAYCLSCHK        Pay code class permitted values when previous value was also one of these     -
074000240220//- STOPREINS        Validation for fields with allowed values of blank, R, or S                   -
074100240220//- VLDIGNRST        Valid ignore staqtement values                                                -
074200240220//- VLDPAYCLS        Valid pay class codes                                                         -
074300240220//- VLDPAYTYP        Valid pay types                                                               -
074400240220//- YESNOBLNK        Validation for fields with allowed values of blank, N, or Y                   -
074500240220//--------------------------------------------------------------------------------------------------
074600240416Dcl-Proc VldPayCodeData;
074700240220
074800240220  // Declare constants..............................................................................
074900240220  Dcl-C MBMCLSCHK Const('123489');
075000240220  Dcl-C MBM068CHK Const('123478');
075100240220  Dcl-C MBM577CHK Const('ABCDEP ');
075200240220  Dcl-C MBM578CHK Const('ABDP ');
075300240220  Dcl-C MBM579CHK Const('ABDP ');
075400240220  Dcl-C PAYCLSCHK Const('1234');
075500240220  Dcl-C STOPREINS Const('RS ');
075600240220  Dcl-C VLDIGNRST Const('NRY ');
075700240220  Dcl-C VLDPAYCLS Const('1234789 ');
075800240220  Dcl-C VLDPAYTYP Const('01 ');
075900240220  Dcl-C YESNOBLNK Const('YN ');
076000240220
076100240220  // Going down one level in the message queue......................................................
076200240220  MsgQNbr_Cur += 1;
076300240220
076400240416  // Pay code cannot be blank.......................................................................
076500240220  If INFO_R.PAPAYCODE = *BLANKS;
076600240220    ERR0024.Field1 = 'Account Type';
076700240220    SndPgmMsg( Err_MisValu : MsgFile_Dft : Err0024 : %Len(Err0024) : MsgTy_Diag : MsgQ_Cur :
076800240220               MsgQNbr_Cur : MsgKey : APIErrC );
076900240220    PayCode_40 = *ON;
077000240220    DataErr_89 = *ON;
077100240220  EndIf;
077200240220
077300240416  // See if the pay code already exists in the file.................................................
077400240220  If AddCode_36 = *ON;
077500240417    SetLL(E) (INFO_R.PAPAYCODE) PAYD.PAYDR;
077600240220    If %Equal and not %Error;
077700240220      ERR0029.Field1 = INFO_R.PAPAYCODE;
077800240220      ERR0029.Field2 = PayCodeF;
077900240220      SndPgmMsg( Err_KeyValu : MsgFile_Dft : Err0029 : %Len(Err0029) : MsgTy_Diag : MsgQ_Cur :
078000240220                 MsgQNbr_Cur : MsgKey : APIErrC );
078100240220      PayCode_40 = *ON;
078200240220      DataErr_89 = *ON;
078300240417    ElseIf %Error;
078400240220      CPF9898.Field1 = 'Issues checking the existance of the pay code in the Pay Code Desc file';
078500240220      SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
078600240220                 MsgQNbr_Cur : MsgKey : APIErrC );
078700240417      PayCode_40 = *ON;
078800240220      DataErr_89 = *ON;
078900240220    EndIf;
079000240220  EndIf;
079100240220
079200240220  // Inactive date is invalid.......................................................................
079300240220  If INFO_R.PAINACDT <> *ZERO;
079400240220    Test(DE) *USA INFO_R.PAINACDT;
079500240220    If %Error;
079600240220      SndPgmMsg( Err_InvDat : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
079700240220      MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC );
079800240220      InactDt_41 = *ON;
079900240220      DataErr_89 = *ON;
080000240220    EndIf;
080100240220  EndIf;
080200240220
080300240220  // Pay code description cannot be blanks..........................................................
080400240220  If INFO_R.PADESC = *BLANKS;
080500240220    ERR0024.Field1 = 'Pay Code Description';
080600240220    SndPgmMsg( Err_MisValu : MsgFile_Dft : Err0024 : %Len(Err0024) : MsgTy_Diag : MsgQ_Cur :
080700240220    MsgQNbr_Cur : MsgKey : APIErrC );
080800240220    PyCdDsc_42 = *ON;
080900240220    DataErr_89 = *ON;
081000240220  EndIf;
081100240220
081200240220  // Pay code type must be blank, 0, or 1...........................................................
081300240220  If %Check(VLDPAYTYP : INFO_R.PATYPE) <> *ZERO;
081400240220    ERR0032.Field1 = 'pay code type';
081500240220    ERR0032.Field2 = 'blank, 0 (debit), or 1 (credit)';
081600240220    SndPgmMsg( Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
081700240220    MsgQNbr_Cur : MsgKey : APIErrC );
081800240220    PyCdTyp_43 = *ON;
081900240220    DataErr_89 = *ON;
082000240220  EndIf;
082100240220
082200240220  // Pay code class must be blank, 1, 2, 3, 4, 7, 8, or 9...........................................
082300240220  If %Check(VLDPAYCLS : INFO_R.PACLASS) <> *ZERO;
082400240220    Err0032.Field1 = 'pay code class';
082500240220    Err0032.Field2 = 'blank, 1, 2, 3, 4, 7, 8, or 9';
082600240220    SndPgmMsg( Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
082700240220    MsgQNbr_Cur : MsgKey : APIErrC );
082800240220    PyCdCls_44 = *ON;
082900240220    DataErr_89 = *ON;
083000240220  EndIf;
083100240220
083200240220  // If pay code class between 1 and 4 and it is changed, it must stay between 1 and 4..............
083300240220  If SavPayClass <> INFO_R.PACLASS;
083400240220    If %Check(PAYCLSCHK : SavPayClass) = *ZERO and %Check(PAYCLSCHK : INFO_R.PACLASS) <> *ZERO;
083500240220      Err0038.Field1 = INFO_R.PACLASS;
083600240220      Err0038.Field2 = SavPayClass;
083700240220      SndPgmMsg( Err_InvVal : MsgFile_Dft : Err0038 : %Len(Err0038) : MsgTy_Diag : MsgQ_Cur :
083800240220      MsgQNbr_Cur : MsgKey : APIErrC );
083900240220      PyCdCls_44 = *ON;
084000240220      DataErr_89 = *ON;
084100240220    EndIf;
084200240220
084300240220    // Cannot change class if there is any activity for paycode and new class is not between 1 - 4..
084400240220    If %Check(PAYCLSCHK : SavPayClass) <> *ZERO or %Check(PAYCLSCHK : INFO_R.PACLASS) <> *ZERO;
084500240220      Chain(E) (INFO_R.PAPAYCODE) PMSR;
084600240220      If not %Found and not %Error;
084700240220        Chain(E) (INFO_R.PAPAYCODE) PMTR;
084800240220        If %Found;
084900240220          SndPgmMsg( Err_ActPmts : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
085000240220          MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC );
085100240220          PyCdCls_44 = *ON;
085200240220          DataErr_89 = *ON;
085300240220        ElseIf %Error;
085400240220          CPF9898.Field1 = 'Issues checking for activity in the Revenue Payment file ' + PmtRevenuF;
085500240220          SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
085600240220          MsgQNbr_Cur : MsgKey : APIErrC );
085700240220          PyCdCls_44 = *ON;
085800240220          DataErr_89 = *ON;
085900240220        EndIf;
086000240220      ElseIF %Found;
086100240220        SndPgmMsg( Err_ActPmts : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
086200240220        MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC );
086300240220        PyCdCls_44 = *ON;
086400240220        DataErr_89 = *ON;
086500240220      ElseIf %Error;
086600240220        CPF9898.Field1 = 'Issues checking for activity in the Nonrevenue Payment file ' + PmtNonRevF;
086700240220        SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
086800240220        MsgQNbr_Cur : MsgKey : APIErrC );
086900240220        PyCdCls_44 = *ON;
087000240220        DataErr_89 = *ON;
087100240220      EndIf;
087200240220    EndIf;
087300240220  EndIf;
087400240220
087500240220  // Pay code class must be blank (informational) if ignore on statement equal to R.................
087600240220  If INFO_R.PACLASS <> *BLANK and INFO_R.PAIGNORE = 'R';
087700240220    CPF9898.Field1 = 'Ignore on statement of R requires pay code class to be informational (blank)';
087800240220    SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
087900240220    MsgQNbr_Cur : MsgKey : APIErrC );
088000240220    PyCdCls_44 = *ON;
088100240220    IgnrStm_45 = *ON;
088200240220    DataErr_89 = *ON;
088300240220  EndIf;
088400240220
088500240220  // Ignore on statement must be blank, N, R, or Y..................................................
088600240220  If %Check(VLDIGNRST : INFO_R.PAIGNORE) <> *ZERO;
088700240220    Err0032.Field1 = 'ignore on statement';
088800240220    Err0032.Field2 = 'blank, N, R, or Y';
088900240220    SndPgmMsg( Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
089000240220    MsgQNbr_Cur : MsgKey : APIErrC );
089100240220    IgnrStm_45 = *ON;
089200240220    DataErr_89 = *ON;
089300240220  EndIf;
089400240220
089500240220  // Post to the general ledger must be blank, N, or Y..............................................
089600240220  If %Check(YESNOBLNK : INFO_R.PAPOSTGL) <> *ZERO;
089700240220    Err0032.Field1 = 'post to general ledger';
089800240220    Err0032.Field2 = 'blank, N, or Y';
089900240220    SndPgmMsg( Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
090000240220    MsgQNbr_Cur : MsgKey : APIErrC );
090100240220    Post2GL_46 = *ON;
090200240220    DataErr_89 = *ON;
090300240220  EndIf;
090400240220
090500240220  // Stop/Reinstate staements must be blank, R, or S................................................
090600240220  If %Check(STOPREINS : INFO_R.PASTOP) <> *ZERO;
090700240220    Err0032.Field1 = 'stop/reinstate statement';
090800240220    Err0032.Field2 = 'blank, R, or S';
090900240220    SndPgmMsg( Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
091000240220    MsgQNbr_Cur : MsgKey : APIErrC );
091100240220    SRStmnt_47 = *ON;
091200240220    DataErr_89 = *ON;
091300240220  EndIf;
091400240220
091500240220  // Alternate pay code for delinquent and final notices............................................
091600240417  If INFO_R.PAALTPAYCD <> *BLANKS;
091700240417    Chain(E) (INFO_R.PAALTPAYCD) PAYD.PAYDR PAYD_R;
091800240417    If %Found;
091900240417      If INFO_R.PACLASS <> *BLANK and INFO_R.PACLASS <> '9';
092000240417        SndPgmMsg( Err_PyCdCls : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
092100240417                  MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC );
092200240417        PyCdCls_44 = *ON;
092300240417        AltPyCd_48 = *ON;
092400240417        DataErr_89 = *ON;
092500240417      EndIf;
092600240417    ElseIf not %Found;
092700240417      Err0036.Field1 = 'alternate pay code';
092800240417      SndPgmMsg( Err_NotInFl : MsgFile_Dft : Err0036 : %Len(Err0036) : MsgTy_Diag : MsgQ_Cur :
092900240417      MsgQNbr_Cur : MsgKey : APIErrC );
093000240417      AltPyCd_48 = *ON;
093100240417      DataErr_89 = *ON;
093200240417    ElseIf %Error;
093300240417      CPF9898.Field1 = 'Error occurred while validating the alternate pay code';
093400240417      SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
093500240417      MsgQNbr_Cur : MsgKey : APIErrC );
093600240417      AltPyCd_48 = *ON;
093700240417      DataErr_89 = *ON;
093800240417    EndIf;
093900240417  EndIf;
094000240220
094100240220  // Stop/Reinstate automatic rebill................................................................
094200240220  If %Check(STOPREINS : INFO_R.PARBLBYPAS) <> *ZERO;
094300240220    Err0032.Field1 = 'stop/reinstate automatic rebill';
094400240220    Err0032.Field2 = 'blank, R, or S';
094500240220    SndPgmMsg( Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
094600240220    MsgQNbr_Cur : MsgKey : APIErrC );
094700240220    SRAutoR_49 = *ON;
094800240220    DataErr_89 = *ON;
094900240220  EndIf;
095000240220
095100240220  // Stop/Reinstate automatic rebill must be Y if pay code class is 3...............................
095200240220  If INFO_R.PACLASS = '3' and INFO_R.PARBLBYPAS <> 'Y';
095300240220    Err0032.Field1 = 'stop/reinstate automatic rebill';
095400240220    Err0032.Field2 = 'Y when pay code class is 3';
095500240220    SndPgmMsg( Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
095600240220    MsgQNbr_Cur : MsgKey : APIErrC );
095700240220    SRAutoR_49 = *ON;
095800240220    DataErr_89 = *ON;
095900240220  EndIf;
096000240220
096100240220  // Stop/Reinstate automatic rebill is set to bypass, but override days are specified..............
096200240220  If INFO_R.PARBLBYPAS = 'S' and INFO_R.PARBLDAYS <> *ZERO;
096300240220    CPF9898.Field1 = 'Automatic rebill is set to bypass, but override days are not equal to zero';
096400240220    SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
096500240220    MsgQNbr_Cur : MsgKey : APIErrC );
096600240220    SRAutoR_49 = *ON;
096700240220    ReblDys_50 = *ON;
096800240220    DataErr_89 = *ON;
096900240220  EndIf;
097000240220
097100240220  // Override automatic rebill days.................................................................
097200240220  If INFO_R.PARBLDAYS < *ZERO;
097300240220    Err0019.Field1 = 'override automatic rebill days';
097400240220    SndPgmMsg( Err_GTZero : MsgFile_Dft : Err0019 : %Len(Err0019) : MsgTy_Diag : MsgQ_Cur :
097500240220    MsgQNbr_Cur : MsgKey : APIErrC );
097600240220    ReblDys_50 = *ON;
097700240220    DataErr_89 = *ON;
097800240220  EndIf;
097900240220
098000240220  // Installment payment pay code...................................................................
098100240220  If %Check(YESNOBLNK : INFO_R.PAINSTLMNT) <> *ZERO;
098200240220    Err0032.Field1 = 'installment payment pay code';
098300240220    Err0032.Field2 = 'blank, N, or Y';
098400240220    SndPgmMsg( Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
098500240220    MsgQNbr_Cur : MsgKey : APIErrC );
098600240220    InsPymt_51 = *ON;
098700240220    DataErr_89 = *ON;
098800240220  EndIf;
098900240220
099000240220  // Print on MBM068 must be blank, N, or Y.........................................................
099100240220  If %Check(YESNOBLNK : INFO_R.PAPRT068) <> *ZERO;
099200240220    Err0032.Field1 = 'print on MBMB068';
099300240220    Err0032.Field2 = 'blank, N, or Y';
099400240220    SndPgmMsg( Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
099500240220               MsgQNbr_Cur : MsgKey : APIErrC );
099600240220    PrtMB68_52 = *ON;
099700240220    DataErr_89 = *ON;
099800240220  EndIf;
099900240220
100000240220  // Print on MBM068 must be blank or N for the pay code classes between 1 and 8....................
100100240220  If %Check(MBM068CHK : INFO_R.PACLASS) = *ZERO and INFO_R.PAPRT068='Y';
100200240220    Err0032.Field1 = 'print on MBMB068';
100300240220    Err0032.Field2 = 'blank or N when the pay code class is between 1 and 8';
100400240220    SndPgmMsg( Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
100500240220               MsgQNbr_Cur : MsgKey : APIErrC );
100600240220    PrtMB68_52 = *ON;
100700240220    DataErr_89 = *ON;
100800240220  EndIf;
100900240220
101000240220  // Generic pay code value not found in Generic Pay Code file......................................
101100240419  Clear INFO_R.PCDDESC;
101200240220  If INFO_R.PAGENXREF <> *BLANKS;
101300240220    Chain(E) (INFO_R.PAGENXREF) PCDR;
101400240220    If %Found and INFO_R.PACLASS <> PCDCLASS;    // Pay code class entered must match the
101500240220      Err0041.Field1 = INFO_R.PACLASS;           // generic pay code class from the file
101600240220      Err0041.Field2 = PCDCLASS;
101700240220      SndPgmMsg( Err_PCClsNE : MsgFile_Dft : Err0041 : %Len(Err0041) : MsgTy_Diag : MsgQ_Cur :
101800240220                 MsgQNbr_Cur : MsgKey : APIErrC );
101900240220      GenPyCd_53 = *ON;
102000240220      DataErr_89 = *ON;
102100240220    ElseIf %Found;
102200240419      INFO_R.PCDDESC = PCDDESC;                // Populate the generic pay code description
102300240220    ElseIf not %Found;
102400240220      ERR0036.Field1 = 'Generic Pay Code';
102500240220      SndPgmMsg( Err_NotInFl : MsgFile_Dft : Err0036 : %Len(Err0036) : MsgTy_Diag : MsgQ_Cur :
102600240220                 MsgQNbr_Cur : MsgKey : APIErrC );
102700240220      GenPyCd_53 = *ON;
102800240220      DataErr_89 = *ON;
102900240220    ElseIf %Error;
103000240220      CPF9898.Field1 = 'Issues checking the generic pay code in the Generic Pay Code file M.PCD';
103100240220      SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
103200240220                 MsgQNbr_Cur : MsgKey : APIErrC );
103300240220      GenPyCd_53 = *ON;
103400240220      DataErr_89 = *ON;
103500240220    EndIf;
103600240220
103700240220    // Generic pay code cannot be assigned to a different pay code..................................
103800240220    Chain(E) (INFO_R.PAGENXREF) PYD2R;
103900240220    If %Found and INFO_R.PAPAYCODE <> PAPAYCODE;
104000240220      Err0042.Field1 = INFO_R.PAGENXREF;
104100240220      Err0042.Field2 = PAPAYCODE;
104200240220      Err0042.Field3 = INFO_R.PAPAYCODE;
104300240418      SndPgmMsg( Err_GPCAsgn : MsgFile_Dft : Err0042 : %Len(Err0042) : MsgTy_Diag : MsgQ_Cur :
104400240220                 MsgQNbr_Cur : MsgKey : APIErrC );
104500240220      GenPyCd_53 = *ON;
104600240220      DataErr_89 = *ON;
104700240220    EndIf;
104800240220  EndIf;
104900240220
105000240418  // Follow up number of days must not be less than zero............................................
105100240220  If INFO_R.PAFLWUP < *ZERO;
105200240220    Err0019.Field1 = 'follow up number of days';
105300240220    SndPgmMsg( Err_GTZero : MsgFile_Dft : Err0019 : %Len(Err0019) : MsgTy_Diag : MsgQ_Cur :
105400240220    MsgQNbr_Cur : MsgKey : APIErrC );
105500240220    FlUpDys_54 = *ON;
105600240220    DataErr_89 = *ON;
105700240220  EndIf;
105800240220
105900240220  // Follow up number of days can only be entered on informational pay code classes of blank and 9..
106000240220  If INFO_R.PAFLWUP > *ZERO and INFO_R.PACLASS <> *BLANK and INFO_R.PACLASS <> '9';
106100240220    SndPgmMsg( Err_FlwUpDy : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
106200240220               MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC );
106300240220    FlUpDys_54 = *ON;
106400240220    DataErr_89 = *ON;
106500240220  EndIf;
106600240220
106700240220  // Code in column MBM577 must be filled in if print report option is not N........................
106800240220  If %Check(MBMCLSCHK : INFO_R.PACLASS) = *ZERO;
106900240220    Chain(E) ('3' : 'AR' : 'MB577') RPT01;
107000240220    If %Found and not %Error and RPRPRT <> 'N' and INFO_R.PAMBM577 = *BLANK;
107100240220      SndPgmMsg( Err_ColFlgB : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
107200240220                 MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC );
107300240220      MBM577E_55 = *ON;
107400240220      DataErr_89 = *ON;
107500240220    ElseIf %Error;
107600240220      CPF9898.Field1 = 'Issues validating the MBM577 code against the Report file';
107700240220      SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
107800240220                 MsgQNbr_Cur : MsgKey : APIErrC );
107900240220      MBM577E_55 = *ON;
108000240220      DataErr_89 = *ON;
108100240220    EndIf;
108200240220
108300240220    // Code in column MBM578 must be filled in if print report option is not N......................
108400240220    Chain(E) ('3' : 'AR' : 'MB578') RPT01;
108500240220    If %Found and not %Error and RPRPRT <> 'N' and INFO_R.PAMBM578 = *BLANK;
108600240220      SndPgmMsg( Err_ColFlgB : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
108700240220                 MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC );
108800240220      MBM578E_56 = *ON;
108900240220      DataErr_89 = *ON;
109000240220    ElseIf %Error;
109100240220      CPF9898.Field1 = 'Issues validating the MBM578 code against the Report file';
109200240220      SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
109300240220                 MsgQNbr_Cur : MsgKey : APIErrC );
109400240220      MBM578E_56 = *ON;
109500240220      DataErr_89 = *ON;
109600240220    EndIf;
109700240220
109800240220    // Code in column MBM579 must be filled in if print report option is not N......................
109900240220    Chain(E) ('3' : 'AR' : 'MB579') RPT01;
110000240220    If %Found and not %Error and RPRPRT <> 'N' and INFO_R.PAMBM579 = *BLANK;
110100240220      SndPgmMsg( Err_ColFlgB : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
110200240220                 MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC );
110300240220      MBM579E_57 = *ON;
110400240220      DataErr_89 = *ON;
110500240220    ElseIf %Error;
110600240220      CPF9898.Field1 = 'Issues validating the MBM579 code against the Report file';
110700240220      SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
110800240220                 MsgQNbr_Cur : MsgKey : APIErrC );
110900240220      MBM579E_57 = *ON;
111000240220      DataErr_89 = *ON;
111100240220    EndIf;
111200240220  EndIf;
111300240220
111400240220  // Check column MBM577 value against allowed values...............................................
111500240220  If %Check(MBM577CHK : INFO_R.PAMBM577) <> *ZERO;
111600240220    Err0032.Field1 = 'column MBMB577';
111700240220    Err0032.Field2 = 'blank, A, B, C, D, E, or P';
111800240220    SndPgmMsg( Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
111900240220               MsgQNbr_Cur : MsgKey : APIErrC );
112000240220    MBM577E_55 = *ON;
112100240220    DataErr_89 = *ON;
112200240220  EndIf;
112300240220
112400240220  // Check column MBM578 value against allowed values...............................................
112500240220  If %Check(MBM578CHK : INFO_R.PAMBM578) <> *ZERO;
112600240220    Err0032.Field1 = 'column MBMB578';
112700240220    Err0032.Field2 = 'blank, A, B, D, or P';
112800240220    SndPgmMsg( Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
112900240220               MsgQNbr_Cur : MsgKey : APIErrC );
113000240220    MBM578E_56 = *ON;
113100240220    DataErr_89 = *ON;
113200240220  EndIf;
113300240220
113400240220  // Check column MBM579 value against allowed values...............................................
113500240220  If %Check(MBM578CHK : INFO_R.PAMBM578) <> *ZERO;
113600240220    Err0032.Field1 = 'column MBMB579';
113700240220    Err0032.Field2 = 'blank, A, B, D, or P';
113800240220    SndPgmMsg( Err_InvVal : MsgFile_Dft : Err0032 : %Len(Err0032) : MsgTy_Diag : MsgQ_Cur :
113900240220               MsgQNbr_Cur : MsgKey : APIErrC );
114000240220    MBM579E_57 = *ON;
114100240220    DataErr_89 = *ON;
114200240220  EndIf;
114300240220
114400240220  // Going up one level in the message queue........................................................
114500240220  MsgQNbr_Cur -= 1;
114600240220
114700240416End-Proc VldPayCodeData;
114800240220
114900240220//--------------------------------------------------------------------------------------------------
115000240416//- SUBPROCEDURE: ChgPayCodeData                                                                   -
115100240220//- FUNCTION....: Update the Miscellaneous Code                                                    -
115200240416//- EXPLANATION.: Change the pay code data in the Pay Code Description file. Before updating the   -
115300240416//-               code, a record of a before and after data change snapshot needs to be saved to   -
115400240416//-               the Miscellaneous Codes Maintenance Audit file.                                  -
115500240220//--------------------------------------------------------------------------------------------------
115600240416Dcl-Proc ChgPayCodeData;
115700240220
115800240220  // Going down one level in the message queue......................................................
115900240220  MsgQNbr_Cur += 1;
116000240220
116100240220  // Make sure the record exists in the EDI Master file before updating it..........................
116200240220  Chain(E) (INFO_R.PAPAYCODE) PAYD.PAYDR PAYD_R;
116300240220  If %Found(PAYD) and not %Error;
116400240220    Eval-Corr AudtDta1 = PAYD_R;                 // File fields data structure for comparison
116500240220    Eval-Corr AudtDta2 = INFO_R;                 // Screen fields data structure for comparison
116600240220    If AudtDta2 <> AudtDta1;                     // Were changes made to the screen data
116700240220
116800240220      // Save audit record to the audit file before changing the record in the Account Type file....
116900240220      WrtAudDta( MyLDA.Group : RECID : INFO_R.PAPAYCODE : CHANGE : AudtDta1 : AudtDta2 :
117000240220                 WAD.ErrorMsg );
117100240220      If WAD.ErrorMsg <> *BLANKS;                  // Issues saving the audit data?
117200240220        CPF9898.Field1 = WAD.ErrorMsg;
117300240220        SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
117400240220                   MsgQNbr_Cur : MsgKey : APIErrC );
117500240220        DataErr_89 = *ON;
117600240220      Else;
117700240220        Eval-Corr PAYD_R = INFO_R;                 // Move the screen data to the file
117800240220        PAYD_R.PACHGDAT = %Dec(%Date():*USA);
117900240220        PAYD_R.PACHGUSR = JobUser;
118000240220        Update PAYD.PAYDR PAYD_R;
118100240220        CPF9898.Field1 = 'Pay code ' + INFO_R.PAPAYCODE + ' updated in Pay Code Description file';
118200240220      EndIf;
118300240220    Else;
118400240220      CPF9898.Field1 = 'No data changes where made to the pay code ' + INFO_R.PAPAYCODE +
118500240220      '; therefore, no updates were done';
118600240220    EndIf;
118700240220
118800240220  ElseIF not %Found;
118900240220    CPF9898.Field1 = 'No pay code exists for ' + INFO_R.PAPAYCODE +
119000240220                     ' in the Pay Code Description file';
119100240220  Else;
119200240220    CPF9898.Field1 = 'Error occured when updating pay code ' + INFO_R.PAPAYCODE +
119300240220                     ' in the Pay Code Description file';
119400240220  EndIf;
119500240220
119600240220  // Show the action taken message..................................................................
119700240220  SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
119800240220  MsgQNbr_Cur : MsgKey : APIErrC );
119900240220
120000240220  // Going up one level in the message queue........................................................
120100240220  MsgQNbr_Cur -= 1;
120200240220
120300240416End-Proc ChgPayCodeData;
120400240220
120500240220//--------------------------------------------------------------------------------------------------
120600240416//- SUBPROCEDURE: AddPayCodeData                                                                   -
120700240416//- FUNCTION....: Add the Pay Code To The Pay Cdoe Description File                                -
120800240416//- EXPLANATION.: Add the new pay code to the Pay Code Description file. Before adding code to the -
120900240416//-               file, save a snapshot of the data that will be added to the Miscellaneous Codes  -
121000240416//-               Maintenance Audit file.                                                          -
121100240220//--------------------------------------------------------------------------------------------------
121200240416Dcl-Proc AddPayCodeData;
121300240220
121400240220  // Going down one level in the message queue......................................................
121500240220  MsgQNbr_Cur += 1;
121600240220
121700240416  // Save the record to the audit file before adding the record to the Pay Code Description file...
121800240220  Eval-Corr AudtDta1 = INFO_R;
121900240220  Clear AudtDta2;
122000240220  WrtAudDta( MyLDA.Group : RECID : INFO_R.PAPAYCODE : ADD : AudtDta1 : AudtDta2 : WAD.ErrorMsg );
122100240220  If WAD.ErrorMsg <> *BLANKS;                  // Issues saving the audit data?
122200240220    CPF9898.Field1 = WAD.ErrorMsg;
122300240220    SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
122400240220               MsgQNbr_Cur : MsgKey : APIErrC );
122500240220    DataErr_89 = *ON;
122600240220  Else;
122700240220
122800240416    // Add the account type to the Pay Code Description file........................................
122900240220    Clear PAYD_R;
123000240220    Eval-Corr PAYD_R = INFO_R;
123100240418    PAYD_R.PACHGDAT = %Dec(%Date():*USA);
123200240418    PAYD_R.PACHGUSR = JobUser;
123300240220    Write(E) PAYD.PAYDR PAYD_R;
123400240220    If not %Error;
123500240220      CPF9898.Field1 = 'Pay code ' + %Trim(INFO_R.PAPAYCODE) +
123600240220                       ' added to the Pay Code Description file';
123700240416      AddCode_36 = *OFF;                         // Data added, so turn add mode off
123800240416      DataAdded  = YES;                          // Allow added data to be changed
123900240416      RtvPayCodes();
124000240416    Else;
124100240220      CPF9898.Field1 = 'Error occured when adding the pay code ' + %Trim(INFO_R.PAPAYCODE) +
124200240220                       ' to the Pay Code Description file';
124300240220    EndIf;
124400240220  EndIf;
124500240220
124600240220  // Show the action taken message..................................................................
124700240220  SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
124800240220  MsgQNbr_Cur : MsgKey : APIErrC );
124900240220
125000240220  // Going up one level in the message queue........................................................
125100240220  MsgQNbr_Cur -= 1;
125200240220
125300240416End-Proc AddPayCodeData;
125400240220
125500240220//--------------------------------------------------------------------------------------------------
125600240220//- SUBPROCEDURE: CloseOpenFiles                                                                   -
125700240220//- FUNCTION....: Close Files Opened By This Program                                               -
125800240220//- EXPLANATION.: Some files were opened by this program so that the file could be overridden at   -
125900240220//-               the time it was opened. At the end of the program these files need to be closed. -
126000240220//--------------------------------------------------------------------------------------------------
126100240220Dcl-Proc CloseOpenFiles;
126200240220
126300240220  // Close the pay code description file............................................................
126400240220  If %Open(PAYD);
126500240220    Close(E) PAYD;
126600240220  EndIf;
126700240220
126800240220  // Close the generic pay code file................................................................
126900240220  If %Open(PCD);
127000240220    Close(E) PCD;
127100240220  EndIf;
127200240220
127300240220  // Close the nonrevenue payment logical...........................................................
127400240220  If %Open(PMS4);
127500240220    Close(E) PMS4;
127600240220  EndIf;
127700240220
127800240220  // Close the revenue payment logical..............................................................
127900240220  If %Open(PMT4);
128000240220    Close(E) PMT4;
128100240220  EndIf;
128200240220
128300240220  // Close the pay code generic pay code cross-reference logical....................................
128400240220  If %Open(PYD2);
128500240220    Close(E) PYD2;
128600240220  EndIf;
128700240220
128800240220  // Close the report file..........................................................................
128900240220  If %Open(RPT);
129000240220    Close(E) RPT;
129100240220  EndIf;
129200240220
129300240220End-Proc CloseOpenFiles;
129400240220
129500240220//--------------------------------------------------------------------------------------------------
129600240220// FUNCTION....: Center text within a field                                                        -
129700240220//--------------------------------------------------------------------------------------------------
129800240220/COPY QCPYSRC,F_CENTRTXT
