000100240319**Free
000200240319//*************************************************************************************************/
000300240319//                                   EMMI Physician Service, Inc.                                  /
000400240319//                                               ©2024                                             /
000500240319//*************************************************************************************************/
000600240319// PROTOTYPE...: D_MCM0102R                                                                        /
000700240319// CREATE DATE.: 03/19/2024                                                                        /
000800240319// PROGRAMMER..: Johnny Skaggs                                                                     /
000900240319// FUNCTION....: Pay Code To Account Type Maintenance                                              /
001000240319// EXPLANATION.: Display a screen that shows the pay code and the corresponding account type code  /
001100240319//               that the curent account type code will be changed to. The screen will allow the   /
001200240319//               data to changed, deleted displayed or added to. If the user has the correct       /
001300240319//               authority, they are able to add, change or delete the data; otherwise, the user   /
001400240319//               will only be able to view the data.  Any messages produced by this program will   /
001500240319//               be passed back to the calling program to handle. When the function key F3 is      /
001600240319//               pressed, a code of F03 will be passed back to the calling program, so that the    /
001700240319//               calling program knows to exit to the menu from which it was ran.                  /
001800240319//                                                                                                 /
001900240319//+++++++++++++++++++++++++++++++++++++  P R O T O T Y P E S  +++++++++++++++++++++++++++++++++++++/
002000240319//       NAME       TYP                                 DESCRIPTION                                /
002100240319// ---------------- --- -------------------------------------------------------------------------- /
002200240319// PyCdAcTyMnt..........Pay code to account type maintenance                                       /
002300240319//  CustCode        In  ·Group code used to identify the customer                                  /
002400240319//  AcctType        In  ·Financial class account type                                              /
002500240319//  AddChgDsp       In  ·Perform one of the following on the account type data: add/change/display /
002600240319//  RetFncKey       Out ·Function key pressed in this program that needs to be returned to the     /
002700240319//                       calling program (for example, F03=Exit back to menu)                      /
002800240319//  RetMsgTyp       Out ·Program message type: ERR=Error, INF=Informational, WRN=Warning           /
002900240319//  RetPgmMsg       Out ·Message returned by this program to the calling program                   /
003000240319//                                                                                                 /
003100240319//+++++++++++++++++++++++++++++++++  D A T A  S T R U C T U R E S  ++++++++++++++++++++++++++++++++/
003200240319//       NAME       TYP                                 DESCRIPTION                                /
003300240319// ---------------- --- -------------------------------------------------------------------------- /
003400240319// PCATM................Pay code to account type maintenance                                       /
003500240319//  CustCode        In  ·Group code used to identify the customer                                  /
003600240319//  AcctType        In  ·Financial class account type                                              /
003700240319//  AddChgDsp       In  ·Perform one of the following on the account type data: add/change/display /
003800240319//  RetFncKey       Out ·Function key pressed in this program that needs to be returned to the     /
003900240319//                       calling program (for example, F03=Exit back to menu)                      /
004000240319//  RetMsgTyp       Out ·Program message type: ERR=Error, INF=Informational, WRN=Warning           /
004100240319//  RetPgmMsg       Out ·Message returned by this program to the calling program                   /
004200240319//                                                                                                 /
004300240319//+++++++++++++++++++++++++++++++++++  I L L U S T R A T I O N  +++++++++++++++++++++++++++++++++++/
004400240319//                                                                                                 /
004500240319// // Prototype-Change the account type based on the associated pay code.......................... /
004600240319// /COPY QCPYSRC,D_MCM0102R                                                                        /
004700240319//                                                                                                 /
004800240319// // Change the account type based on the associated pay code.................................... /
004900240319// PyCdAcTypMnt(CustCode : AcctType : ADD : PCATM.RetFncKey : PCATM.RetMsgTyp : PCATM.RetPgmMsg);  /
005000240319// If PCAT.RetPgmMsg <> *BLANKS';                                                                  /
005100240319//   CPF9898.Field1 = PCATM.RetPgmMsg;                                                             /
005200240319//   SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :       /
005300240319//              MsgQNbr_Cur : MsgKey : APIErrC );                                                  /
005400240319//   If PCATM.RetMsgTyp = 'ERR';                                                                   /
005500240319//     DataErr_89 = *ON;                                                                           /
005600240319//   EndIf;                                                                                        /
005700240319// ElseIf PCATM.RetFncKey = 'F03';                                                                 /
005800240319//   F3_Exit = *ON;                                                                                /
005900240319//   Return;                                                                                       /
006000240319// EndIf;                                                                                          /
006100240319//                                                                                                 /
006200240319//++++++++++++++++++++++++++++++++++  M O D I F I C A T I O N S  ++++++++++++++++++++++++++++++++++/
006300240319// DATE..: MM/DD/CCYY   PROGRAMMER: First and last name                                            /
006400240319// REASON: Project number or ticket number                                                         /
006500240319// MODS..: What changes were made to the program                                                   /
006600240319//                                                                                                 /
006700240319//*************************************************************************************************/
006800240319
006900240319// Prototype definition........................................................................
007000240319Dcl-PR PyCdAcTypMnt ExtPgm('MCM0102R');
007100240319  CustCode  Char( 2) Const;
007200240319  AcctTyCde Char( 2) Const;
007300240319  AddChgDsp Char( 3) Const;
007400240319  RetFncKey Char( 3);
007500240319  RetMsgTyp Char( 3);
007600240319  RetPgmMsg Char(78);
007700240319End-PR;
007800240319
007900240319// Declare data structure for prototype........................................
008000240319Dcl-DS PCATM Qualified Inz;
008100240319  CustCode  Char( 2);
008200240319  AcctTyCde Char( 2);
008300240319  AddChgDsp Char( 3);
008400240319  RetFncKey Char( 3);
008500240319  RetMsgTyp Char( 3);
008600240319  RetPgmMsg Char(78);
008700240319End-DS;
