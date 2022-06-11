//+------------------------------------------------------------------+
//|                                                   utilString.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
 #include <Arrays\ArrayString.mqh>
class UtilString
{
   public : 
      static string unPackStringArray(CArrayString* in,char sep=";");
};
string UtilString::unPackStringArray(CArrayString* _in,char sep)
{
string res = "";
   for (int i=0; i < _in.Total();i++)
   {
      res += _in.At(i) + CharToString(sep);
   }
   return StringSubstr(res,0,StringLen(res)-1);
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
