000100240325**Free
000200240325//*************************************************************************************************/
000300240325//                                   EMMI Physician Service, Inc.                                  /
000400240325//                                               ©2024                                             /
000500240325//*************************************************************************************************/
000600240325// PROTOTYPE...: D_MCM0104R                                                                        /
000700240325// CREATE DATE.: 03/25/2024                                                                        /
000800240325// PROGRAMMER..: Johnny Skaggs                                                                     /
000900240325// FUNCTION....: Change Account Type Based on Associated Pay Code                                  /
001000240325// EXPLANATION.: Display a window for the adding, changing or deleting of the pay code and the     /
001100240325//               corresponding account type code. When changing the account type code for the      /
001200240325//               associated pay code, the pay code cannot be changed only the account type code    /
001300240325//               will be able to be changed. A new entry for the pay code and associated account   /
001400240325//               type code must be made in order to change the pay code, and the old one must be   /
001500240325//               deleted. You must have the correct authority to add, change or delete the pay     /
001600240325//               code and assoicated account type code; otherwise, you can only display the data,  /
001700240325//               which means that this program will not be called for those who only have display  /
001800240325//               rights to the data. Any messages produced by this program will be passed back to  /
001900240325//               the calling program to handle. When the function key F3 is pressed, a code of F03 /
002000240325//               will be passed back to the calling program, so that the calling program knows to  /
002100240325//               exit to the menu from which it was ran.                                           /
002200240325//                                                                                                 /
002300240325//+++++++++++++++++++++++++++++++++++++  P R O T O T Y P E S  +++++++++++++++++++++++++++++++++++++/
002400240325//       NAME       TYP                                 DESCRIPTION                                /
002500240325// ---------------- --- -------------------------------------------------------------------------- /
002600240325// PayCdeAccTyp.........Change the account type based on the associated pay code                   /
002700240325//  CustCode        In  ·Group code used to identify the customer                                  /
002800240325//  AccTypCde       In  ·Account type code                                                         /
002900240325//  PayCode         In  ·Pay code                                                                  /
003000240325//  AcctType        In  ·Financial class account type                                              /
003100240325//  AddChgDlt       In  ·Perform one of the following on the account type data: add/change/delete  /
003200240325//  ExitAdd         Out ·End the add process in MCM0102R                                           /
003300240325//  RetMsgTyp       Out ·Program message type: ERR=Error, INF=Informational, WRN=Warning           /
003400240325//  RetPgmMsg       Out ·Message returned by this program to the calling program                   /
003500240325//                                                                                                 /
003600240325//+++++++++++++++++++++++++++++++++  D A T A  S T R U C T U R E S  ++++++++++++++++++++++++++++++++/
003700240325//       NAME       TYP                                 DESCRIPTION                                /
003800240325// ---------------- --- -------------------------------------------------------------------------- /
003900240325// PCAT.................Change the account type based on the associated pay code                   /
004000240325//  CustCode        In  ·Group code used to identify the customer                                  /
004100240325//  AccTypCde       In  ·Account type code                                                         /
004200240325//  PayCode         In  ·Pay code                                                                  /
004300240325//  AcctType        In  ·Financial class account type                                              /
004400240325//  AddChgDlt       In  ·Perform one of the following on the account type data: add/change/delete  /
004500240325//  ExitAdd         Out ·End the add process in MCM0102R                                           /
004600240325//  RetMsgTyp       Out ·Program message type: ERR=Error, INF=Informational, WRN=Warning           /
004700240325//  RetPgmMsg       Out ·Message returned by this program to the calling program                   /
004800240325//                                                                                                 /
004900240325//+++++++++++++++++++++++++++++++++++  I L L U S T R A T I O N  +++++++++++++++++++++++++++++++++++/
005000240325//                                                                                                 /
005100240325// // Prototype-Add/Change/Delete the account type based on the associated pay code............... /
005200240325// /COPY QCPYSRC,D_MCM0104R                                                                        /
005300240325//                                                                                                 /
005400240325// // Change the account type based on the associated pay code.................................... /
005500240325// PayCdeAccTyp(CustCode : AcctTypCde : PayCode : ChgAccCode : DISPLAY : PACT.ExitAdd :            /
005600240325//              PACT.RetMsgTyp : PACT.RetPgmMsg);                                                  /
005700240325//                                                                                                 /
005800240325//++++++++++++++++++++++++++++++++++  M O D I F I C A T I O N S  ++++++++++++++++++++++++++++++++++/
005900240325// DATE..: MM/DD/CCYY   PROGRAMMER: First and last name                                            /
006000240325// REASON: Project number or ticket number                                                         /
006100240325// MODS..: What changes were made to the program                                                   /
006200240325//                                                                                                 /
006300240325//*************************************************************************************************/
006400240325
006500240325// Prototype definition........................................................................
006600240325Dcl-PR PayCdeAccTyp ExtPgm('MCM0104R');
006700240325  CustCode  Char( 2) Const;
006800240325  AccTypCde Char( 2) Const;
006900240325  PayCode   Char( 2) Const;
007000240325  ChgAccTyp Char( 2) Const;
007100240325  AddChgDlt Char( 3) Const;
007200240325  ExitAdd   Char( 1);
007300240325  RetMsgTyp Char( 3);
007400240325  RetPgmMsg Char(78);
007500240325
007600240325End-PR;
007700240325
007800240325// Declare data structure for prototype........................................
007900240325Dcl-DS PCAT Qualified Inz;
008000240325  CustCode  Char( 2);
008100240325  AccTypCde Char( 2);
008200240325  PayCode   Char( 2);
008300240325  ChgAccTyp Char( 2);
008400240325  AddChgDlt Char( 3);
008500240325  ExitAdd   Char( 1);
008600240325  RetMsgTyp Char( 3);
008700240325  RetPgmMsg Char(78);
008800240325End-DS;
