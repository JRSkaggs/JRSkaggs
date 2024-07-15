000100240313**Free
000200240313//*************************************************************************************************/
000300240313//                                   EMMI Physician Service, Inc.                                  /
000400240313//                                               ©2024                                             /
000500240313//*************************************************************************************************/
000600240313// PROTOTYPE...: D_MCM0101R                                                                        /
000700240313// CREATE DATE.: 03/13/2024                                                                        /
000800240313// PROGRAMMER..: Johnny Skaggs                                                                     /
000900240313// FUNCTION....: Display/Add/Change The Account Type Code Data                                     /
001000240313// EXPLANATION.: Display a screen that contains the financial class account type code data for the /
001100240313//               code that was passed to the program. The user must authority to change/add        /
001200240313//               account type code data; otherwise, the data can on be displayed.  Any messages    /
001300240313//               produced by this program will be passed back to the calling program to handle.    /
001400240313//                                                                                                 /
001500240313//+++++++++++++++++++++++++++++++++++++  P R O T O T Y P E S  +++++++++++++++++++++++++++++++++++++/
001600240313//       NAME       TYP                                 DESCRIPTION                                /
001700240313// ---------------- --- -------------------------------------------------------------------------- /
001800240313// ProcAccTyp...........Return the financial class account type                                    /
001900240313//  CustCode        In  ·Group code used to identify the customer                                  /
002000240313//  AcctType        In  ·Financial class account type                                              /
002100240313//  AddChgDsp       In  ·Perform one of the following on the account type data: add/change/display /
002200240313//  RetFncKey       Out ·Function key pressed in this program that needs to be returned to the     /
002300240313//                       calling program (for example, F03=Exit back to menu)                      /
002400240313//  RetMsgTyp       Out ·Program message type: ERR=Error, INF=Informational, WRN=Warning           /
002500240313//  RetPgmMsg       Out ·Message returned by this program to the calling program                   /
002600240313//                                                                                                 /
002700240313//+++++++++++++++++++++++++++++++++  D A T A  S T R U C T U R E S  ++++++++++++++++++++++++++++++++/
002800240313//       NAME       TYP                                 DESCRIPTION                                /
002900240313// ---------------- --- -------------------------------------------------------------------------- /
003000240313// PAT..................Financial Class Account Type                                               /
003100240313//  CustCode        In  ·Group code used to identify the customer                                  /
003200240313//  AcctType        In  ·Financial class account type                                              /
003300240313//  AddChgDsp       In  ·Perform one of the following on the account type data: add/change/display /
003400240313//  RetFncKey       Out ·Function key pressed in this program that needs to be returned to the     /
003500240313//                       calling program (for example, F03=Exit back to menu)                      /
003600240313//  RetMsgTyp       Out ·Program message type: ERR=Error, INF=Informational, WRN=Warning           /
003700240313//  RetPgmMsg       Out ·Message returned by this program to the calling program                   /
003800240313//                                                                                                 /
003900240313//+++++++++++++++++++++++++++++++++++  I L L U S T R A T I O N  +++++++++++++++++++++++++++++++++++/
004000240313//                                                                                                 /
004100240313// // Prototype-Add/Change/Display the Account Type Code data..................................... /
004200240313// /COPY QCPYSRC,D_MCM0101R                                                                        /
004300240313//                                                                                                 /
004400240313// // Process the request for the account type data............................................... /
004500240313// ProcAccTyp(CustCode : AcctType : AddChgDsp : PAT.RetFncKey : PAT.RetMsgTyp : PAT.RetPgmMsg);    /
004600240313// If PAT.RetPgmMsg <> *BLANKS';                                                                   /
004700240313//   CPF9898.Field1 = PAT.RetPgmMsg;                                                               /
004800240313//   SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :       /
004900240313//              MsgQNbr_Cur : MsgKey : APIErrC );                                                  /
005000240313//   If PAT.RetMsgTyp = 'ERR';                                                                     /
005100240313//     DataErr_89 = *ON;                                                                           /
005200240313//   EndIf;                                                                                        /
005300240313// ElseIf PAT.RetFncKey = 'F03';                                                                   /
005400240313//   F3_Exit = *ON;                                                                                /
005500240313//   Return;                                                                                       /
005600240313// EndIf;                                                                                          /
005700240313//                                                                                                 /
005800240313//++++++++++++++++++++++++++++++++++  M O D I F I C A T I O N S  ++++++++++++++++++++++++++++++++++/
005900240313// DATE..: MM/DD/CCYY   PROGRAMMER: First and last name                                            /
006000240313// REASON: Project number or ticket number                                                         /
006100240313// MODS..: What changes were made to the program                                                   /
006200240313//                                                                                                 /
006300240313//*************************************************************************************************/
006400240313
006500240313// Prototype definition........................................................................
006600240313Dcl-PR ProcAccTyp ExtPgm('MCM0101R');
006700240313  CustCode  Char( 2) Const;
006800240313  AcctTyCde Char( 2) Const;
006900240313  AddChgDsp Char( 3) Const;
007000240313  RetFncKey Char( 3);
007100240313  RetMsgTyp Char( 3);
007200240313  RetPgmMsg Char(78);
007300240313End-PR;
007400240313
007500240313// Declare data structure for prototype........................................
007600240313Dcl-DS PAT Qualified Inz;
007700240313  CustCode  Char( 2);
007800240313  AcctTyCde Char( 2);
007900240313  AddChgDsp Char( 3);
008000240313  RetFncKey Char( 3);
008100240313  RetMsgTyp Char( 3);
008200240313  RetPgmMsg Char(78);
008300240313End-DS;
