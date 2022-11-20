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
      static string fromCommentToSwapRate(string& in);
      static int nDigitsFormatSymbol(string in);
      static string fromCommentToSwapRate_NotDeleteSwap(string in_comment);
};
int UtilString::nDigitsFormatSymbol(string in)
{

      int nDigits = 5;
      if(StringFind(in,"JPY") > -1)
         nDigits = 3;
       return nDigits;

}
string UtilString::fromCommentToSwapRate_NotDeleteSwap(string in_comment)
{
   string sep="_";                // A separator as a character
   ushort u_sep; 
   string result[];               // An array to get strings
   //--- Get the separator code
   u_sep=StringGetCharacter(sep,0);
   //--- Split the string to substrings
   int k=StringSplit(in_comment,u_sep,result);
   CArrayString res;
      if(!res.AssignArray(result))
     {
      Print("UtilString::fromCommentToSwapRate Array assigned error");
      return "";
     }
     return res.At(2);
}
string UtilString::fromCommentToSwapRate(string& in_comment)
{

   string sep="_";                // A separator as a character
   ushort u_sep; 
   string result[];               // An array to get strings
   //--- Get the separator code
   u_sep=StringGetCharacter(sep,0);
   //--- Split the string to substrings
   int k=StringSplit(in_comment,u_sep,result);
   CArrayString res;
      if(!res.AssignArray(result))
     {
      Print("UtilString::fromCommentToSwapRate Array assigned error");
      return "";
     }
     in_comment = "";
     for(int j=0 ; j < res.Total(); j++)
     {
     if (j==2) 
         continue;
         
      if (j==0)
             in_comment = res.At(j);
      else
               in_comment = in_comment + "_" + res.At(j);
     }

     return res.At(2);
}
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
