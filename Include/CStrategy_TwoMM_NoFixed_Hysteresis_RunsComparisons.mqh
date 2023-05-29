//+------------------------------------------------------------------+
//|            Strategy_TwoMM_NoFixed_Hysteresis_RunsComparisons.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                  sqlReporter.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfoCustom.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Indicators\Indicators.mqh>
#include <Indicators\Indicator_Enhanced.mqh>
#include <Indicators\Oscilators.mqh>
#include <Indicators\CiPosition.mqh>
#include <Arrays\ArrayObj.mqh>


#include <DealsRequester.mqh>

#include <Indicators\CICustomMA_Yellow.mqh>
#include <Indicators\CICustomMA_White.mqh>
#include <Indicators\CICustomMA_Cyan.mqh>
#include <Indicators\Indicators.mqh>
#include <Indicators\CICustomMA.mqh>

#include <Indicators\CICustomMA_Yellow_NoFixedHysteresis.mqh>

#include <Indicators\CiMA_Enhanced.mqh>

#include <UtilChart.mqh>
#include <CStrategy_BaseCustomProfitComparison.mqh>




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStrategy_TwoMM_NoFixed_Hysteresis_RunsComparisons : public  CStrategy_BaseCustomProfitComparison
  {
public :
                     CStrategy_TwoMM_NoFixed_Hysteresis_RunsComparisons(enMaTypes _MA,int slowPeriod,int mediumPeriod,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange,int _HysteresisMaxBackWardUse);             // Constructor
                    ~CStrategy_TwoMM_NoFixed_Hysteresis_RunsComparisons() { Deinit(); }  // Destructor

   void              Deinit();
   bool              InitIndicators();
   bool              Init(string Pair,int slippage,double lot,int magic,bool useSLTP,CSVDebugger* _debugger,CArrayString& swap_rates[],CArrayString& commissions_calibrations[],CArrayString& positions[]);
   bool               LookForEntry_StrategyCrossOver();
   bool               LookForEntry_StrategyCrossOver_old();
   bool              checkForExit(bool long_exit,bool short_exit,string msg);
protected :

   int               HysteresisMaxBackWardUse;
   CIndicator_Enhanced          *m_Slow;                    // Slow moving average indicator
   CIndicator_Enhanced   *m_Fast;
   int               SlowPeriod;
   int               i_FastPeriod;
   int               magic;
   bool              Checked;
   int               FastPeriod;
   int               ATR_MAPeriod;
   int               ATR_StopLossRange;
   int               ATR_TPRange;
   bool              isLong();
   double            getHysteresis();
   enMaTypes         SlowMethod;

   enMaTypes         FastMethod;
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  CStrategy_TwoMM_NoFixed_Hysteresis_RunsComparisons::checkForExit(bool long_exit,bool short_exit,string msg)
  {
   if(!m_Symbol.RefreshRates())
      return (false);

   this.setIndicatorsValue();
   double sl = 0;
   double tp = 0;
   if(long_exit)
     {

      if(OrderNumber > 0) // does an active position exist ?
        {
         if(!m_Trade.PositionCloseEnhanced(ULONG_MAX,ORDER_TYPE_BUY,msg))
            return false;
         Short = false;
         Long = false;
         OrderNumber = 0;
         Print(" Used Memory is " + IntegerToString(MQLInfoInteger(MQL_MEMORY_USED)));
         Print(" Max Memory is " + IntegerToString(MQLInfoInteger(MQL_MEMORY_LIMIT)));
        }
        return false;
     }

   else
      if(short_exit)
        {

         if(OrderNumber > 0) // does an active position exist ?
           {
            if(!m_Trade.PositionCloseEnhanced(ULONG_MAX,ORDER_TYPE_SELL,msg))
               return false;
            Short = false;
            Long = false;
            OrderNumber = 0;
            Print(" Used Memory is " + IntegerToString(MQLInfoInteger(MQL_MEMORY_USED)));
            Print(" Max Memory is " + IntegerToString(MQLInfoInteger(MQL_MEMORY_LIMIT)));
           }
           return false;
        }
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CStrategy_TwoMM_NoFixed_Hysteresis_RunsComparisons::getHysteresis()
  {
   double Slow_MA;
   if(UtilTerminal::useCiCustomMA_Yellow_Hysteresis())
      return(MathAbs(m_Fast.GetData(1,0)-m_Fast.GetData(0,0)));
   else
      Slow_MA = m_Slow.GetData(0,0);

   double slow_MA_latest[];
   double fast_MA_latest[];
   double gap_slow_fast_ma[];
   ArrayResize(slow_MA_latest,HysteresisMaxBackWardUse-1);
   ArrayResize(gap_slow_fast_ma,HysteresisMaxBackWardUse-1);
   ArrayResize(fast_MA_latest,HysteresisMaxBackWardUse-1);
   double toFill;
   for(int i=0; i<HysteresisMaxBackWardUse-1 ; i++)
     {
      slow_MA_latest[i] =  m_Slow.GetData(0,i);
      fast_MA_latest[i] =  m_Fast.GetData(0,i);
      toFill = MathAbs(slow_MA_latest[i]-fast_MA_latest[i]);
      ArrayFill(gap_slow_fast_ma,i,1,toFill);
     }
   double max = gap_slow_fast_ma[ArrayMaximum(gap_slow_fast_ma)];
   return max;


   return max;

//  return 10*Point();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStrategy_TwoMM_NoFixed_Hysteresis_RunsComparisons::CStrategy_TwoMM_NoFixed_Hysteresis_RunsComparisons(enMaTypes _MA,int slowPeriod,int fastPeriod,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange,int _HysteresisMaxBackWardUse)
  {


   HysteresisMaxBackWardUse = _HysteresisMaxBackWardUse;
// extra spread inputed

   if((HysteresisMaxBackWardUse < 0))
      Alert("CStrategy_TwoMM_NoFixed_Hysteresis_RunsComparisons init problem");
   ATR_MAPeriod = _ATR_MAPeriod;
   ATR_TPRange = _ATR_TPRange;
   ATR_StopLossRange=_ATR_StopLossRange;
   ATR_TPRange = _ATR_TPRange;
   ticks = 0;

   m_Slow = NULL;
   m_Fast = NULL;
   SlowPeriod = slowPeriod;
   i_FastPeriod = fastPeriod;

   SlowMethod = _MA;
   FastMethod = _MA;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStrategy_TwoMM_NoFixed_Hysteresis_RunsComparisons::Init(string sPair,int slippage,double lot,int magic,bool useSLTP,CSVDebugger* _debugger,CArrayString& swap_rates[],CArrayString& commissions_calibrations[],CArrayString& positions[])
  {

   if(!CStrategy_BaseCustomProfitComparison::Init(sPair,magic,slippage,lot,useSLTP,_debugger,swap_rates,commissions_calibrations,positions))
     {
      Print(" CStrategy_TwoMM_NoFixed_Hysteresis_RunsComparisons:: " + " unable to initiate");
      return false;
     }
   return(InitIndicators());
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CStrategy_TwoMM_NoFixed_Hysteresis_RunsComparisons::Deinit()
  {
   CStrategy_BaseCustomProfitComparison::Deinit();

   m_Indis = NULL;
   m_Slow = NULL;
   m_Fast = NULL;


   Initialized = false;

   Print("DeInitialized OK");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStrategy_TwoMM_NoFixed_Hysteresis_RunsComparisons::InitIndicators()
  {



// Create fast MA and add it to collection
   if(m_Fast == NULL)
     {
      if(UtilTerminal::useCiCustomMA_Yellow_Hysteresis())
        {
         if((m_Fast = new CICustomMA_Yellow_NoFixedHysteresis(HysteresisMaxBackWardUse,SlowPeriod)) == NULL)
           {
            Print("CStrategy_TwoMM_NoFixed_Hysteresis_RunsComparisons CICustomMA_Yellow Error creating fast MA");
            return(false);
           }
        }
      else
        {
         if((m_Fast = new CiMA_Enhanced(HysteresisMaxBackWardUse)) == NULL)
           {
            Print("CStrategy_TwoMM_NoFixed_Hysteresis_RunsComparisons CiMA_Enhanced Error creating fast MA");
            return(false);
           }
        }
     }

   CMqlParams params;
   if(!m_Fast.Create(m_Pair, 0, i_FastPeriod,0, (ENUM_MA_METHOD)FastMethod, PRICE_CLOSE,params))
     {
      Print("CStrategy_TwoMM_NoFixed_Hysteresis_RunsComparisons::Error initializing fast MA");
      return(false);
     }





   if(!m_Indis.Add(m_Fast))
     {
      Print("CStrategy_TwoMM_NoFixed_Hysteresis_RunsComparisons::Error adding fast MA to indicator collection");
      return(false);
     }


   if(m_Slow == NULL)
     {
      if(UtilTerminal::useCiCustomMA_Yellow_Hysteresis())
         return true;

      if((m_Slow = new CiMA_Enhanced(HysteresisMaxBackWardUse)) == NULL)
        {
         Print("Error creating m_Slow MA");
         return(false);
        }
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!m_Slow.Create(m_Pair, 0, SlowPeriod,0, (ENUM_MA_METHOD) SlowMethod, PRICE_CLOSE,params))
     {
      Print("Error initializing slow MA");
      return(false);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   m_Slow.BufferResize(HysteresisMaxBackWardUse);
   if(!m_Indis.Add(m_Slow))
     {
      Print("Error adding slow MA to indicator collection");
      return(false);
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   return (true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStrategy_TwoMM_NoFixed_Hysteresis_RunsComparisons::LookForEntry_StrategyCrossOver()
  {

   if(!m_Symbol.RefreshRates())
      return false;
   m_Indis.Refresh();
   bool enter_long_signal = false;
   bool enter_short_signal  = false;
   
   double Slow_MA;
   if(UtilTerminal::useCiCustomMA_Yellow_Hysteresis())
      Slow_MA = m_Fast.GetData(3,0); // Slow_MA is included in the CiCustomMA_Yellow_Hysteresis
   else
      Slow_MA = m_Slow.GetData(0,0);

   double fast_MA = m_Fast.GetData(0,0);

   double hysteresis = 0;

   string msg = "";

   bool exit_short_signal =   !Long && (fast_MA >= (Slow_MA));
   bool exit_long_signal =   !Short && (fast_MA <= (Slow_MA));


   if(exit_short_signal || exit_long_signal)
      hysteresis = getHysteresis();


   if(exit_short_signal)
      enter_long_signal =   !Long && (fast_MA >= (Slow_MA + hysteresis)); // if we are not already long
   if(exit_long_signal)
      enter_short_signal =   !Short && (fast_MA + hysteresis <= (Slow_MA)); // if we ar not alreafy shorrt
   if(exit_short_signal || exit_long_signal)
     {
      int nDigits =this.m_Symbol.getNDigitsFormat();
      msg = DoubleToString((Slow_MA),nDigits) + "_" + DoubleToString((fast_MA),nDigits)+ "_" + DoubleToString((double)(hysteresis)/this.m_Symbol.getPointSize(),1);

     }

   bool bCheckExit = checkForExit(exit_long_signal,exit_short_signal,msg);
   if (bCheckExit == true)
      return bCheckExit;
      
   return(CStrategy_BaseCustomProfitComparison::CheckEntry(enter_long_signal,enter_short_signal,msg));






  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

