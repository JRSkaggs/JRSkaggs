000100240110**free
000200240313Ctl-Opt COPYRIGHT('©EMMI Physician Service, Inc. - 2024')
000300230725DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')
000400230725OPTION(*SRCSTMT:*NODEBUGIO:*NOUNREF)
000500230725DECEDIT('0.') ExtBinInt(*YES) OPTIMIZE(*BASIC);
000600230511//*************************************************************************************************/
000700230511//                                   EMMI Physician Service, Inc.                                  /
000800240313//                                               ©2024                                             /
000900230511//*************************************************************************************************/
001000240416// CREATE DATE: 04/16/2024                                                                         /
001100230511// PROGRAMMER.: Johnny Skaggs                                                                      /
001200240415// PROGRAM....: MCM0200R                                                                           /
001300240415// SYNOPSIS...: Pay Code Maintenance Selection                                                     /
001400240415// DESCRIPTION: Shows a screen that lists the unique pay codes for the customer. There is an       /
001500240415//              option column at the front of the pay codes that allows for the entry of a number  /
001600240415//              to display or change the pay code details, or delete the pay code. To add a new    /
001700240415//              pay code the F6 funtion key is pressed. You must have the authority to add, change /
001800240415//              or delete pay codes; otherwise, you can only view the pay code data. Actions of    /
001900240415//              add, change and delete on a pay code, will create a record in the customer         /
002000240415//              Miscellaneous Codes Maintenance Audit file (Mxx.AUDM). A check is done to make     /
002100240415//              the data was changed before updating the data, so that no unneccesary records are  /
002200240415//              written to the audit file.                                                         /
002300240207//                                                                                                 /
002400231206//++++++++++++++++++++++++++++++++++++++  P R A M A T E R S  ++++++++++++++++++++++++++++++++++++++/
002500231206//      NAME      I/O                                  DESCRIPTION                                 /
002600231206// -------------- --- ---------------------------------------------------------------------------- /
002700240416//  RetFncKey       Out ·Function key pressed in this program that needs to be returned to the     /
002800240416//                       calling program (for example, F03=Exit back to menu)                      /
002900240416//  RetMsgTyp       Out ·Program message type: ERR=Error, INF=Informational, WRN=Warning           /
003000240416//  RetPgmMsg       Out ·Message returned by this program to the calling program                   /
003100240416//                                                                                                 /
003200230511//++++++++++++++++++++++++++++++++++++++++++  F I L E S  ++++++++++++++++++++++++++++++++++++++++++/
003300231020//    NAME     OVERRIDDEN                                DESCRIPTION                               /
003400231020// ----------  ----------  ----------------------------------------------------------------------- /
003500240327// Mxx.PAYD    PAYD        Pay Code Description File                                               /
003600230511//                                                                                                 /
003700231101//++++++++++++++++++++++++++++++++  D A T A  S T R U C T U R E S  +++++++++++++++++++++++++++++++++/
003800231101//      NAME      I/O                                  DESCRIPTION                                 /
003900231101// -------------- --- ---------------------------------------------------------------------------- /
004000240415// AuditData1     Out This data structure contains the fields of the pay code data that are used   /
004100240415//                    for change comparison and are written to the customer Miscellaneous Codes    /
004200240415//                    Audit file (Mxx.AUDM).                                                       /
004300240415// AudtDta1       I/O The first purpose of this data structure is to hold the file data so that a  /
004400240415//                    comparison can be done between the file data and the screen data to see if   /
004500240415//                    any of the fields were changed. The second purpose of the data structure is  /
004600240415//                    to hold the file data on an add, change or delete record. This data is       /
004700240415//                    passed along to program that writes the data to the audit file.              /
004800240415// AudtDta2       I/O The first purpose of this data structure is to hold the screen data so that  /
004900240415//                    a comparison can be made between the screen data and the file data to see if /
005000240415//                    any of the fields were changed.  The second purpose of this data structure   /
005100240415//                    is to hold the after data on a change, so that there is before change and    /
005200240415//                    after change data passed along to program that writes the data to the audit  /
005300240415//                    file.                                                                        /
005400240116// DataIn         In  Allows the data to be retrieved from the input file by the SQL processing.   /
005500240116// MyLDA          In  Holds the data that is read in from the Local Data Area (LDA).               /
005600231101// WSInd          In  Since INDARA is used in the display file, mapping of the indicators must be  /
005700231101//                    done  in the program.  The indicators for the display are now accessed using /
005800231101//                    the  data structure. Turning on an indicator in the data structure will not  /
005900231101//                    turn on the corresponding *INxx indicator.                                   /
006000231101//                                                                                                 /
006100231127//+++++++++++++++++++++++++++++++++++++  C O N S T A N T S   ++++++++++++++++++++++++++++++++++++++/
006200231127//      NAME                                          DESCRIPTION                                  /
006300231127// --------------   ------------------------------------------------------------------------------ /
006400231127// ADD            - Add a record to the miscellaneous codes maintenance file                       /
006500231127// CHANGE         - Change a record in the miscellaneous codes maintenance file                    /
006600231127// DELETE         - Delete a record fromthe miscellaneous codes maintenance file                   /
006700240314// DISPLAY        - Display the data for the account type code                                     /
006800240315// ERROR          - Message passed back from program called is an error message                    /
006900240315// EXIT           - F03 passed back from calling program                                           /
007000231127// RECID          - Record identification                                                          /
007100231127// RTVBYCODE      - Retrieve records from file using miscellaneous code                            /
007200231127// RTVBYDESC      - Retrieve records from file using code description                              /
007300231127// RTVBYSRCH      - Retrieve records from file using search string                                 /
007400231127// SYSKEY         - System file key used to look up provider account information                   /
007500231127// YES            - Replacement for Y                                                              /
007600231127//                                                                                                 /
007700231101//++++++++++++++++++++++++++++++++++++++  V A R I A B L E S  ++++++++++++++++++++++++++++++++++++++/
007800230725//      NAME                                          DESCRIPTION                                  /
007900230725// --------------   ------------------------------------------------------------------------------ /
008000231110// CompanyName    - Name of the company who's data is being presented                              /
008100240415// PayCodeF       - Pay code description file PAYD overridden to this file Mxx.PAYD                /
008200240314// SavRRN         - Save of the main display relative record number                                /
008300230511//                                                                                                 /
008400230807//++++++++++++++++++++  F U N C T I O N  K E Y S  A N D  I N D I C A T O R S  +++++++++++++++++++++/
008500230725//     NAME                                         DESCRIPTION                                    /
008600230807// ----------   ---------------------------------------------------------------------------------- /
008700230807// F1_Help    - Context sensitive help                                                             /
008800230807// F3_Exit    - Exit program                                                                       /
008900240313// F5_Refresh - Refresh the screen, setting it back to the way it looked when called initially     /
009000240223// F6_AddCode - Add a new account type code to the Account Type Financial Class file               /
009100240327// F11_Toggle - Toggle between the code and code description to sort and search on                 /
009200230807// F12_Cancel - Cancel current action and return to previous screen                                /
009300240327// F14_Toggle - Toggle between showing all accounts and showing only active accounts               /
009400240327// F24_MorKys - Loop through the available function keys                                           /
009500240318// SFNxChg_25 - Mark subfile field as changed (SFLNXTCHG)                                          /
009600231030// ProtFld_28 - Protect the field from changes                                                     /
009700230807// InzSubF_29 - Initailze subfile (SFLINZ)                                                         /
009800230807// ClrSubF_30 - Subfile clear (SFLCLR)                                                             /
009900230807// DspCtlR_31 - Subfile Display Control (SFLDSPCTL)                                                /
010000231114// SortCol_34 - Highlight the column haeader of the data that is being sorted on                   /
010100231114// ScanMod_35 - Indicates that the search is in scan mode                                          /
010200231218// AddCode_36 - Add a new accounting type code                                                     /
010300231218// Inactiv_37 - Show/Hide inactive accounts                                                        /
010400240314// OnlyAct_38 - Show all or only active accounts                                                   /
010500231030// SubFEnd_39 - Display subfile more/bottom                                                        /
010600240415// OptNbrE_40 - Invalid option number entered                                                      /
010700231030// DataErr_89 - Data error found                                                                   /
010800240415// NxtFKys_91 - Show the next set of available function keys                                       /
010900230511//                                                                                                 /
011000230511//+++++++++++++++++++++++++++++++++  M O D I F I C A T I O N S  +++++++++++++++++++++++++++++++++++/
011100230511// DATE..: MM/DD/CCYY   PROGRAMMER: First and last name                                            /
011200230511// REASON: Project number or ticket number                                                         /
011300230511// MODS..: What changes were made to the program                                                   /
011400230511//*************************************************************************************************/
011500231206
011600240416// Passed parameters................................................................................
011700240416Dcl-PI *n;
011800240416  RetFncKey Char( 3);
011900240416  RetMsgTyp Char( 3);
012000240416  RetPgmMsg Char(78);
012100240416End-PI;
012200240416
012300230511// Declare, override and open files.................................................................
012400240415Dcl-F PAYD Disk Keyed Qualified Usage(*DELETE : *OUTPUT) ExtDesc('MXX.PAYD') ExtFile(PayCodeF) UsrOpn;
012500240415Dcl-F DSP  WorkStn Qualified ExtDesc('MCM0200D') ExtFile(*ExtDesc) InDDS(WsInd)
012600240415           SFile(MCM0200SFL : SFRRN);
012700230807
012800230807// Data structure templates to deifine record formats...............................................
012900240415Dcl-DS CTL_T  LikeRec(DSP.MCM0200CTL : *All) Template;
013000240415Dcl-DS FKYS_T LikeRec(DSP.MCM0200FKY : *All) Template;
013100240314Dcl-DS MSGC_T LikeRec(DSP.MSGCTL     : *All) Template;
013200240327Dcl-DS PAYD_T LikeRec(PAYD.PAYDR     : *All) Template;
013300240415Dcl-DS SFL_T  LikeRec(DSP.MCM0200SFL : *All) Template;
013400230807
013500230807// Like data structures used for the reading and writing of data....................................
013600240415Dcl-DS CTL_R  LikeDS(CTL_T );          // Pay code selection screen control record format
013700240327Dcl-DS FKYS_R LikeDS(FKYS_T);          // Function keys screen record format
013800240327Dcl-DS MSGC_R LikeDS(MSGC_T);          // Error message screen record format
013900240327Dcl-DS PAYD_R LikeDS(PAYD_T);          // Pay code description file record format
014000240415Dcl-DS SFL_R  LikeDS(SFL_T );          // Pay code selection subfile record format
014100231101
014200231101// Define data structure for reading of batch control file using SQL................................
014300240415Dcl-DS DataIn ExtName('MXX.PAYD') Qualified End-DS;
014400231101
014500230807// Functions keys and indicators data structure.....................................................
014600230807Dcl-DS WsInd Len(99);
014700230807  FuncKeyInd Char(24) Pos(01);         // Function key indicators...................................
014800240328    F3_Exit    Ind Pos(03);            // End program
014900240328    F4_Prompt  Ind Pos(04);            // A pop-up window which allows selection and return of data
015000240328    F5_Refresh Ind Pos(05);            // Refresh the data on the screen
015100240223    F6_AddCode Ind Pos(06);            // Add code to the Account Type file
015200240314    F11_Toggle Ind Pos(11);            // Toggle between the acct code and acct code description
015300240328    F12_Cancel Ind Pos(12);            // Cancel out of current window
015400240314    F14_Toggle Ind Pos(14);            // Toggle between showing all and only active pay codes
015500240318    F16_BilDys Ind Pos(16);            // Call the Initial Billing Days After DOS program MCM0103R
015600240318    F24_FunKys Ind Pos(24);            // Loop through the available function keys
015700240223  ScreenInd  Char(15) Pos(25);         // Screen manipulation indicators............................
015800240223    SFNxChg_25 Ind Pos(25);            // Mark subfile field as changed (SFLNXTCHG)
015900240223    ProtFld_28 Ind Pos(28);            // Protect the field from being changed
016000240223    InzSubF_29 Ind Pos(29);            // Initailze subfile (SFLINZ)
016100240223    ClrSubF_30 Ind Pos(30);            // Subfile clear (SFLCLR)
016200240223    DspCtlR_31 Ind Pos(31);            // Subfile Display Control (SFLDSPCTL)
016300240223    DspSubF_32 Ind Pos(32);            // Subfile Display (SFLDSP)
016400240223    SortCol_34 Ind Pos(34);            // Column subfile data is being sorted by when color pink
016500240223    ScanMod_35 Ind Pos(35);            // Indicates that the search is in scan mode
016600240223    AddCode_36 Ind Pos(36);            // Add a new account type code
016700240314    Inactiv_37 Ind Pos(37);            // Highlight inactive accounts
016800240327    OnlyAct_38 Ind Pos(38);            // Show all or only active accounts
016900240223    SubFEnd_39 Ind Pos(39);            // Subfile End (SFLEND)
017000240223  FldErrInd  Char(50) Pos(40);         // Error indicators..........................................
017100240313    OptNbrE_40 Ind Pos(40);            // Option number entered
017200240223    DataErr_89 Ind Pos(89);            // Data error found
017300230807  ProgramInd Char(10) Pos(90);         // Program flow indicators...................................
017400240319    NxtFKys_91 Ind Pos(91);            // Show the next set of available function keys
017500230807End-DS WsInd;
017600231027
017700240401// Declare data structures to store audit data......................................................
017800240327Dcl-DS AuditData1 Qualified;
017900240415   PAPAYCODE  Like(PAYD_R.PAPAYCODE );  // Pay code
018000240415   PADESC     Like(PAYD_R.PADESC    );  // Pay code description
018100240415   PATYPE     Like(PAYD_R.PATYPE    );  // Type
018200240415   PACLASS    Like(PAYD_R.PACLASS   );  // Pay class
018300240415   PAPOSTGL   Like(PAYD_R.PAPOSTGL  );  // Post to general ledger
018400240415   PAIGNORE   Like(PAYD_R.PAIGNORE  );  // Ignore on statement
018500240415   PASTOP     Like(PAYD_R.PASTOP    );  // Stop statement
018600240415   PACHGDAT   Like(PAYD_R.PACHGDAT  );  // Last Change date
018700240415   PACHGUSR   Like(PAYD_R.PACHGUSR  );  // Last Change user
018800240415   PAACTPAYCD Like(PAYD_R.PAACTPAYCD);  // Activity pay code(not used)
018900240415   PAALTPAYCD Like(PAYD_R.PAALTPAYCD);  // Alternate pay code
019000240415   PARBLBYPAS Like(PAYD_R.PARBLBYPAS);  // Auto rebill bypass
019100240415   PARBLDAYS  Like(PAYD_R.PARBLDAYS );  // Auto rebill days
019200240415   PAINSTLMNT Like(PAYD_R.PAINSTLMNT);  // Installment pay code
019300240415   PAPRT068   Like(PAYD_R.PAPRT068  );  // Print on MB068 report (explanation of pay code report)
019400240415   PAGENXREF  Like(PAYD_R.PAGENXREF );  // Generic cross reference
019500240415   PAINACDT   Like(PAYD_R.PAINACDT  );  // Inactive Date
019600240415   PAMBM577   Like(PAYD_R.PAMBM577  );  // MBM577 column code
019700240415   PAMBM578   Like(PAYD_R.PAMBM578  );  // MBM578 column code
019800240415   PAFLWUP    Like(PAYD_R.PAFLWUP   );  // Follow-up number of days
019900240415   PAMBM579   Like(PAYD_R.PAMBM579  );  // MBM579 column code
020000240415End-DS AuditData1;
020100240206
020200240328// Data structures used to see if the screen and file data are the same.............................
020300240206Dcl-DS AudtDta1 LikeDS(AuditData1);
020400240206Dcl-DS AudtDta2 LikeDS(AuditData1);
020500230725
020600231219// Declare data structre for reading in the Local Data Area (LDA)...................................
020700231219Dcl-DS MyLDA DtaAra(*LDA) Qualified;
020800231219  Entity   Char(3)  Pos(137);          // Used to open the correct account type file
020900231219  Group    Char(2)  Pos(138);          // Used as key to lookup customer information
021000231219  DeviceID Char(2)  Pos(494);          // Last two characters of device name
021100231219  UserID   Char(10) Pos(496);          // User identification of person running the job
021200231219  Customer Char(50) Pos(951);          // Customer company name
021300231219End-DS;
021400231219
021500230511// Declare constatnts...............................................................................
021600240326Dcl-C ADD       Const('ADD');
021700240326Dcl-C CHANGE    Const('CHG');
021800240326Dcl-C DELETE    Const('DLT');
021900240326Dcl-C DISPLAY   Const('DSP');
022000240315Dcl-C ERROR     Const('ERR');
022100240315Dcl-C EXIT      Const('F03');
022200240418Dcl-C RECID     Const('02');
022300240314Dcl-C RTVBYCODE Const('CODE');
022400240314Dcl-C RTVBYDESC Const('DESC');
022500240314Dcl-C RTVBYSRCH Const('SRCH');
022600240314Dcl-C SYSKEY    Const('01');
022700240314Dcl-C YES       Const('Y');
022800230511
022900231103// Declare variables...............................................................................
023000231110Dcl-S CompanyName Char(50)      Inz;
023100240327Dcl-S PayCodeF    Char(10)      Inz;
023200240314Dcl-S SavRRN      Packed(4:0);
023300240314Dcl-S SFRRN       Packed(4:0);
023400240223
023500230725// Data structure-Contains any API interface errors.................................................
023600230725/COPY QCPYSRC,D_APIErrDS
023700240314
023800240415// Prototype-Display/Add/Change The Pay Code Data...................................................
023900240415/COPY QCPYSRC,D_MCM0201R
024000240415
024100240415// Prototype-Lookup the pay code from the Pay Code Description file.................................
024200240415/COPY QCPYSRC,D_PAYCDELU
024300240415
024400230725// Prototype-Send program message and clear program message queue...................................
024500230725/COPY QCPYSRC,D_PGMMSGS
024600230725
024700230725// Data structure-Contains the program information..................................................
024800230725/COPY QCPYSRC,D_PGMSTSDS
024900230725
025000240328// Constants and data structures-Human readable form of the message ID's and custom message parms...
025100230725/COPY QCPYSRC,D_PMSGIDS
025200230807
025300240313// Prototype-Retrieve security data from the User/Program Security file.............................
025400240313/COPY QCPYSRC,D_RTVSECDT
025500240313
025600240313// Prototype-Retrieve system control data from the System Control file..............................
025700240313/COPY QCPYSRC,D_RTVSYSDT
025800240313
025900240313// Prototype-Write the audit data to the correct audit file.........................................
026000240313/COPY QCPYSRC,D_WRTAUDTA
026100240313
026200230524//**************************************************************************************************
026300230511//************************************  M A I N  P R O G R A M  ************************************
026400230524//**************************************************************************************************
026500230511
026600231101// Stuff that only needs to be done once when the program is first run..............................
026700240327ProgramEntry();
026800230807
026900231108// Process the screen until F3 is pressed...........................................................
027000240223DoU F3_Exit or F12_Cancel;
027100230725
027200240415  // Display the pay code selection screen..........................................................
027300240327  CTL_R.CompName = CompanyName;
027400240412  SubFEnd_39 = *ON;
027500240415  Write DSP.MCM0200FKY FKYS_R;
027600231031  Write DSP.MSGCTL MSGC_R;
027700240415  ExFmt DSP.MCM0200CTL CTL_R;
027800230725
027900231102  // Reset the error indicators and clear out any previously displayed messages.....................
028000240223  FldErrInd  = *OFF;
028100240314  ClrMsgQ(MsgQ_Cur : MsgQNbr_Cur : MsgKey_All :  MsgRmv_All : APIErrC);
028200230725
028300231102  // F3 - Exit out of program.......................................................................
028400231023  Select;
028500231023  When F3_Exit;
028600231023    Leave;
028700240313
028800240314  // F5 - Refresh the screen to appear as it did initially..........................................
028900240313  When F5_Refresh;
029000240313    Clear CTL_R.SRCH4TEXT;                       // Clear out any search values
029100240320    Clear SFL_R;                                 // Clear out option data entered
029200240320    ClrSFData();                                 // Clear out subfile data
029300240313    SortCol_34 = *ON;                            // Set to sort on code column indicator
029400240313    ScanMod_35 = *OFF;                           // Turn off scan mode
029500240314    OnlyAct_38 = *OFF;                           // Turn off show only active accounts
029600240415    RtvPayCodes(RTVBYCODE);
029700240313
029800240415  // F6 - Add a new code to the Pay Code file.......................................................
029900240223  When F6_AddCode;
030000240313    If not ProtFld_28;                           // Must have the security to add codes
030100240416      ProcPayCde(MyLDA.Group : SFL_R.PAPAYCODE : ADD : PPC.RetFncKey : PPC.RetMsgTyp : PPC.RetPgmMsg);
030200240415      If PPC.RetFncKey = EXIT;                   // Exit out of program passed back
030300240315        Leave;
030400240415      ElseIf PPC.RetPgmMsg <> *BLANKS;
030500240415        CPF9898.Field1 = PPC.RetPgmMsg;
030600240314        SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
030700240314                   MsgQNbr_Cur : MsgKey : APIErrC);
030800240415        If PPC.RetMsgTyp = ERROR;                // Error message passed back from program called
030900240315          DataErr_89 = *ON;
031000240315        EndIf;
031100240320      Else;                                      // Set everything back to its initial state
031200240320        Clear CTL_R.SRCH4TEXT;                   // Clear out any search values
031300240320        Clear SFL_R;                             // Clear out option data entered
031400240320        ClrSFData();                             // Clear out subfile data
031500240320        SortCol_34 = *ON;                        // Set to sort on code column indicator
031600240320        ScanMod_35 = *OFF;                       // Turn off scan mode
031700240320        OnlyAct_38 = *OFF;                       // Turn off show only active accounts
031800240415        RtvPayCodes(RTVBYCODE);
031900240313      EndIf;
032000231025    Else;
032100240318      SndPgmMsg(Err_CodeAdd : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
032200240314                 MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC);
032300231025      DataErr_89 = *ON;
032400231025    EndIf;
032500240313
032600240313  // F11 - Toggle between sorting by code and sorting by description................................
032700240313  When F11_Toggle;
032800240313    ClrSFData();
032900240314    If SortCol_34 = *ON;                         // Data currently sorting by code
033000240314      SortCol_34 = *OFF;                         // Change the description column header to pink
033100240314      If %SubSt(CTL_R.SRCH4TEXT:1:1) = '?';      // Data is being retrieved by character match
033200240314        ScanMod_35 = *ON;                        // Show scan mode on the display
033300240415        RtvPayCodes(RTVBYSRCH);                  // Retrieve data by scan method
033400240314      Else;
033500240314        ScanMod_35 = *OFF;                       // Turn off scan mode notification on screen
033600240415        RtvPayCodes(RTVBYDESC);                  // Retrieve data by description
033700240314      EndIf;
033800240314    Else;
033900240314      SortCol_34 = *ON;                          // Change the code column header to pink
034000240314      If %SubSt(CTL_R.SRCH4TEXT:1:1) = '?';      // Data is being retrieved by character match
034100240314        ScanMod_35 = *ON;                        // Show scan mode on the display
034200240415        RtvPayCodes(RTVBYSRCH);                  // Retrieve data by scan method
034300240314      Else;
034400240314        ScanMod_35 = *OFF;                       // Stop showing scan mode on the display
034500240415        RtvPayCodes(RTVBYCODE);                  // Retrieve data by code
034600240313      EndIf;
034700240313    EndIf;
034800240313    If CTL_R.SRCH4TEXT <> *BLANKS and not ScanMod_35;
034900240313      PositionTo();
035000240313    EndIf;
035100240313
035200240415  // F12 - Go back to previous screen (exit the program since this is the first screen).............
035300231023  When F12_Cancel;
035400240223    Leave;
035500230824
035600240415  // F14 - Toggle between displaying all pay codes and active pay codes.............................
035700240314  When F14_Toggle;
035800240314    ClrSFData();
035900240314    If OnlyAct_38 = *OFF;                        // Currently not showing inactive accounts
036000240314       OnlyAct_38 = *ON;
036100240314    Else;
036200240314       OnlyAct_38 = *OFF;
036300240314    EndIf;
036400240314    If SortCol_34 = *ON;                         // Currently sorting by code
036500240314      If %SubSt(CTL_R.SRCH4TEXT:1:1) = '?';      // Data is being retrieved by character match
036600240315        ScanMod_35 = *ON;                        // Show scan mode notification on screen
036700240415        RtvPayCodes(RTVBYSRCH);                  // Retrieve data by scan method
036800240314      Else;
036900240314        ScanMod_35 = *OFF;                       // Turn off scan mode notification on screen
037000240415        RtvPayCodes(RTVBYDESC);                  // Retrieve data by description
037100240314      EndIf;
037200240314    Else;
037300240314      If %SubSt(CTL_R.SRCH4TEXT:1:1) = '?';      // Data is being retrieved by character match
037400240315        ScanMod_35 = *ON;                        // Show scan mode notification on screen
037500240415        RtvPayCodes(RTVBYSRCH);                  // Retrieve data by scan method
037600240314      Else;
037700240314        ScanMod_35 = *OFF;                       // Turn off scan mode notification on screen
037800240415        RtvPayCodes(RTVBYCODE);                  // Retrieve data by description
037900240314      EndIf;
038000240314    EndIf;
038100240314    If CTL_R.SRCH4TEXT <> *BLANKS and not ScanMod_35;
038200240314      PositionTo();
038300240314    EndIf;
038400240314
038500240327  // F24 - Rotate displaying the different function keys............................................
038600240319  When F24_FunKys;
038700240319    If NxtFKys_91 = *OFF;
038800240319      NxtFKys_91 = *ON;
038900240319    Else;
039000240319      NxtFKys_91 = *OFF;
039100240319    EndIf;
039200240319
039300240327  // Enter - Process all option numbers entered.....................................................
039400231023  Other;
039500240313    ProcessScreen();
039600240315    If F3_Exit;                                  // If exit passed back by program called, then exit
039700240315      Leave;                                     // out of this program
039800240315    EndIf;
039900240313  EndSL;
040000231107
040100240223EndDo;                                           // DoU F3_Exit or F12_Cancel
040200231101
040300240313// Close files that were opened by this program.....................................................
040400240313CloseOpenFiles();
040500240313
040600231101//--------------------------------------------------------------------------------------------------
040700240327//- SUBPROCEDURE: ProgramEntry                                                                     -
040800240327//- FUNCTION....: Tasks Done When The Prorgam Is First Run                                         -
040900240327//- EXPLANATION.: Process all of the tasks that only need to done when the program is first run.   -
041000240327//-               Such as, getting user privileges, opening files, initializing variables, etc.    -
041100231101//--------------------------------------------------------------------------------------------------
041200240327Dcl-Proc ProgramEntry;
041300231101
041400240223  // Going down one level in the message queue......................................................
041500240223  MsgQNbr_Cur += 1;
041600240223
041700231102  // Set program name for error message screen and initialize the error message screen..............
041800231102  *INLR = *ON;
041900231110  MSGC_R.PGMNAME = PgmName;                      // Required because of screen record format DS
042000240314  ClrMsgQ(MsgQ_Cur : MsgQNbr_Cur : MsgKey_All :  MsgRmv_All : APIErrC);
042100231101
042200240313  // Retrieve the user security information from the program security file..........................
042300240313  RtvSecDta(PgmName : JobUser : RSECD.SecFileDta : RSECD.ErrorMsg);
042400240313  If RSECD.ErrorMsg = *BLANKS;
042500240313    If RSECD.SecFileDta.SEC02 <> YES;            // Pay code data edit security
042600240313      ProtFld_28 = *ON;                          // Do not allow editing of pay code data
042700240313    EndIf;
042800240313  Else;
042900240313    CPF9898.Field1 = RSECD.ErrorMsg;
043000240314    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
043100240314               MsgQNbr_Cur : MsgKey : APIErrC);
043200240313    ProtFld_28 = *ON;
043300240313    DataErr_89 = *ON;
043400240313  EndIf;
043500240327
043600240415  // Open the Pay Code Description file.............................................................
043700240415  In MyLDA;
043800240415  If %Len(%Trim(MyLDA.Entity)) = 3;
043900240327    PayCodeF = MyLDA.Entity + '.PAYD';
044000240327    If not %Open(PAYD);
044100240327      Open(E) PAYD;
044200240327      If %Error;
044300240327        CPF9898.Field1 = 'The program could not open the file ' + PayCodeF + '. Contact IT for help';
044400240327        SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
044500240327                   MsgQNbr_Cur : MsgKey : APIErrC);
044600240327        DataErr_89  = *ON;
044700240327      EndIf;
044800240327    EndIf;
044900240118
045000231219  Else;
045100231219    CPF9898.Field1 = 'LDA missing data. Cannot open correct file. Contact IT for help';
045200240314    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
045300240314               MsgQNbr_Cur : MsgKey : APIErrC);
045400231219    DataErr_89  = *ON;
045500231219  EndIf;
045600240206
045700240206  // Retrieve the customer company and center it in the field.......................................
045800240314  RtvSysDta(MyLDA.Group : SYSKEY : RSYSD.SysFileDta : RSYSD.ErrorMsg);
045900240313  If RSYSD.ErrorMsg = *BLANKS;
046000240313    CompanyName = CenterText(RSYSD.SysFileDta.SYSNAM);
046100240313  Else;
046200240313    CPF9898.Field1 = RSYSD.ErrorMsg;
046300240314    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
046400240314               MsgQNbr_Cur : MsgKey : APIErrC);
046500240313    DataErr_89 = *ON;
046600240313  EndIf;
046700240313
046800240314  // Load the file data to the screen...............................................................
046900240314  InzSubFile();
047000240412  ClrSFData();
047100240315  SortCol_34 = *ON;
047200240415  RtvPayCodes(RTVBYCODE);
047300240314
047400240223  // Going up one level in the message queue........................................................
047500240223  MsgQNbr_Cur -= 1;
047600231101
047700240327End-Proc ProgramEntry;
047800230725
047900240314//--------------------------------------------------------------------------------------------------
048000240314//- SUBPROCEDURE: InzSubFile                                                                       -
048100240314//- FUNCTION....: Initialize The Fields In The Subfile                                             -
048200240314//- EXPLANATION.: Set all the input capable fields to their default values.                        -
048300240314//--------------------------------------------------------------------------------------------------
048400240314Dcl-Proc InzSubFile;
048500240314
048600240314  // Set the indicators to initialize the subfile display...........................................
048700240314  InzSubF_29   = *ON;
048800240314  CTL_R.SFREC# = 1;
048900240314
049000240314  // Write the subfile control record to clear out the subfile display..............................
049100240415  Write DSP.MCM0200CTL CTL_R;
049200240314
049300240314  // Set indicators and fields to show that the subfile is empty....................................
049400240314  InzSubF_29 = *OFF;
049500240314  DspCtlR_31 = *ON;
049600240314  DspSubF_32 = *ON;
049700240314
049800240314End-Proc InzSubFile;
049900240314
050000240314//--------------------------------------------------------------------------------------------------
050100240314//- SUBPROCEDURE: ClrSubFile                                                                       -
050200240314//- FUNCTION....: Clear Out The Data In Subfile Display                                            -
050300240328//- EXPLANATION.: Remove all the data in the display subfile so that it does not contain any data  -
050400240328//-               before more data is written to the subfile.                                      -
050500240314//--------------------------------------------------------------------------------------------------
050600240314Dcl-Proc ClrSFData;
050700240314
050800240314  // Set the indicators to clear out the subfile display............................................
050900240314  ClrSubF_30 = *ON;
051000240314  DspCtlR_31 = *OFF;
051100240314  DspSubF_32 = *OFF;
051200240314
051300240314  // Write the subfile control record to clear out the subfile display..............................
051400240415  Write DSP.MCM0200CTL CTL_R;
051500240314
051600240314  // Set indicators and fields to show that the subfile is empty....................................
051700240314  ClrSubF_30   = *OFF;
051800240314  DspCtlR_31   = *ON;
051900240314  SavRRN       = *ZERO;
052000240314  CTL_R.SFREC# = *ZERO;
052100240314  SFRRN        = *ZERO;
052200240314  SubFEnd_39   = *OFF;
052300240314
052400240314End-Proc ClrSFData;
052500240314
052600230725//--------------------------------------------------------------------------------------------------
052700240415//- SUBPROCEDURE: RtvPayCodes                                                                      -
052800231101//- FUNCTION....: Retrieve Data To Load Into The Subfile Display                                   -
052900240415//- EXPLANATION.: Retrieve the data from the Pay Code Description file to populate the subfile     -
053000240415//-               display. For the initial screen, the code header will be highlighted and the     -
053100240415//-               data will be sorted by the code. Additionally, the data can be sorted by the     -
053200240415//-               code description. Plus there is the ability to populate the subfile display      -
053300240415//-               based upon matching the search characters with characters in the code or code    -
053400231226//-               description. This is accomplished by placing a question mark at the beginning of -
053500231226//-               the characters in the search field. The SFLEND indicator is set ON so that the   -
053600231226//-               display will handle the MORE and BOTTOM that appear at the end of the subfile    -
053700231226//-               display.                                                                         -
053800231101//-                                                                                                -
053900231101//- - - - - - - - - - - - - - - - - -   P A R A M E T E R S  - - - - - - - - - - - - - - - - - - - -
054000231101//      Name      I/O                                  Description                                 -
054100231101// -------------- --- ---------------------------------------------------------------------------- -
054200231101//- HowToRtv      In  How the data is to be retrieved: By code, description or search string       -
054300231101//-                                                                                                -
054400231101//- - - - - - - - - - - - - - - - - - -  C O N S T A N T S   - - - - - - - - - - - - - - - - - - - -
054500231101//-      Name                                          Description                                 -
054600231101//- --------------   ----------------------------------------------------------------------------- -
054700231101//- ASCENDING        Sort the returned SQL data in ascending sequence                              -
054800231101//- DESCENDING       Sort the returned SQL data in descending sequence                             -
054900231101//- MAXSFREC         Maximum number of records in the main subfile                                 -
055000231101//- SPACE            Used to put spaces inbetween the different clauses of the SQL statement       -
055100231101//- SQLOK            Status of good SQL processing                                                 -
055200231101//- SQLEOF           SQL end of file indicator                                                     -
055300231101//- SQUOTE           Single quote to put around character values in the SQL statement              -
055400231101//-                                                                                                -
055500231101//- - - - - - - - - - - - - - - - - - -  V A R I A B L E S   - - - - - - - - - - - - - - - - - - - -
055600231101//-      Name                                          Description                                 -
055700231101//- --------------   ----------------------------------------------------------------------------- -
055800231101//- ForClause        Dynamic SQL FOR clause (not required; however, it is recommended)             -
055900231101//- GroupByClause    Dynamic SQL GROUP BY clause used to get unique values for the field           -
056000231101//- OrderByClause    Dynamic SQL ORDER BY clause (not required)                                    -
056100231101//- SelectClause     Dynamic SQL SELECT clause (also update, delete, etc)                          -
056200231101//- SortSeq          Sequence in which the data is sorted (ascending or descending)                -
056300231101//- SQLStmt          Complete dynamic SQL stament to be executed                                   -
056400231101//- WhereClause      Dynamic SQL WHERE clause                                                      -
056500231101//--------------------------------------------------------------------------------------------------
056600240415Dcl-Proc RtvPayCodes;
056700230725
056800240314  // Parameters passed..............................................................................
056900240314  Dcl-PI *n;
057000240314    HowToRtv Char(4) Value;
057100240314  End-PI;
057200240314
057300231101  // Declare constants..............................................................................
057400231101  Dcl-C ASCENDING  Const('ASC');
057500231101  Dcl-C DESCENDING Const('DESC');
057600240418  Dcl-C MAXSFREC   Const(1200);
057700231101  Dcl-C SPACE      Const(' ');
057800231101  Dcl-C SQLOK      Const('00000');
057900231101  Dcl-C SQLEOF     Const('02000');
058000231101  Dcl-C SQUOTE     Const('''');
058100231101
058200231101  // Declare standalone variables...................................................................
058300240314  Dcl-S ForClause     Char( 64);
058400240314  Dcl-S GroupByClause Char(128);
058500240314  Dcl-S OrderByClause Char(128);
058600240314  Dcl-S SelectClause  Char(256);
058700240314  Dcl-S SortSeqAsc    Char(  4)  Inz(ASCENDING);
058800240314  Dcl-S SortSeqDsc    Char(  4)  Inz(DESCENDING);
058900231101  Dcl-S SQLStmt       Char(1024);
059000240314  Dcl-S WhereClause   Char(256);
059100231101
059200230725  // Going down one level in the message queue......................................................
059300230725  MsgQNbr_Cur += 1;
059400231101
059500231101  // Build the SQL select clause....................................................................
059600240415  SelectClause = 'select * from "' + %Trim(PayCodeF) + '"';
059700231101
059800231101  // Build the SQL where clause.....................................................................
059900240314  If HowToRtv = RTVBYSRCH;
060000240314    If SortCol_34 = *ON;
060100240415      WhereClause = 'where PAPAYCODE like ';
060200240314    Else;
060300240415      WhereClause = 'where PADESC like ';
060400240314    EndIf;
060500240314      WhereClause = %Trim(WhereClause) + SPACE + SQUOTE + '%' + %Trim(CTL_R.SRCH4TEXT : '? ') +
060600240314                    '%' + SQUOTE;
060700240314  EndIf;
060800240415  If OnlyAct_38 = *ON and HowToRtv = RTVBYSRCH;            // Show only active accounts
060900240415    WhereClause = %Trim(WhereClause) + ' and PAINACDT = 0';
061000240314  ElseIf OnlyAct_38 = *ON;
061100240415    WhereClause = 'where PAINACDT = 0';
061200240314  EndIf;
061300240314
061400231101  // Build the SQL group by clause(not needed)......................................................
061500231101  GroupByClause = SPACE;
061600231101
061700231101  // Build the SQL order by clause..................................................................
061800240315  If SortCol_34 = *ON;
061900240415    OrderByClause = 'order by PAPAYCODE ' + SortSeqAsc;    // Order by pay code
062000240314  Else;
062100240415    OrderByClause = 'order by PADESC ' + SortSeqAsc;       // Order by pay code description
062200240314  EndIf;
062300231101
062400231101  // Build the SQL for clause.......................................................................
062500231101  ForClause = 'for read only';
062600231101
062700231101  // Build the SQL statement separating each clause by a space......................................
062800240223  SQLStmt = %Trim(SelectClause) + SPACE + %Trim(WhereClause) + SPACE + %Trim(GroupByClause) +
062900240223            SPACE + %Trim(OrderByClause) + SPACE + %TrimR(ForClause);
063000231101
063100231101  // Commit must be set to none since table is not journaled........................................
063200231101  Exec SQL Set Option Commit = *NONE, Closqlcsr = *ENDMOD;
063300231101
063400240327  // Declare the cursor for dynamic SQL statement...................................................
063500231101  Exec SQL Declare InputFile cursor for DynSQLStmt;
063600231101
063700240327  // Prepare the declared dynamic SQL cursor to receive data........................................
063800231101  Exec SQL Prepare DynSQLStmt from :SQLStmt;
063900231101
064000240327  // Open the dynamic SQL cursor for reading of the data and check to see that data was retrieved...
064100231101  Exec SQL Open InputFile;
064200231101  If SQLState <> SQLOK;
064300231101    Wrn0000.Field1 = SQLStmt;
064400240314    SndPgmMsg(Wrn_NoDtaRt : MsgFile_Dft : Wrn0000 : %Len(Wrn0000) : MsgTy_Diag : MsgQ_Cur :
064500240314               MsgQNbr_Cur : MsgKey : APIErrC);
064600231101    DataErr_89 = *ON;
064700231101  EndIf;
064800231101
064900240327  // Read the file data into the data structure and write the data to the display subfile...........
065000231101  If SQLState = SQLOK and DataErr_89 = *OFF;
065100231101    Exec SQL Fetch next from InputFile into :DataIn;
065200231101
065300240314    DoW SQLState = SQLOK and SQLState <> SQLEOF and SFRRN <= MAXSFREC;
065400240314      SFRRN += 1;
065500240415      SFL_R.PAPAYCODE = DataIn.PAPAYCODE;
065600240415      SFL_R.PADESC    = DataIn.PADESC;
065700240415      SFL_R.PAINACDT = DataIn.PAINACDT;
065800240415      If SFL_R.PAINACDT = *ZERO;                 // Active pay code records
065900240314        Inactiv_37 = *OFF;
066000240415      Else;                                      // Inactive pay code records
066100240327        Inactiv_37 = *ON;                        // Make subfile line text red(Danger Will Robinson)
066200231228      EndIf;
066300240415      Write DSP.MCM0200SFL SFL_R;
066400231101      Exec SQL Fetch next from InputFile into :DataIn;
066500231101    EndDo;
066600231101  EndIf;
066700231101
066800240327  // Close the cursor once all the file data has been read..........................................
066900231101  Exec SQL Close InputFile;
067000231023
067100240327  // No records read from input file, so show warning message.......................................
067200240223  If SQLState <> SQLOK;
067300240415    CPF9898.Field1 = 'No data found for pay code. Contact IT if problem persists';
067400240314    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
067500240314               MsgQNbr_Cur : MsgKey : APIErrC);
067600231023    DataErr_89  = *ON;
067700231023  EndIf;
067800231101
067900240328  // Disiplay the subfile even if it does not contain data..........................................
068000240314  DspSFData();
068100240314
068200230725  // Going up one level in the message queue........................................................
068300230725  MsgQNbr_Cur -= 1;
068400230725
068500240415End-Proc RtvPayCodes;
068600240223
068700240313//--------------------------------------------------------------------------------------------------
068800240313//- SUBPROCEDURE: DspSFData                                                                        -
068900240328//- FUNCTION....: Display The Subfile                                                              -
069000240401//- EXPLANATION.: Set the indicators to display the subile even if it does not have any records.   -
069100240401//-               Note:  If you try to display an empty subfile that has not been initialized, the -
069200240401//-               program will error out.                                                          -
069300240401//--------------------------------------------------------------------------------------------------
069400240313Dcl-Proc DspSFData;
069500240313
069600240313  // Display the subfile if there are records to display............................................
069700240314  If SFRRN > *ZERO;
069800240314    DspSubF_32   = *ON;
069900240314    CTL_R.SFRec# = SavRRN + 1;
070000240313  Else;
070100240314    DspSubF_32   = *OFF;
070200240314    CTL_R.SFRec# = *ZERO;
070300240313  EndIF;
070400240313
070500240313  // Do not allow the subfile page to position beyond the last subfile page.........................
070600240314  If CTL_R.SFRec# > SFRRN;
070700240314    CTL_R.SFRec# = SavRRN;
070800240313  EndIf;
070900240313
071000240313  // Save the last subfile record to be able to position to the last subfile page...................
071100240314  SavRRN = SFRRN;
071200240313
071300240313End-Proc DspSFData;
071400240313
071500240313//--------------------------------------------------------------------------------------------------
071600240313//- SUBPROCEDURE: ProcessScreen                                                                    -
071700240328//- FUNCTION....: Process The Screen                                                               -
071800240328//- EXPLANATION.: Determine what needs to happen next from what was entered on the screen. You     -
071900240328//-               have the ability to position to a code or description, or select codes or select -
072000240328//-               codes or desctiptions based upon finding the matching characters that were       -
072100240328//-               entered into the search. By entering an option number in front of a account type -
072200240328//-               code, you can change, delete or display an account type code and any additional  -
072300240328//-               data.                                                                            -
072400240313//--------------------------------------------------------------------------------------------------
072500240313Dcl-Proc ProcessScreen;
072600240313
072700240313  // Going down one level in the message queue......................................................
072800240313  MsgQNbr_Cur += 1;
072900240313
073000240313  // Process the code selection screen..............................................................
073100240415    ReadC(E) DSP.MCM0200SFL SFL_R;               // Check for option number being entered first
073200240313    If not %EOF or %ERROR;
073300240416      ProcCdeSelScrn();                          // Process the change/delete/display for the code
073400240313    ElseIf %Error;
073500240313      CPF9898.Field1 = 'An error occured while reading the subfile display data';
073600240314      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
073700240314                 MsgQNbr_Cur : MsgKey : APIErrC);
073800240313
073900240313    ElseIf CTL_R.SRCH4TEXT <> *BLANKS;           // Code or description search requested
074000240313      If %SubSt(CTL_R.SRCH4TEXT:1:1) = '?';      // Return results containing the characters entered
074100240313        ClrSFData();
074200240313        ScanMod_35 = *ON;                        // Turn on searching by scan method
074300240415        RtvPayCodes(RTVBYSRCH);                  // Retrieve data by scan method
074400240313
074500240313      ElseIf ScanMod_35 and %SubSt(CTL_R.SRCH4TEXT:1:1) <> '?';  // Scan method no longer used
074600240313        ScanMod_35 = *OFF;
074700240313        ClrSFData();
074800240315        If  SortCol_34 = *ON;                    // If currently selecting by code
074900240415          RtvPayCodes(RTVBYCODE);                // Retrieve data by codes
075000240313        Else;
075100240415          RtvPayCodes(RTVBYDESC);                // Retrieve data by description
075200240313        EndIf;
075300240313        PositionTo();                            // Begin subfile at what was entered in the search
075400240313
075500240313      Else;                                      // Just position to code or description
075600240313        PositionTo();
075700240313      EndIf;
075800240313
075900240313    EndIf;
076000240313
076100240313  // Going up one level in the message queue........................................................
076200240313  MsgQNbr_Cur -= 1;
076300240313
076400240313End-Proc ProcessScreen;
076500240313
076600240313//--------------------------------------------------------------------------------------------------
076700240416//- SUBPROCEDURE: ProcCdeSelScrn                                                                    -
076800240313//- FUNCTION....: Process The Code Selection Screen Request                                        -
076900240415//- EXPLANATION.: Verify that the user has the authority to perform a change or delete of the pay  -
077000240415//-               code data. If display data was selected, then display the pay code data, because -
077100240415//-               everyone can display the data.                                                   -
077200240313//--------------------------------------------------------------------------------------------------
077300240416Dcl-Proc ProcCdeSelScrn;
077400240313
077500240313  // Going down one level in the message queue......................................................
077600240313  MsgQNbr_Cur += 1;
077700240313
077800240313  // Process the option entered for the code........................................................
077900240313  DoW not %EOF and not %Error;
078000240313
078100240415    // Change the pay code data.....................................................................
078200240313    If SFL_R.OPTION = '2';
078300240313      If not ProtFld_28;                         // Authority required to modify the data
078400240416        ProcPayCde(MyLDA.Group : SFL_R.PAPAYCODE : CHANGE : PPC.RetFncKey : PPC.RetMsgTyp :
078500240415                   PPC.RetPgmMsg);
078600240415        If PPC.RetFncKey = EXIT;                 // Exit out of program passed back
078700240315          F3_Exit = *ON;
078800240415        ElseIf PPC.RetPgmMsg <> *BLANKS;
078900240415          CPF9898.Field1 = PPC.RetPgmMsg;
079000240315          SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
079100240315                     MsgQNbr_Cur : MsgKey : APIErrC);
079200240415          If PPC.RetMsgTyp = ERROR;              // Error message passed back from program called
079300240315            DataErr_89 = *ON;
079400240315          EndIf;
079500240320        Else;                                    // Set everything back to its initial state
079600240320          Clear CTL_R.SRCH4TEXT;                 // Clear out any search values
079700240320          Clear SFL_R;                           // Clear out option data entered
079800240320          ClrSFData();                           // Clear out subfile data
079900240320          SortCol_34 = *ON;                      // Set to sort on code column indicator
080000240320          ScanMod_35 = *OFF;                     // Turn off scan mode
080100240320          OnlyAct_38 = *OFF;                     // Turn off show only active accounts
080200240415          RtvPayCodes(RTVBYCODE);
080300240320        EndIf;
080400240313      Else;
080500240314        SndPgmMsg(Err_CodeChg : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
080600240314                   MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC);
080700240313        DataErr_89 = *ON;
080800240313      EndIf;
080900240313
081000240415    // Delete the pay code data.....................................................................
081100240313    ElseIf SFL_R.OPTION = '4';
081200240313      If not ProtFld_28;                         // Authority required to delete the data
081300240415        Chain(E) (SFL_R.PAPAYCODE) PAYD.PAYDR PAYD_R;
081400240313        If %Found and not %ERROR;
081500240416          DltPayCodeData();
081600240313        Else;
081700240415          CPF9898.Field1 = 'An error occured while retrieving data from the Pay Code File';
081800240314          SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
081900240314                     MsgQNbr_Cur : MsgKey : APIErrC);
082000240313        EndIf;
082100240313      Else;
082200240314        SndPgmMsg(Err_CodeDlt : MsgFile_Dft : MsgDta_None :  MsgDtaLen_None : MsgTy_Diag :
082300240314                   MsgQ_Cur: MsgQNbr_Cur : MsgKey : APIErrC);
082400240313        DataErr_89 = *ON;
082500240313      EndIf;
082600240313
082700240415    // Display pay code detail data.................................................................
082800240313    ElseIf SFL_R.OPTION = '5';
082900240416      ProcPayCde(MyLDA.Group : SFL_R.PAPAYCODE : DISPLAY : PPC.RetFncKey : PPC.RetMsgTyp :
083000240415                 PPC.RetPgmMsg);
083100240415        If PPC.RetFncKey = EXIT;                 // Exit out of program passed back
083200240315          F3_Exit = *ON;
083300240415        ElseIf PPC.RetPgmMsg <> *BLANKS;
083400240415          CPF9898.Field1 = PPC.RetPgmMsg;
083500240315          SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
083600240315                     MsgQNbr_Cur : MsgKey : APIErrC);
083700240415          If PPC.RetMsgTyp = ERROR;              // Error message passed back from program called
083800240315            DataErr_89 = *ON;
083900240315          EndIf;
084000240320        Else;                                    // Set everything back to its initial state
084100240320          Clear CTL_R.SRCH4TEXT;                 // Clear out any search values
084200240320          Clear SFL_R;                           // Clear out option data entered
084300240320          ClrSFData();                           // Clear out subfile data
084400240320          SortCol_34 = *ON;                      // Set to sort on code column indicator
084500240320          ScanMod_35 = *OFF;                     // Turn off scan mode
084600240320          OnlyAct_38 = *OFF;                     // Turn off show only active accounts
084700240415          RtvPayCodes(RTVBYCODE);
084800240315        EndIf;
084900240313    EndIf;
085000240415    ReadC(E) DSP.MCM0200SFL SFL_R;
085100240313  EndDo;
085200240313
085300240313  // Error occured while processing the subfile.....................................................
085400240313  If %ERROR;
085500240313    CPF9898.Field1 = 'An error occured while processing the subfile display data';
085600240314    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
085700240314               MsgQNbr_Cur : MsgKey : APIErrC);
085800240313  EndIf;
085900240313
086000240313  // Going up one level in the message queue........................................................
086100240313  MsgQNbr_Cur -= 1;
086200240313
086300240416End-Proc ProcCdeSelScrn;
086400240313
086500240313//--------------------------------------------------------------------------------------------------
086600240313//- SUBPROCEDURE: PositionTo                                                                       -
086700240313//- FUNCTION....: Position The Subfile Display                                                     -
086800240313//- EXPLANATION.: The user has entered a search value that they want the to appear as the first    -
086900240313//-               record in the subfile.  Each record in the subfile is read until the search      -
087000240313//-               value exceeds the corresponding subfile value.  The subfile record number is     -
087100240313//-               set to the current value, which will cause it to be displayed at the top of the  -
087200240313//-               subfile. If the subfile index exceeds the number of subfile records, then the    -
087300240313//-               search value entered has not been found in the subfile and no positioning should -
087400240313//-               be done.                                                                         -
087500240313//- - - - - - - - - - - - - - - - - - -  V A R I A B L E S   - - - - - - - - - - - - - - - - - - - -
087600240313//-      Name                                          Description                                 -
087700240313//- --------------   ----------------------------------------------------------------------------- -
087800240313//- SFIdx            Counter used as a subfile index to get the subfile data                       -
087900240313//--------------------------------------------------------------------------------------------------
088000240313Dcl-Proc PositionTo;
088100240313
088200240314  Dcl-S SFIdx Like(SFRRN) Inz(1);
088300240313
088400240313  // Going down one level in the message queue......................................................
088500240313  MsgQNbr_Cur += 1;
088600240313
088700240313  // Read though the subfile to find where to postion it to.........................................
088800240314  DoU SFIdx > SavRRN;
088900240415    Chain(E) SFIdx DSP.MCM0200SFL SFL_R;
089000240415    If SortCol_34 and SFL_R.PAPAYCODE >= CTL_R.SRCH4TEXT or not SortCol_34 and
089100240415       SFL_R.PAPAYCODE >= CTL_R.SRCH4TEXT;
089200240314      CTL_R.SFRec# = SFIdx;
089300240415      Update DSP.MCM0200SFL SFL_R;
089400240313      Leave;
089500240313    ElseIf %Error;
089600240313      CPF9898.Field1 = 'Error occured when trying to reading through the subfile data';
089700240314      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
089800240314                 MsgQNbr_Cur : MsgKey : APIErrC);
089900240313      DataErr_89  = *ON;
090000240313      Leave;
090100240313    EndIf;
090200240313    SFIdx +=1;
090300240313  EndDo;
090400240313
090500240313  // No value found to position the subfile to......................................................
090600240314  If SFIdx > SavRRN;
090700240313    CPF9898.Field1 = 'Not able to positon to code based upon what was entered';
090800240314    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
090900240314               MsgQNbr_Cur : MsgKey : APIErrC);
091000240313  EndIf;
091100240313
091200240313  // Going up one level in the message queue........................................................
091300240313  MsgQNbr_Cur -= 1;
091400240313
091500240313End-Proc PositionTo;
091600231109
091700240103//--------------------------------------------------------------------------------------------------
091800240416//- SUBPROCEDURE: DltPayCodeData                                                                     -
091900240415//- FUNCTION....: Delete the Pay Code Data                                                         -
092000240415//- EXPLANATION.: Remove the pay code from the Pay Code Description file. Before any data is       -
092100240415//-               deleted from the Pay Code description file, a snapshot of the data to be deleted -
092200240415//-               is saved to the customer Miscellaneous Codes Maintenance Audit file.             -
092300231226//--------------------------------------------------------------------------------------------------
092400240416Dcl-Proc DltPayCodeData;
092500231109
092600240103  // Going down one level in the message queue......................................................
092700240103  MsgQNbr_Cur += 1;
092800231115
092900240103  // Save the deleted record to the audit file before deleting the record...........................
093000240415  Eval-Corr AudtDta1 = PAYD_R;
093100240415  WrtAudDta(MyLDA.Group : RECID : SFL_R.PAPAYCODE : DELETE : AudtDta1 : AudtDta2 : WAD.ErrorMsg);
093200240307  If WAD.ErrorMsg <> *BLANKS;                  // Issues saving the audit data?
093300240307    CPF9898.Field1 = WAD.ErrorMsg;
093400240314    SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
093500240314               MsgQNbr_Cur : MsgKey : APIErrC);
093600240206    DataErr_89 = *ON;
093700240206  Else;
093800231109
093900240415    // Delete the pay code from the Pay Code Description file.......................................
094000240415    Chain(E) (SFL_R.PAPAYCODE) PAYD.PAYDR PAYD_R;
094100240415    If %Found(PAYD) and not %Error;
094200240415      Delete PAYD.PAYDR;
094300240415      CPF9898.Field1 = 'Pay code ' + %Trim(SFL_R.PAPAYCODE) + ' deleted from the Pay Code +
094400240415                        Description file';
094500240314      SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
094600240314      MsgQNbr_Cur : MsgKey : APIErrC);
094700240206    ElseIF not %Equal;
094800240415      CPF9898.Field1 = 'No pay code exists for ' + %Trim(SFL_R.PAPAYCODE) +
094900240415                       ' in the Pay Code Description file';
095000240223      DataErr_89 = *ON;
095100240206    Else;
095200240415      CPF9898.Field1 = 'Error occured when deleting the pay code ' + %Trim(SFL_R.PAPAYCODE) +
095300240415      ' from the Pay Code Description file';
095400240223      DataErr_89 = *ON;
095500240206    EndIf;
095600240206  EndIf;
095700231109
095800240103  // Show the action taken message..................................................................
095900240314  SndPgmMsg(CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :
096000240314    MsgQNbr_Cur : MsgKey : APIErrC);
096100240223
096200240223  // If delete of the data was successful, clear out data on the main screen........................
096300240223  If DataErr_89 = *OFF;
096400240322    Clear CTL_R.SRCH4TEXT;                       // Clear out any search values
096500240322    Clear SFL_R;                                 // Clear out option data entered
096600240322    ClrSFData();                                 // Clear out subfile data
096700240322    SortCol_34 = *ON;                            // Set to sort on code column indicator
096800240322    ScanMod_35 = *OFF;                           // Turn off scan mode
096900240322    OnlyAct_38 = *OFF;                           // Turn off show only active accounts
097000240415    RtvPayCodes(RTVBYCODE);
097100240223  EndIf;
097200240223
097300240103  // Going up one level in the message queue........................................................
097400240103  MsgQNbr_Cur -= 1;
097500231109
097600240416End-Proc DltPayCodeData;
097700230809
097800240313//--------------------------------------------------------------------------------------------------
097900240313//- SUBPROCEDURE: CloseOpenFiles                                                                   -
098000240313//- FUNCTION....: Close Files Opened By This Program                                               -
098100240313//- EXPLANATION.: Some files were opened by this program so that the file could be overridden at   -
098200240313//-               the time it was opened. At the end of the program these files need to be closed. -
098300240313//--------------------------------------------------------------------------------------------------
098400240313Dcl-Proc CloseOpenFiles;
098500240313
098600240327  // Close the Pay Code Description file............................................................
098700240327  If %Open(PAYD);
098800240327    Close(E) PAYD;
098900240327  EndIf;
099000240327
099100240313End-Proc CloseOpenFiles;
099200240313
099300240103//--------------------------------------------------------------------------------------------------
099400240103// FUNCTION....: Center text within a field                                                        -
099500240103//--------------------------------------------------------------------------------------------------
099600230809/COPY QCPYSRC,F_CENTRTXT
