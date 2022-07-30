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

#define HYSTERESIS_NBUFFERS 5
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
                     CiCustomMA_Yellow_Hysteresis(int _window_backward,double _long_ma_period);
                    ~CiCustomMA_Yellow_Hysteresis();

   bool              Create(const string symbol,const ENUM_TIMEFRAMES period,
               const int ma_period,const int ma_shift,
               const ENUM_MA_METHOD ma_method,const int applied);
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiCustomMA_Yellow_Hysteresis::Create(const string symbol,const ENUM_TIMEFRAMES period,
               const int ma_period,const int ma_shift,
               const ENUM_MA_METHOD ma_method,const int applied)
  {
   CMqlParams params;
   if(!CICustomMA::Create(symbol,period,ma_period,ma_shift,ma_method,applied));
      return false;
      

     if(!BufferResize(window_backward))
     {
         Print("Error BufferResizeHysteresis MA");
      return(false);  
     }
//--- ok
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CiCustomMA_Yellow_Hysteresis::CiCustomMA_Yellow_Hysteresis(int _window_backward,double _long_ma_period) :  CICustomMA(INDICATOR_NAME,HYSTERESIS_NBUFFERS)
  {
   window_backward = _window_backward;
   long_ma_period = _long_ma_period;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CiCustomMA_Yellow_Hysteresis::~CiCustomMA_Yellow_Hysteresis()
  {

  }
//+------------------------------------------------------------------+
