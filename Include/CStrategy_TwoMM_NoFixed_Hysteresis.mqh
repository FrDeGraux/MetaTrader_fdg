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
#include <Generic\Queue.mqh> 


#include <DealsRequester.mqh>

#include <Indicators\CICustomMA_Yellow.mqh>
#include <Indicators\CICustomMA_White.mqh>
#include <Indicators\CICustomMA_Cyan.mqh>
#include <Indicators\Indicators.mqh>
#include <Indicators\CICustomMA.mqh>

#include <Indicators\CICustomMA_Yellow_Hysteresis.mqh>

#include <Indicators\CiMA_Enhanced.mqh>

#include <UtilChart.mqh>
#include <CStrategy_TwoMM_Base.mqh>
    


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStrategy_TwoMM_NoFixed_Hysteresis : public  CStrategy_TwoMM_Base
  {
public :
                     CStrategy_TwoMM_NoFixed_Hysteresis(enMaTypes _MAType,int slowPeriod,int fastPeriod,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange,int _HysteresisMaxBackWardUse);
   void              Deinit();
   bool              InitIndicators();

   bool               LookForEntry_StrategyCrossOver();
   bool               LookForEntry_StrategyCrossOver_old();
   void               removeFromQueue();
   void               addToQueue();
   bool              Init(string Pair,int slippage,double lot,int magic,bool useSLTP,CSVDebugger* _debugger,CArrayString& swap_rates[]);
protected :

   int               HysteresisMaxBackWardUse;


   int               magic;
   bool              Checked;
   double            getHysteresis_WIP();
   double            getHysteresis();

 private : 
  CQueue<double>* queue_MA_wedge;  
  double MA_wedge_max;

  };
void CStrategy_TwoMM_NoFixed_Hysteresis::removeFromQueue()
{
// called on newBar()
   if (this.queue_MA_wedge.Count() <= HysteresisMaxBackWardUse)
      return;
      
    double toRemove = this.queue_MA_wedge.Dequeue();
    if (toRemove >= MA_wedge_max)
    {
    double tab[];
    ArrayResize(tab,toRemove);
    this.queue_MA_wedge.CopyTo(tab);
    this.MA_wedge_max = tab[ArrayMaximum(tab)];
    }
}
void CStrategy_TwoMM_NoFixed_Hysteresis::addToQueue()
{
double toAdd = MathAbs(m_Slow.GetData(0,1)-m_Fast.GetData(0,1));

 this.queue_MA_wedge.Add(toAdd);
 if(toAdd > this.MA_wedge_max)
   this.MA_wedge_max = toAdd;
 
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CStrategy_TwoMM_NoFixed_Hysteresis::getHysteresis_WIP()
  {
   double Slow_MA;
   if(UtilTerminal::useCiCustomMA_Yellow_Hysteresis())
      return(MathAbs(m_Fast.GetData(1,0)-m_Fast.GetData(0,0)));
   else
      Slow_MA = m_Slow.GetData(0,0);


   double lastVal = MathAbs(m_Slow.GetData(0,0)-m_Fast.GetData(0,0));
   if(lastVal > this.MA_wedge_max)
      return lastVal;
   else
    return this.MA_wedge_max;
 


//  return 10*Point();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CStrategy_TwoMM_NoFixed_Hysteresis::getHysteresis()
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
CStrategy_TwoMM_NoFixed_Hysteresis::CStrategy_TwoMM_NoFixed_Hysteresis(enMaTypes _MAType,int slowPeriod,int fastPeriod,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange,int _HysteresisMaxBackWardUse) : CStrategy_TwoMM_Base(_MAType,slowPeriod,fastPeriod,_ATR_MAPeriod,_ATR_StopLossRange,_ATR_TPRange)
  {
  MA_wedge_max = 0;
  
   HysteresisMaxBackWardUse = _HysteresisMaxBackWardUse;
    this.queue_MA_wedge = new CQueue<double>();  

// extra spread inputed

   if((HysteresisMaxBackWardUse < 0))
      Alert("CStrategy_TwoMM_NoFixed_Hysteresis init problem");


  }
  
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CStrategy_TwoMM_NoFixed_Hysteresis::Deinit()
  {
   CStrategy_Base::Deinit();

   m_Indis = NULL;
   m_Slow = NULL;
   m_Fast = NULL;


   Initialized = false;

   Print("DeInitialized OK");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

	bool CStrategy_TwoMM_NoFixed_Hysteresis::Init(string Pair,int slippage,double lot,int magic,bool useSLTP,CSVDebugger* _debugger,CArrayString& swap_rates[])
  {
   if(!CStrategy_TwoMM_Base::Init(magic,Pair,slippage,lot,useSLTP,_debugger,swap_rates))
      Print(" CGuruEx03_ThreeMM " + " unable to initiate");
   return(InitIndicators());
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStrategy_TwoMM_NoFixed_Hysteresis::InitIndicators()
  {
// Create fast MA and add it to collection
   if(m_Fast == NULL)
     {
      if(UtilTerminal::useCiCustomMA_Yellow_Hysteresis())
        {
         if((m_Fast = new CiCustomMA_Yellow_Hysteresis(HysteresisMaxBackWardUse,SlowPeriod)) == NULL)
           {
            Print("CStrategy_TwoMM_NoFixed_Hysteresis CICustomMA_Yellow Error creating fast MA");
            return(false);
           }
        }
      else
        {
         if((m_Fast = new CiMA_Enhanced(1)) == NULL)
           {
            Print("CStrategy_TwoMM_NoFixed_Hysteresis CiMA_Enhanced Error creating fast MA");
            return(false);
           }
        }
     }

   CMqlParams params;
   if(!m_Fast.Create(m_Pair, 0, this.FastPeriod,0,   (ENUM_MA_METHOD) FastMethod, PRICE_CLOSE,params))
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
      if(UtilTerminal::useCiCustomMA_Yellow_Hysteresis())
         return true; // slow already included in fast

      if((m_Slow = new CiMA_Enhanced(1)) == NULL)
        {
         Print("Error creating m_Slow MA");
         return(false);
        }
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!m_Slow.Create(m_Pair, 0, SlowPeriod,0,   (ENUM_MA_METHOD) SlowMethod, PRICE_CLOSE,params))
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
bool CStrategy_TwoMM_NoFixed_Hysteresis::LookForEntry_StrategyCrossOver()
  {
  if(!UtilTerminal::isViewerMode())
  {
   if (this.m_Symbol.hasNewBar())
   {
      this.removeFromQueue();
      this.addToQueue();
     
    } 
  }
 
   if(!m_Symbol.RefreshRates())
      return false;
   m_Indis.Refresh();

   double Slow_MA;
   if(UtilTerminal::useCiCustomMA_Yellow_Hysteresis())
      Slow_MA = m_Fast.GetData(3,0); // Slow_MA is included in the CiCustomMA_Yellow_Hysteresis
   else
      Slow_MA = m_Slow.GetData(0,0);
   double fast_MA = m_Fast.GetData(0,0);

   double hysteresis = 0;

   string msg = "";

   bool pre_buy_signal =   !Long && (fast_MA >= (Slow_MA));
   bool pre_sell_signal =   !Short && (fast_MA <= (Slow_MA));

   bool buy_signal = false;
   bool sell_signal = false;
   if(pre_buy_signal || pre_sell_signal)
      hysteresis = getHysteresis();


   if(pre_buy_signal)
      buy_signal =   !Long && (fast_MA >= (Slow_MA + hysteresis)); // if we are not already long
   if(pre_sell_signal)
      sell_signal =   !Short && (fast_MA + hysteresis <= (Slow_MA)); // if we ar not alreafy shorrt
   if(buy_signal || sell_signal)
     {
     int nDigits = 5;
     if(StringFind(this.m_Symbol.Name(),"JPY") > -1)
         nDigits = 3; 
      msg = DoubleToString((Slow_MA),nDigits) + "_" + DoubleToString((fast_MA),nDigits)+ "_" + DoubleToString((double)(hysteresis)/this.m_Symbol.getPointSize(),1);

     }
     

   return(CStrategy_Base::CheckEntry(buy_signal,sell_signal,msg));






  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
