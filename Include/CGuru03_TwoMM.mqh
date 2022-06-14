//+------------------------------------------------------------------+
//|                                                  sqlReporter.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfoCustom.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Indicators\Indicators.mqh>
 #include <Indicators\Oscilators.mqh>
 #include <Indicators\CiPosition.mqh>
#include <Indicators\CiProfit_v3stepwip.mqh>
#include <Arrays\ArrayObj.mqh>


#include <Indicators\CICustomMA_Yellow.mqh>
#include <Indicators\CICustomMA_White.mqh>
#include <Indicators\CICustomMA_Cyan.mqh>
#include <Indicators\Indicators.mqh>
#include <Indicators\CICustomMA.mqh>
#include <CGuru03_Base.mqh>
#include <MqlOutputMessageMM.mqh>
 
class CGuruEx03_TwoMM : public CGuruEx03_Base
  {
  public :                   
                     CGuruEx03_TwoMM(int slowPeriod,int mediumPeriod,int hysterisis,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange);             // Constructor
                    ~CGuruEx03_TwoMM() { Deinit(); }  // Destructor
  bool writeTrade (CArrayObj* msg);
   void              Deinit();
   bool              InitIndicators();
   bool              Init(string Pair,int slippage,double lot,int magic,bool useSLTP,CSVDebugger* _debugger);
   bool               LookForEntry_StrategyCrossOver();

   private : 

   CICustomMA_Cyan             *m_Slow;                    // Slow moving average indicator
   CICustomMA_White             *m_Medium;  
   int SlowPeriod;
   int MediumPeriod;
   int Hysteresis;
   int   magic;
   bool Checked;
   int FastPeriod;
   int ATR_MAPeriod;
int ATR_StopLossRange;
int ATR_TPRange;
 };

    bool CGuruEx03_TwoMM::writeTrade (CArrayObj* msg)
    {
   string Fast, Slow,Medium,Ravi;

   Slow = DoubleToString(m_Slow.Main(0));
   Medium = DoubleToString(m_Medium.Main(0));
   Ravi = DoubleToString(m_Profit.Main(0)); 
   string extra = Medium + ";" + Slow + ";" + Ravi;
   
    return(CGuruEx03_Base::writeTrade(msg,extra));
    }
 CGuruEx03_TwoMM::CGuruEx03_TwoMM(int slowPeriod,int mediumPeriod,int hysterisis,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange)
  {
 ATR_MAPeriod = _ATR_MAPeriod;
 ATR_TPRange = _ATR_TPRange;
ATR_StopLossRange=_ATR_StopLossRange;
ATR_TPRange = _ATR_TPRange;
  ticks = 0;

   m_Slow = NULL;
   m_Medium = NULL;
     SlowPeriod = slowPeriod;
    MediumPeriod = mediumPeriod;
   
    Hysteresis = hysterisis;
  }
   bool CGuruEx03_TwoMM::Init(string Pair,int slippage,double lot,int magic,bool useSLTP,CSVDebugger* _debugger)
   {
     if(!CGuruEx03_Base::Init(magic,Pair,slippage,lot,ATR_MAPeriod,ATR_StopLossRange,ATR_TPRange,useSLTP,_debugger))
         Print(" CGuruEx03_ThreeMM " + " unable to initiate");
     return(InitIndicators());
   }
 void CGuruEx03_TwoMM::Deinit()
{
CGuruEx03_Base::Deinit();
  
      m_Indis = NULL;    
      m_Slow = NULL;
         m_Medium = NULL;
   

   Initialized = false;
   
   Print("DeInitialized OK");
}
bool CGuruEx03_TwoMM::InitIndicators()
  {



// Create slow MA and add it to collection
   if (m_Slow == NULL) {
      if ((m_Slow = new CICustomMA_Cyan ) == NULL) {
         Print("Error creating slow MA");
         return(false);
      } 
   }
   if (!m_Slow.Create(m_Pair, 0, SlowPeriod, 0)) {   
      Print("Error initializing slow MA");
      return(false);
   }
  // m_Slow.BuffSize(1);
   if (!m_Indis.Add(m_Slow)) {
      Print("Error adding slow MA to indicator collection");
      return(false);
   }
   if (m_Medium == NULL) {
      if ((m_Medium = new CICustomMA_White ) == NULL) {
         Print("Error creating slow MA");
         return(false);
      }
   }
   if (!m_Medium.Create(m_Pair, 0, MediumPeriod, 0)) {   
      Print("Error initializing medium MA");
      return(false);
   }
  // m_Slow.BuffSize(1);
   if (!m_Indis.Add(m_Medium)) {
      Print("Error adding slow MA to indicator collection");
      return(false);
   }
    return true;
 }

 bool CGuruEx03_TwoMM::LookForEntry_StrategyCrossOver()
    {   
    CArrayObj* res = new CArrayObj();
    m_Indis.Refresh();
   
   double Slow_MA = m_Slow.Main(0);
  double Medium_MA = m_Medium.Main(0);
  
      double Fast, Slow,Medium;

   if(!m_Symbol.RefreshRates())
      return false;
      

   if (!Checked) {
      Checked = true;
      if (Fast > Medium > Slow)
         Long = true;
      else   
         Long = false;
   }
   double hysteresis = Hysteresis * Points;
   bool buy_signal =   !Long && (Medium_MA > (Slow_MA + hysteresis));
   bool sell_signal =   Long && (Medium_MA < (Slow_MA - hysteresis));
 //  buy_signal = true;
   return(CGuruEx03_Base::CheckEntry(buy_signal,sell_signal));



   } 
    