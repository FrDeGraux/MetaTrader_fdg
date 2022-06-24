//+------------------------------------------------------------------+
//|                                                       CiRAVI.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "Custom.mqh"
#define INDICATOR_NAME "Custom Moving Average Input Color_White"

#define INITIAL_BUFFER_SIZE 2048

//https://stackoverflow.com/questions/52769369/mql5-pass-indicator-as-parameter
#include <MqlParams.mqh>
#include "CICustomMA.mqh"

class CICustomMA_White : public CICustomMA
  {

public:
                     CICustomMA_White();
                    ~CICustomMA_White();
   bool Create(  string symbol,ENUM_TIMEFRAMES tf ,int MAPeriod,enMaTypes inpMaMethod) ;
private : 

  }; 
  
    bool CICustomMA_White::Create(  string symbol, 
                            ENUM_TIMEFRAMES tf , 
                            int MAPeriod, 
                            enMaTypes inpMaMethod) 
{
CMqlParams params;
return(CICustomMA::Create(symbol,tf,INDICATOR_NAME,MAPeriod,inpMaMethod,params));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CICustomMA_White::CICustomMA_White()
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CICustomMA_White::~CICustomMA_White()
  {
  }
//+------------------------------------------------------------------+
