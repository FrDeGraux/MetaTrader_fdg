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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiCustomMA_Yellow_Hysteresis : public CICustomMA
  {
private:
   int               window_backward;
   int               long_ma_period;
   int               method;



public:
                     CiCustomMA_Yellow_Hysteresis(int _window_backward,double long_ma_period,enMaTypes method);
                    ~CiCustomMA_Yellow_Hysteresis();
   bool              Create(string symbol,
               ENUM_TIMEFRAMES tf,
               int MAPeriod,
               enMaTypes inpMaMethod);
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiCustomMA_Yellow_Hysteresis::Create(string symbol,
      ENUM_TIMEFRAMES tf,
      int _MAPeriod,
      enMaTypes inpMaMethod)
  {
   CMqlParams params;
   string ind = INDICATOR_NAME;
   params.Set(ind, TYPE_STRING);
   params.Set(window_backward, TYPE_UCHAR);
   params.Set(long_ma_period,TYPE_UCHAR);
   params.Set(method,TYPE_UCHAR);
   return(CICustomMA::Create(symbol,tf,INDICATOR_NAME,_MAPeriod,inpMaMethod,params));



  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CiCustomMA_Yellow_Hysteresis::CiCustomMA_Yellow_Hysteresis(int _window_backward,double _long_ma_period,enMaTypes _method)
  {
   window_backward = _window_backward;
   long_ma_period = _long_ma_period;
   method  = _method;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CiCustomMA_Yellow_Hysteresis::~CiCustomMA_Yellow_Hysteresis()
  {

  }
//+------------------------------------------------------------------+
