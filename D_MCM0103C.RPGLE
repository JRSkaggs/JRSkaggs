000100240319**Free
000200240319//*************************************************************************************************/
000300240319//                                   EMMI Physician Service, Inc.                                  /
000400240319//                                               ©2024                                             /
000500240319//*************************************************************************************************/
000600240319// PROTOTYPE...: D_MCM0103C                                                                        /
000700240319// CREATE DATE.: 03/19/2024                                                                        /
000800240319// PROGRAMMER..: Johnny Skaggs                                                                     /
000900240319// FUNCTION....: Initial Billing Days After Date Of Service                                        /
001000240319// EXPLANATION.: Display a screen that allows modifications to the initial billing days after the  /
001100240319//               date of service for the account type code. The two character company code is      /
001200240319//               passed to the program so that the account type codes will be populated when the   /
001300240319//               screen first appears. The called program will pass back the F3 key so that the    /
001400240319//               calling program will end.                                                         /
001500240319//                                                                                                 /
001600240319//+++++++++++++++++++++++++++++++++++++  P R O T O T Y P E S  +++++++++++++++++++++++++++++++++++++/
001700240319//       NAME       TYP                                 DESCRIPTION                                /
001800240319// ---------------- --- -------------------------------------------------------------------------- /
001900240319// InitBillDys...........Initial billing days after the date of service                            /
002000240319//  CustCode        In  ·Group code used to identify the customer                                  /
002100240319//  RetFncKey       Out ·Function key pressed in this program that needs to be returned to the     /
002200240319//                       calling program (for example, F03=Exit back to menu)                      /
002300240319//                                                                                                 /
002400240319//+++++++++++++++++++++++++++++++++  D A T A  S T R U C T U R E S  ++++++++++++++++++++++++++++++++/
002500240319//       NAME       TYP                                 DESCRIPTION                                /
002600240319// ---------------- --- -------------------------------------------------------------------------- /
002700240319// InitBillDys...........Initial billing days after the date of service                            /
002800240319//  CustCode        In  ·Group code used to identify the customer                                  /
002900240319//  RetFncKey       Out ·Function key pressed in this program that needs to be returned to the     /
003000240319//                       calling program (for example, F03=Exit back to menu)                      /
003100240319//                                                                                                 /
003200240319//+++++++++++++++++++++++++++++++++++  I L L U S T R A T I O N  +++++++++++++++++++++++++++++++++++/
003300240319//                                                                                                 /
003400240319// // Prototype-Initial Billing Days After The Date Of Service.................................... /
003500240319// /COPY QCPYSRC,D_MCM0103C                                                                        /
003600240319//                                                                                                 /
003700240319// // Process the request for the account type data............................................... /
003800240319// InitBillDys('MXX' : PAT.RetFncKey);                                                             /
003900240319// If IBD.RetFncKey = 'F03';                                                                       /
004000240319//   F3_Exit = *ON;                                                                                /
004100240319//   Return;                                                                                       /
004200240319// EndIf;                                                                                          /
004300240319//                                                                                                 /
004400240319//++++++++++++++++++++++++++++++++++  M O D I F I C A T I O N S  ++++++++++++++++++++++++++++++++++/
004500240319// DATE..: MM/DD/CCYY   PROGRAMMER: First and last name                                            /
004600240319// REASON: Project number or ticket number                                                         /
004700240319// MODS..: What changes were made to the program                                                   /
004800240319//                                                                                                 /
004900240319//*************************************************************************************************/
005000240319
005100240319// Prototype definition........................................................................
005200240319Dcl-PR InitBillDys ExtPgm('MCM0103C');
005300240319  CustCode  Char(3) Const;
005400240319  RetFncKey Char(3);
005500240319End-PR;
005600240319
005700240319// Declare data structure for prototype........................................
005800240319Dcl-DS IBD Qualified Inz;
005900240319  CustCode  Char(3);
006000240319  RetFncKey Char(3);
006100240319End-DS;
