//+------------------------------------------------------------------+
//|                                                   utilString.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
 #include <Arrays\ArrayString.mqh>
class utilDateTime
{
   public : 
      static datetime GetTimeLocal();
};
datetime utilDateTime::GetTimeLocal( void )
{ 
   string tmpFileName      = "_TEMP_FILE";
   int handleTmpFile       = FileOpen(tmpFileName, FILE_WRITE); if(handleTmpFile==INVALID_HANDLE);
   datetime now            = (datetime)FileGetInteger(handleTmpFile, FILE_CREATE_DATE);
   MqlDateTime nowMql;

   FileClose(handleTmpFile);
   FileDelete(tmpFileName);
   return now;
}


//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
