//+------------------------------------------------------------------+
//|                                    StrategyBase_Instanciable.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <CStrategy_Base.mqh>
#include <Indicators\CICustomMA.mqh>
#include <Indicators\CICustomMA_Yellow.mqh>
#include <Indicators\CICustomMA_Cyan.mqh>
#include <Indicators\CICustomMA_White.mqh>
#include <Indicators\CiMA_Enhanced.mqh>
class CStrategy_TwoMM_Base : public CStrategy_Base
  {
private:

   int               ATR_MAPeriod;
   int               ATR_StopLossRange;
   int               ATR_TPRange;

   bool              isLong();

   double            swap_rate;
protected:
   CIndicator_Enhanced          *m_Slow;                    // Slow moving average indicator
   CIndicator_Enhanced   *m_Fast;
   int               FastPeriod;
   int               SlowPeriod;
   enMaTypes         SlowMethod;
   enMaTypes         FastMethod;
public:
                     CStrategy_TwoMM_Base(enMaTypes MAMethod,int slowPeriod,int fastPeriod,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange)   ;
   bool              LookForEntry_StrategyCrossOver();
                    ~CStrategy_TwoMM_Base();
   bool              Init(string sPair,int slippage,double lot,int magic,bool useSLTP,CSVDebugger* _debugger,CArrayString& swap_rates[],CArrayString& commissions_calibrations[]);
   bool              InitIndicators();
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStrategy_TwoMM_Base::InitIndicators(void)
  {
// Create fast MA and add it to collection
   if(m_Fast == NULL)
     {

      if((m_Fast = new CiMA_Enhanced(1)) == NULL)
        {
         Print("CStrategy_TwoMM_NoFixed_Hysteresis CiMA_Enhanced Error creating fast MA");
         return(false);
        }

     }

   CMqlParams* params = new CMqlParams;
   if(!m_Fast.Create(m_Pair, 0, this.FastPeriod,0, (ENUM_MA_METHOD)FastMethod, PRICE_CLOSE,params))
     {
      Print("CStrategy_TwoMM_Base::Error initializing fast MA");
      return(false);
     }

   if(!m_Indis.Add(m_Fast))
     {
      Print("CStrategy_TwoMM_Base::Error adding fast MA to indicator collection");
      return(false);
     }


   if(m_Slow == NULL)
     {

      if((m_Slow = new CiMA_Enhanced(1)) == NULL)
        {
         Print("CStrategy_TwoMM_NoFixed_Hysteresis CiMA_Enhanced Error creating fast MA");
         return(false);
        }

     }
   params = new CMqlParams;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!m_Slow.Create(m_Pair, 0, this.SlowPeriod,0, (ENUM_MA_METHOD)SlowMethod, PRICE_CLOSE,params))
     {
      Print("Error initializing slow MA");
      return(false);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   if(!m_Indis.Add(m_Slow))
     {
      Print("Error adding slow MA to indicator collection");
      return(false);
     }


   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStrategy_TwoMM_Base::CStrategy_TwoMM_Base(enMaTypes _MAMethod,int slowPeriod,int fastPeriod,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange)  : CStrategy_Base()        // Constructor
  {
   ATR_MAPeriod = _ATR_MAPeriod;
   ATR_TPRange = _ATR_TPRange;
   ATR_StopLossRange=_ATR_StopLossRange;
   ATR_TPRange = _ATR_TPRange;
   ticks = 0;
   swap_rate = 0;
   m_Slow = NULL;
   m_Fast = NULL;
   SlowPeriod = slowPeriod;
   FastPeriod = fastPeriod;

   SlowMethod = _MAMethod;
   FastMethod = _MAMethod;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStrategy_TwoMM_Base::~CStrategy_TwoMM_Base()
  {
  }
//+------------------------------------------------------------------+
bool CStrategy_TwoMM_Base::Init(string sPair,int slippage,double lot,int magic,bool useSLTP,CSVDebugger* _debugger,CArrayString& swap_rates[],CArrayString& commissions_calibrations[])
  {

   if(!CStrategy_Base::Init(sPair,magic,slippage,lot,useSLTP,_debugger,swap_rates,commissions_calibrations))
     {
      Print(" CStrategy_TwoMM_Base " + " unable to initiate");
      return false;
     }
   return(InitIndicators());
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStrategy_TwoMM_Base::LookForEntry_StrategyCrossOver()
  {

   if(!this.m_Symbol.hasNewBar())
      return true;

   if(!m_Symbol.RefreshRates())
      return false;
   m_Indis.Refresh();

   double Slow_MA = m_Slow.GetData(0,0);
   double fast_MA = m_Fast.GetData(0,0);

   string msg = "";

   bool buy_signal =   !Long && (fast_MA >= (Slow_MA));
   bool sell_signal =   !Short && (fast_MA <= (Slow_MA));

   if((Slow_MA > 10000000)|| (fast_MA>10000000))
     {
      Print("Undefined MA For Symbol " + this.m_Symbol.Name());
      return true;
     }

   if(buy_signal || sell_signal)
     {
      int nDigits =this.m_Symbol.getNDigitsFormat();
      msg = DoubleToString((Slow_MA),nDigits) + "_" + DoubleToString((fast_MA),nDigits);
     }

   bool res = CStrategy_Base::CheckEntry(buy_signal,sell_signal,msg);

   return(res);
  }
//+------------------------------------------------------------------+
