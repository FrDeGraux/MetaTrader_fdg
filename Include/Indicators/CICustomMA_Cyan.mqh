//+------------------------------------------------------------------+
//|                                                       CiRAVI.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "Custom.mqh"

//https://stackoverflow.com/questions/52769369/mql5-pass-indicator-as-parameter
#include <MqlParams.mqh>
#include "CICustomMA.mqh"
#define INDICATOR_NAME "Custom Moving Average Input Color_Cyan"

class CICustomMA_Cyan : public CICustomMA
  
{
private : 

public:
                     CICustomMA_Cyan();
                    ~CICustomMA_Cyan();
                     bool Create(  string symbol,ENUM_TIMEFRAMES tf,int MAPeriod,enMaTypes inpMaMethod) ;

  }; 
  bool CICustomMA_Cyan::Create(  string symbol, 
                            ENUM_TIMEFRAMES tf, 
                            int MAPeriod, 
                            enMaTypes inpMaMethod) 
{
CMqlParams params;
return(CICustomMA::Create(symbol,tf,INDICATOR_NAME,MAPeriod,inpMaMethod,params));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CICustomMA_Cyan::CICustomMA_Cyan()
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CICustomMA_Cyan::~CICustomMA_Cyan()
  {
  }
//+------------------------------------------------------------------+
