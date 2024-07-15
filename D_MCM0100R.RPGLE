000100240313**Free
000200240313//*************************************************************************************************/
000300240313//                                   EMMI Physician Service, Inc.                                  /
000400240313//                                               ©2024                                             /
000500240313//*************************************************************************************************/
000600240313// PROTOTYPE...: D_MCM0100R                                                                        /
000700240313// CREATE DATE.: 03/19/2024                                                                        /
000800240313// PROGRAMMER..: Johnny Skaggs                                                                     /
000900240313// FUNCTION....: Account Type Code Maintenance                                                     /
001000240313// EXPLANATION.: Display a screen that shows the account type codes for the customer. The screen   /
001100240313//               allows the data to changed, deleted displayed or added to. To add, change or      /
001200240313//               delete the account type code data, the user must have the correct authority;      /
001300240313//               otherwise the user will only be able to view the data. Messages produced by this  /
001400240313//               program will be passed back to the calling program to handle.                     /
001500240313//                                                                                                 /
001600240313//+++++++++++++++++++++++++++++++++++++  P R O T O T Y P E S  +++++++++++++++++++++++++++++++++++++/
001700240313//       NAME       TYP                                 DESCRIPTION                                /
001800240313// ---------------- --- -------------------------------------------------------------------------- /
001900240313// AccTypCdeMnt.........Account type code maintenance                                              /
002000240313//  RetFncKey       Out ·Function key pressed in this program that needs to be returned to the     /
002100240313//                       calling program (for example, F03=Exit back to menu)                      /
002200240313//  RetMsgTyp       Out ·Program message type: ERR=Error, INF=Informational, WRN=Warning           /
002300240313//  RetPgmMsg       Out ·Message returned by this program to the calling program                   /
002400240313//                                                                                                 /
002500240313//+++++++++++++++++++++++++++++++++  D A T A  S T R U C T U R E S  ++++++++++++++++++++++++++++++++/
002600240313//       NAME       TYP                                 DESCRIPTION                                /
002700240313// ---------------- --- -------------------------------------------------------------------------- /
002800240313// ATCM.................Account type code maintenance                                              /
002900240313//  RetFncKey       Out ·Function key pressed in this program that needs to be returned to the     /
003000240313//                       calling program (for example, F03=Exit back to menu)                      /
003100240313//  RetMsgTyp       Out ·Program message type: ERR=Error, INF=Informational, WRN=Warning           /
003200240313//  RetPgmMsg       Out ·Message returned by this program to the calling program                   /
003300240313//                                                                                                 /
003400240313//+++++++++++++++++++++++++++++++++++  I L L U S T R A T I O N  +++++++++++++++++++++++++++++++++++/
003500240313//                                                                                                 /
003600240416// // Prototype-Account type code maintenance..................................................... /
003700240313// /COPY QCPYSRC,D_MCM0100R                                                                        /
003800240313//                                                                                                 /
003900240416// // Account type code maintenance............................................................... /
004000240313// AccTypCdeMnt(ATCM.RetFncKey : ATCM.RetMsgTyp : ATCM.RetPgmMsg);                                 /
004100240416// If ATCM.RetPgmMsg <> *BLANKS';                                                                  /
004200240313//   CPF9898.Field1 = PCAT.RetPgmMsg;                                                              /
004300240313//   SndPgmMsg( CPF_GenMsg : MsgFile_CPF : CPF9898 : %Len(CPF9898) : MsgTy_Diag : MsgQ_Cur :       /
004400240313//              MsgQNbr_Cur : MsgKey : APIErrC );                                                  /
004500240416//   If ATCM.RetMsgTyp = 'ERR';                                                                    /
004600240313//     DataErr_89 = *ON;                                                                           /
004700240313//   EndIf;                                                                                        /
004800240416// ElseIf ATCM.RetFncKey = 'F03';                                                                  /
004900240313//   F3_Exit = *ON;                                                                                /
005000240313//   Return;                                                                                       /
005100240313// EndIf;                                                                                          /
005200240313//                                                                                                 /
005300240313//++++++++++++++++++++++++++++++++++  M O D I F I C A T I O N S  ++++++++++++++++++++++++++++++++++/
005400240313// DATE..: MM/DD/CCYY   PROGRAMMER: First and last name                                            /
005500240313// REASON: Project number or ticket number                                                         /
005600240313// MODS..: What changes were made to the program                                                   /
005700240313//                                                                                                 /
005800240313//*************************************************************************************************/
005900240313
006000240313// Prototype definition........................................................................
006100240313Dcl-PR AccTypCdeMnt ExtPgm('MCM0100R');
006200240313  RetFncKey Char( 3);
006300240313  RetMsgTyp Char( 3);
006400240313  RetPgmMsg Char(78);
006500240313End-PR;
006600240313
006700240313// Declare data structure for prototype........................................
006800240313Dcl-DS ATCM Qualified Inz;
006900240313  RetFncKey Char( 3);
007000240313  RetMsgTyp Char( 3);
007100240313  RetPgmMsg Char(78);
007200240313End-DS;
