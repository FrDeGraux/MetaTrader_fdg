//+------------------------------------------------------------------+
//|                                                       CiRAVI.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "Custom.mqh"
#define INDICATOR_NAME "Custom Moving Average Input Color_Cyan_Hysteresise"

#define INITIAL_BUFFER_SIZE 2048

//https://stackoverflow.com/questions/52769369/mql5-pass-indicator-as-parameter
#include <MqlParams.mqh>
#include "CICustomMA.mqh"

class CICustomMA_Yellow_Hysteresis : public CICustomMA
  {

public:
                     CICustomMA_Yellow_Hysteresis(int _window_backward,double long_ma_period);
                    ~CICustomMA_Yellow_Hysteresis();
   bool Create(  string symbol,ENUM_TIMEFRAMES tf ,int MAPeriod,enMaTypes inpMaMethod,CMqlParams& params) ;
private : 

  }; 
  
bool CiCustomMA_Yellow_Hysteresis::Create(  string symbol, 
                            ENUM_TIMEFRAMES tf,string ind_Name, 
                            int _MAPeriod, 
                            enMaTypes inpMaMethod)
 {
 CMqlParams params;
 params.Set(window_backward, TYPE_UCHAR);
  params.Set(long_ma_period,TYPE_UCHAR);
 return(CICustomMA_Yellow::Create(symbol,tf,INDICATOR_NAME,MAPeriod,inpMaMethod,params));
 
 
 }
 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
