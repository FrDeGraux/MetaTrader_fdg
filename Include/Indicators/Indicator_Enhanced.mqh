//+------------------------------------------------------------------+
//|                                           Indicator_Enhanced.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "Indicator.mqh"
#include <MqlParams.mqh>
class CIndicator_Enhanced : public CIndicator
  {
private:

public:
                     CIndicator_Enhanced();
                    ~CIndicator_Enhanced();
                     virtual bool Create(const string symbol,const ENUM_TIMEFRAMES period,
                            const int ma_period,const int ma_shift,
                            const ENUM_MA_METHOD ma_method,const int applied,CMqlParams& params) = 0;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CIndicator_Enhanced::CIndicator_Enhanced()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CIndicator_Enhanced::~CIndicator_Enhanced()
  {
  }
//+------------------------------------------------------------------+
