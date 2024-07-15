000100240416**Free
000200240416//*************************************************************************************************/
000300240416//                                   EMMI Physician Service, Inc.                                  /
000400240416//                                               ©2024                                             /
000500240416//*************************************************************************************************/
000600240416// PROTOTYPE...: D_MCM0201R                                                                        /
000700240416// CREATE DATE.: 04/16/2024                                                                        /
000800240416// PROGRAMMER..: Johnny Skaggs                                                                     /
000900240416// FUNCTION....: Display/Add/Change The Pay Code Data                                              /
001000240416// EXPLANATION.: Display a screen that contains the financial class account type code data for the /
001100240416//               code that was passed to the program. The user must authority to change/add        /
001200240416//               account type code data; otherwise, the data can on be displayed.  Any messages    /
001300240416//               produced by this program will be passed back to the calling program to handle.    /
001400240416//                                                                                                 /
001500240416//+++++++++++++++++++++++++++++++++++++  P R O T O T Y P E S  +++++++++++++++++++++++++++++++++++++/
001600240416//       NAME       TYP                                 DESCRIPTION                                /
001700240416// ---------------- --- -------------------------------------------------------------------------- /
001800240416// ProcAccTyp...........Return the financial class account type                                    /
001900240416//  CustCode        In  ·Group code used to identify the customer                                  /
002000240416//  PayCode         In  ·Pay code                                                                  /
002100240416//  AddChgDsp       In  ·Perform one of the following on the account type data: add/change/display /
002200240416//  RetFncKey       Out ·Function key pressed in this program that needs to be returned to the     /
002300240416//                       calling program (for example, F03=Exit back to menu)                      /
002400240416//  RetMsgTyp       Out ·Program message type: ERR=Error, INF=Informational, WRN=Warning           /
002500240416//  RetPgmMsg       Out ·Message returned by this program to the calling program                   /
002600240416//                                                                                                 /
002700240416//+++++++++++++++++++++++++++++++++  D A T A  S T R U C T U R E S  ++++++++++++++++++++++++++++++++/
002800240416//       NAME       TYP                                 DESCRIPTION                                /
002900240416// ---------------- --- -------------------------------------------------------------------------- /
003000240416// PPC..................Pay Code                                                                   /
003100240416//  CustCode        In  ·Group code used to identify the customer                                  /
003200240416//  PayCode         In  ·Pay code                                                                  /
003300240416//  AddChgDsp       In  ·Perform one of the following on the account type data: add/change/display /
003400240416//  RetFncKey       Out ·Function key pressed in this program that needs to be returned to the     /
003500240416//                       calling program (for example, F03=Exit back to menu)                      /
003600240416//  RetMsgTyp       Out ·Program message type: ERR=Error, INF=Informational, WRN=Warning           /
003700240416//  RetPgmMsg       Out ·Message returned by this program to the calling program                   /
003800240416//                                                                                                 /
003900240416//+++++++++++++++++++++++++++++++++++  I L L U S T R A T I O N  +++++++++++++++++++++++++++++++++++/
004000240416//                                                                                                 /
004100240416// // Prototype-Add/Change/Display the Pay Code Description data.................................. /
004200240416// /COPY QCPYSRC,D_MCM0201R                                                                        /
004300240416//                                                                                                 /
004400240416// // Process the request for the pay code description data....................................... /
004500240416// ProcAccTyp(CustCode : PayCode : AddChgDsp : PPC.RetFncKey : PPC.RetMsgTyp : PPC.RetPgmMsg);     /
004600240416// If PPC.RetPgmMsg <> *BLANKS';                                                                   /
004700240416//   CPF9898.Field1 = PPC.RetPgmMsg;                                                               /
004800240416//   SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :       /
004900240416//              MsgQNbr_Cur : MsgKey : APIErrC );                                                  /
005000240416//   If PPC.RetMsgTyp = 'ERR';                                                                     /
005100240416//     DataErr_89 = *ON;                                                                           /
005200240416//   EndIf;                                                                                        /
005300240416// ElseIf PPC.RetFncKey = 'F03';                                                                   /
005400240416//   F3_Exit = *ON;                                                                                /
005500240416//   Return;                                                                                       /
005600240416// EndIf;                                                                                          /
005700240416//                                                                                                 /
005800240416//++++++++++++++++++++++++++++++++++  M O D I F I C A T I O N S  ++++++++++++++++++++++++++++++++++/
005900240416// DATE..: MM/DD/CCYY   PROGRAMMER: First and last name                                            /
006000240416// REASON: Project number or ticket number                                                         /
006100240416// MODS..: What changes were made to the program                                                   /
006200240416//*************************************************************************************************/
006300240416
006400240416// Prototype definition........................................................................
006500240416Dcl-PR ProcPayCde ExtPgm('MCM0201R');
006600240416  CustCode  Char( 2) Const;
006700240416  PayCode   Char( 2) Const;
006800240416  AddChgDsp Char( 3) Const;
006900240416  RetFncKey Char( 3);
007000240416  RetMsgTyp Char( 3);
007100240416  RetPgmMsg Char(78);
007200240416End-PR;
007300240416
007400240416// Declare data structure for prototype........................................
007500240416Dcl-DS PPC Qualified Inz;
007600240416  CustCode  Char( 2);
007700240416  PayCode   Char( 2);
007800240416  AddChgDsp Char( 3);
007900240416  RetFncKey Char( 3);
008000240416  RetMsgTyp Char( 3);
008100240416  RetPgmMsg Char(78);
008200240416End-DS;
