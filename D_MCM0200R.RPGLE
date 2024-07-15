000100240416**Free
000200240416//*************************************************************************************************/
000300240416//                                   EMMI Physician Service, Inc.                                  /
000400240416//                                               ©2024                                             /
000500240416//*************************************************************************************************/
000600240416// PROTOTYPE...: D_MCM0200R                                                                        /
000700240416// CREATE DATE.: 04/16/2024                                                                        /
000800240416// PROGRAMMER..: Johnny Skaggs                                                                     /
000900240416// FUNCTION....: Pay Code Description Maintenance                                                  /
001000240416// EXPLANATION.: Display a screen that shows the pay codes for the customer. The screen allows the /
001100240416//               data to changed, deleted displayed or added to. To add, change or delete the      /
001200240416//               account type code data, the user must have the correct authority; otherwise, the  /
001300240416//               user will only be able to view the data. Messages produced by this program will   /
001400240416//               be passed back to the calling program to handle.                                  /
001500240416//                                                                                                 /
001600240416//+++++++++++++++++++++++++++++++++++++  P R O T O T Y P E S  +++++++++++++++++++++++++++++++++++++/
001700240416//       NAME       TYP                                 DESCRIPTION                                /
001800240416// ---------------- --- -------------------------------------------------------------------------- /
001900240416// PayCdeDscMnt.........Pay code description maintenance                                           /
002000240416//  RetFncKey       Out ·Function key pressed in this program that needs to be returned to the     /
002100240416//                       calling program (for example, F03=Exit back to menu)                      /
002200240416//  RetMsgTyp       Out ·Program message type: ERR=Error, INF=Informational, WRN=Warning           /
002300240416//  RetPgmMsg       Out ·Message returned by this program to the calling program                   /
002400240416//                                                                                                 /
002500240416//+++++++++++++++++++++++++++++++++  D A T A  S T R U C T U R E S  ++++++++++++++++++++++++++++++++/
002600240416//       NAME       TYP                                 DESCRIPTION                                /
002700240416// ---------------- --- -------------------------------------------------------------------------- /
002800240416// PCDM.................Pay code description maintenance                                           /
002900240416//  RetFncKey       Out ·Function key pressed in this program that needs to be returned to the     /
003000240416//                       calling program (for example, F03=Exit back to menu)                      /
003100240416//  RetMsgTyp       Out ·Program message type: ERR=Error, INF=Informational, WRN=Warning           /
003200240416//  RetPgmMsg       Out ·Message returned by this program to the calling program                   /
003300240416//                                                                                                 /
003400240416//+++++++++++++++++++++++++++++++++++  I L L U S T R A T I O N  +++++++++++++++++++++++++++++++++++/
003500240416//                                                                                                 /
003600240416// // Prototype-Pay code description maintenance.................................................. /
003700240416// /COPY QCPYSRC,D_MCM0200R                                                                        /
003800240416//                                                                                                 /
003900240416// // Pay code description maintenance............................................................ /
004000240416// PayCdeDscMnt(PCDM.RetFncKey : PCDM.RetMsgTyp : PCDM.RetPgmMsg);                                 /
004100240416// If PCDM.RetPgmMsg <> *BLANKS';                                                                  /
004200240416//   CPF9898.Field1 = PCAT.RetPgmMsg;                                                              /
004300240416//   SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :       /
004400240416//              MsgQNbr_Cur : MsgKey : APIErrC );                                                  /
004500240416//   If PCDM.RetMsgTyp = 'ERR';                                                                    /
004600240416//     DataErr_89 = *ON;                                                                           /
004700240416//   EndIf;                                                                                        /
004800240416// ElseIf PCDM.RetFncKey = 'F03';                                                                  /
004900240416//   F3_Exit = *ON;                                                                                /
005000240416//   Return;                                                                                       /
005100240416// EndIf;                                                                                          /
005200240416//                                                                                                 /
005300240416//++++++++++++++++++++++++++++++++++  M O D I F I C A T I O N S  ++++++++++++++++++++++++++++++++++/
005400240416// DATE..: MM/DD/CCYY   PROGRAMMER: First and last name                                            /
005500240416// REASON: Project number or ticket number                                                         /
005600240416// MODS..: What changes were made to the program                                                   /
005700240416//                                                                                                 /
005800240416//*************************************************************************************************/
005900240416
006000240416// Prototype definition........................................................................
006100240416Dcl-PR PayCdeDscMnt ExtPgm('MCM0200R');
006200240416  RetFncKey Char( 3);
006300240416  RetMsgTyp Char( 3);
006400240416  RetPgmMsg Char(78);
006500240416End-PR;
006600240416
006700240416// Declare data structure for prototype........................................
006800240416Dcl-DS PCDM Qualified Inz;
006900240416  RetFncKey Char( 3);
007000240416  RetMsgTyp Char( 3);
007100240416  RetPgmMsg Char(78);
007200240416End-DS;
