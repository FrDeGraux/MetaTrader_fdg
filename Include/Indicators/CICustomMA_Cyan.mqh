//|                                                       CiRAVI.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "Custom.mqh"
#define INDICATOR_NAME "Custom Moving Average Input Color_White"



//https://stackoverflow.com/questions/52769369/mql5-pass-indicator-as-parameter
#include <MqlParams.mqh>
#include "CICustomMA.mqh"

class CICustomMA_Cyan : public CICustomMA
  {

public:
                     CICustomMA_Cyan();
                    ~CICustomMA_Cyan();
                    
   static const int bufferSize;
   bool              Create(const string symbol,const ENUM_TIMEFRAMES period,
               const int ma_period,const int ma_shift,
               const ENUM_MA_METHOD ma_method,const int applied);
                 
               
               
private : 

  }; 
   const int CICustomMA_Cyan::bufferSize = 1;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CICustomMA_Cyan::CICustomMA_Cyan() : CICustomMA(INDICATOR_NAME)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CICustomMA_Cyan::~CICustomMA_Cyan()
  {
  }
//+------------------------------------------------------------------+
bool CICustomMA_Cyan::Create(const string symbol,const ENUM_TIMEFRAMES period,
               const int ma_period,const int ma_shift,
               const ENUM_MA_METHOD ma_method,const int applied)
  {
   CMqlParams params;
   if(!(CICustomMA::Create(symbol,period,ma_period,ma_shift,ma_method,applied)))
      return false;
    if(!BufferResize(bufferSize))
     {
         Print("Error CICustomMA_Cyan BufferResizeHysteresis MA");
      return(false);  
     }
     return true;
  }