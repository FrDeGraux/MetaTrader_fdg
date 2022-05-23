//+------------------------------------------------------------------+
//|                                                       CiRAVI.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "Custom.mqh"
#define INDICATOR_NAME "ATR_onPrices"
#define INITIAL_BUFFER_SIZE 2048
//https://stackoverflow.com/questions/52769369/mql5-pass-indicator-as-parameter
#include <MqlParams.mqh>

class CICustomATR : public CiCustom
  {
private:

public:
                     CICustomATR();
                    ~CICustomATR();
                    double            Main(const int index) const;
                    bool Create(string symbol,ENUM_TIMEFRAMES tf,int ExtPeriodATR,int AtrMultiplier_SL,int AtrMultiplier_TP);
                       bool     Initialize(const string symbol, 
                              const ENUM_TIMEFRAMES period, 
                              const int num_params, 
                              const MqlParam &params[]);

  }; 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CICustomATR::CICustomATR()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CICustomATR::~CICustomATR()
  {
  }
//+------------------------------------------------------------------+
double CICustomATR::Main(const int index) const
  {
   CIndicatorBuffer *buffer=At(0);
//--- check
   if(buffer==NULL) 
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }
//+---
bool CICustomATR::Create(  string symbol,ENUM_TIMEFRAMES tf,int ExtPeriodATR,int AtrMultiplier_SL,int AtrMultiplier_TP) 
{
   // #1 Setup the MQL params array for the custom indicator.
   CMqlParams params;

   params.Set(INDICATOR_NAME, TYPE_STRING)
 
         .Set(ExtPeriodATR, TYPE_UCHAR)
         .Set(AtrMultiplier_SL, TYPE_UCHAR)
         .Set(AtrMultiplier_TP, TYPE_UCHAR);
       
       
   int handle = -1;
   long nCharts = -1;
   
    if(!ChartGetInteger(0,CHART_WINDOWS_TOTAL,0,nCharts))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
   // #2 Call the parent Create method with the params
   if (!CiCustom::Create(symbol, tf, IND_CUSTOM, params.Total(), params.params))
      return false; 
   ChartIndicatorAdd(0,0,handle);
   // #3 Resize the buffer to the desired initial size
   if (!this.BufferResize(INITIAL_BUFFER_SIZE))
      return false;
   return true; 
}
bool CICustomATR::Initialize(const string symbol, 
                              const ENUM_TIMEFRAMES period, 
                              const int num_params, 
                              const MqlParam &params[]
) {
   // #1 Specify if this indicator redraws
   this.Redrawer(true);
   // #2 Specify the number of indicator buffers to be used. 
   if (!this.NumBuffers(3))
      return false; 
   // #3 Call super.Initialize 
   if (!CiCustom::Initialize(symbol, period, num_params, params))
      return false;
   return true;
}