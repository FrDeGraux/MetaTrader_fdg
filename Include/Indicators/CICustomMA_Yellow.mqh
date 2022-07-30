//+------------------------------------------------------------------+
//|                                                       CiRAVI.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |CICustomMA
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "Custom.mqh"
#define INDICATOR_NAME "Custom Moving Average Input Color_Yellow"
#define INITIAL_BUFFER_SIZE 2048
//https://stackoverflow.com/questions/52769369/mql5-pass-indicator-as-parameter
#include <MqlParams.mqh>
#include "CICustomMA.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CICustomMA_Yellow : public CICustomMA
  {
private:

public:
                     CICustomMA_Yellow();
                    ~CICustomMA_Yellow();
   bool              Create(const string symbol,const ENUM_TIMEFRAMES period,
                            const int ma_period,const int ma_shift,
                            const ENUM_MA_METHOD ma_method,const int applied);


  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CICustomMA_Yellow::CICustomMA_Yellow() : CICustomMA(INDICATOR_NAME)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CICustomMA_Yellow::~CICustomMA_Yellow()
  {
  }
//+------------------------------------------------------------------+
bool CICustomMA_Yellow::Create(const string symbol,const ENUM_TIMEFRAMES period,
                               const int ma_period,const int ma_shift,
                               const ENUM_MA_METHOD ma_method,const int applied)
  {
   CMqlParams params;
   return(CICustomMA::Create(symbol,period,ma_period,ma_shift,ma_method,applied));
  }
//+------------------------------------------------------------------+
