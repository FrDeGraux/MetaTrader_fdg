//+------------------------------------------------------------------+
//|                                         CiCustomMAHysteresis.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "CICustomMA.mqh"
#define INDICATOR_NAME "Custom Moving Average Input Color_Yellow_hysteresis"
#define INITIAL_BUFFER_SIZE 2048
class CiCustomMAHysteresisBackWard : public CICustomMA
  {
private:
   int window_backward;
   int long_ma_period;



public:
                     CiCustomMAHysteresisBackWard(int _window_backward,double long_ma_period);
                    ~CiCustomMAHysteresisBackWard();
                                        bool Create(  string symbol, 
                            ENUM_TIMEFRAMES tf,
                            int MAPeriod, 
                            enMaTypes inpMaMethod);
  };
  
 
bool CiCustomMAHysteresisBackWard::Create(  string symbol, 
                            ENUM_TIMEFRAMES tf, 
                            int _MAPeriod, 
                            enMaTypes inpMaMethod)
 {
 CMqlParams params;
 params.Set(window_backward, TYPE_UCHAR);
  params.Set(long_ma_period,TYPE_UCHAR);
 return(CICustomMA::Create(symbol,tf,INDICATOR_NAME,MAPeriod,inpMaMethod,params));
 
 
 }
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CiCustomMAHysteresisBackWard::CiCustomMAHysteresisBackWard(int _window_backward,double _long_ma_period)
  {
  window_backward = _window_backward;
long_ma_period = _long_ma_period;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CiCustomMAHysteresisBackWard::~CiCustomMAHysteresisBackWard()
  {
  
  }
//+------------------------------------------------------------------+
