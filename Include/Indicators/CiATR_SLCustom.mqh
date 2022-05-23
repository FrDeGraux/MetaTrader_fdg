//+------------------------------------------------------------------+
//|                                               CiATR_SLCustom.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include "Oscilators.mqh"
class CiATR_SLCustom : public CiATR
  {
protected:
   int factor;

public:
                     CiATR_SLCustom(int factor);
                    ~CiATR_SLCustom(void);
   //--- methods of access to protected data
 double            Main(const int index) const;
   //--- method of creation
   bool             Create(string sName,const string symbol,const ENUM_TIMEFRAMES period,const int ma_period);

   //--- methods of access to indicator data

   //--- method of identifying


protected:
   bool Initialize(string sName,const string symbol,const ENUM_TIMEFRAMES period,const int ma_period);

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CiATR_SLCustom::CiATR_SLCustom(int _factor) : factor(_factor)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CiATR_SLCustom::~CiATR_SLCustom(void)
  {
  }
bool CiATR_SLCustom::Create(string sName,const string symbol,const ENUM_TIMEFRAMES period,const int ma_period)
  {
//--- check history
   if(!SetSymbolPeriod(symbol,period))
      return(false);
//--- create
   m_handle=iATR(symbol,period,ma_period);
//--- check result
   if(m_handle==INVALID_HANDLE)
      return(false);
//--- indicator successfully created
   if(!Initialize(sName,symbol,period,ma_period))
     {
      //--- initialization failed
      IndicatorRelease(m_handle);
      m_handle=INVALID_HANDLE;
      return(false);
     }
//--- ok
   return(true);
  }
bool CiATR_SLCustom::Initialize(string sName,const string symbol,const ENUM_TIMEFRAMES period,const int ma_period)
  {
     if(CiATR::Initialize(symbol,period,ma_period))
     {
      m_name  ="ATR" + "_" + sName;
      return true;
     }
     return false;

  }
double CiATR_SLCustom::Main(const int index) const
  {
   CIndicatorBuffer *buffer=At(0);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);

  }