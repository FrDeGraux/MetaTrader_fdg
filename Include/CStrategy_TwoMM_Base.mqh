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
#include <Indicators\CiMA_Enhanced.mqh>
class CStrategy_TwoMM_Base : public CStrategy_Base
  {
private:

   int               ATR_MAPeriod;
   int               ATR_StopLossRange;
   int               ATR_TPRange;

   bool              isLong();
  
   
protected:
   CIndicator_Enhanced          *m_Slow;                    // Slow moving average indicator
   CIndicator_Enhanced   *m_Fast;
      int               FastPeriod;
         int               SlowPeriod;
            enMaTypes         SlowMethod;
   enMaTypes         FastMethod; 
public:
                     CStrategy_TwoMM_Base(enMaTypes MAMethod,int slowPeriod,int fastPeriod,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange)   ;
                     bool LookForEntry_StrategyCrossOver();
                    ~CStrategy_TwoMM_Base();
                      bool              Init(string Pair,int slippage,double lot,int magic,bool useSLTP,CSVDebugger* _debugger,CArrayString& swap_rates[]);
                      bool              InitIndicators();
  };
  
bool CStrategy_TwoMM_Base::InitIndicators(void)
{
// Create fast MA and add it to collection
   if(m_Fast == NULL)
     {

         if((m_Fast = new CiMA_Enhanced(1)) == NULL)
           {
            Print("CStrategy_TwoMM_Base CiMA_Enhanced Error creating fast MA");
            return(false);
           }
        
     }

CMqlParams params;
   if(!m_Fast.Create(m_Pair, 0, this.FastPeriod,0,  (ENUM_MA_METHOD)FastMethod, PRICE_CLOSE,params))
     {
      Print("CStrategy_TwoMM_NoFixed_Hysteresis::Error initializing fast MA");
      return(false);
     }





   if(!m_Indis.Add(m_Fast))
     {
      Print("CStrategy_TwoMM_NoFixed_Hysteresis::Error adding fast MA to indicator collection");
      return(false);
     }


   if(m_Slow == NULL)
     {


      if((m_Slow = new CiMA_Enhanced(1)) == NULL)
        {
         Print("Error creating m_Slow MA");
         return(false);
        }
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!m_Slow.Create(m_Pair, 0, this.SlowPeriod,0,  (ENUM_MA_METHOD)SlowMethod, PRICE_CLOSE,params))
     {
      Print("Error initializing slow MA");
      return(false);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   m_Slow.BufferResize(1);
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
CStrategy_TwoMM_Base::CStrategy_TwoMM_Base(enMaTypes _MAMethod,int slowPeriod,int fastPeriod,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange)           // Constructor
  {
    ATR_MAPeriod = _ATR_MAPeriod;
   ATR_TPRange = _ATR_TPRange;
   ATR_StopLossRange=_ATR_StopLossRange;
   ATR_TPRange = _ATR_TPRange;
   ticks = 0;

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
  bool CStrategy_TwoMM_Base::Init(string Pair,int slippage,double lot,int magic,bool useSLTP,CSVDebugger* _debugger,CArrayString& swap_rates[])
  {

   if(!CStrategy_Base::Init(magic,Pair,slippage,lot,useSLTP,_debugger,swap_rates))
      Print(" CGuruEx03_ThreeMM " + " unable to initiate");
   return(InitIndicators());
  }
  
  bool CStrategy_TwoMM_Base::LookForEntry_StrategyCrossOver()
  {

   
   if(!m_Symbol.RefreshRates())
      return false;
   m_Indis.Refresh();



    double  Slow_MA = m_Slow.GetData(0,0);
   double fast_MA = m_Fast.GetData(0,0);


   string msg = "";

   bool buy_signal =   !Long && (fast_MA >= (Slow_MA));
   bool sell_signal =   !Short && (fast_MA <= (Slow_MA));







   if(buy_signal || sell_signal)
     {
      int nDigits = 5;
      if(StringFind(this.m_Symbol.Name(),"JPY") > -1)
         nDigits = 3;
      msg = DoubleToString((Slow_MA),nDigits) + "_" + DoubleToString((fast_MA),nDigits)+ "_" + "0";
     }

   
   return(CStrategy_Base::CheckEntry(buy_signal,sell_signal,msg));
    }