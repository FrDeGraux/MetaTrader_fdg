//+------------------------------------------------------------------+
//|                                         MqlOutputMessageBase.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <MqlOutputMessageBase.mqh>
class MqlOutputMessageMM : MqlOutputMessageBase

  {
                     MqlOutputMessageMM(int _id,datetime _dt,string _symbol,int _type,int _entry,double _price,double _sl,double _tp);

                     MqlOutputMessageMM(int _id,datetime _dt,string _symbol,int _type,int _entry,double _price);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MqlOutputMessageMM::MqlOutputMessageMM(int _id,datetime _dt,string _symbol,int _type,int _entry,double _price,double _sl,double _tp) : MqlOutputMessageBase(_id,_dt,_symbol,_type,_entry,_price,_sl,_tp)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MqlOutputMessageMM::MqlOutputMessageMM(int _id,datetime _dt,string _symbol,int _type,int _entry,double _price) : MqlOutputMessageBase(_id,_dt,_symbol,_type,_entry,_price)
  {
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
