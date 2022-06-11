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
color InpColorFast = clrBlue;     
color InpColorSlow = clrGreen;  
class CGuruEx03_ThreeMM : public CGuruEx03_Base
  {
  public :                   
                     CGuruEx03_ThreeMM(int slowPeriod,int mediumPeriod,int intFastPeriod,int hysterisis,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange);             // Constructor
                    ~CGuruEx03_ThreeMM() { Deinit(); }  // Destructor
  bool writeTrade (CArrayObj* msg);
   void              Deinit();
   bool              InitIndicators();
   bool              Init(string Pair,int slippage,double lot,int magic,bool useSLTP,CSVDebugger* _debugger);
   bool               LookForEntry_StrategyCrossOver();

   private : 
   CICustomMA_Yellow             *m_Fast;                    // Fast moving average indicator
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

    bool CGuruEx03_ThreeMM::writeTrade (CArrayObj* msg)
    {
   string Fast, Slow,Medium,Ravi;
   Fast = DoubleToString(m_Fast.Main(0));
   Slow = DoubleToString(m_Slow.Main(0));
   Medium = DoubleToString(m_Medium.Main(0));
   Ravi = DoubleToString(m_Profit.Main(0)); 
   string extra = Fast + ";" + Medium + ";" + Slow + ";" + Ravi;
   
    return(CGuruEx03_Base::writeTrade(msg,extra));
    }
 CGuruEx03_ThreeMM::CGuruEx03_ThreeMM(int slowPeriod,int mediumPeriod,int intFastPeriod,int hysterisis,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange)
  {
 ATR_MAPeriod = _ATR_MAPeriod;
 ATR_TPRange = _ATR_TPRange;
ATR_StopLossRange=_ATR_StopLossRange;
ATR_TPRange = _ATR_TPRange;
  ticks = 0;
 m_Fast = NULL;
   m_Slow = NULL;
   m_Medium = NULL;
     SlowPeriod = slowPeriod;
    MediumPeriod = mediumPeriod;
    FastPeriod = intFastPeriod;
    Hysteresis = hysterisis;
  }
   bool CGuruEx03_ThreeMM::Init(string Pair,int slippage,double lot,int magic,bool useSLTP,CSVDebugger* _debugger)
   {
     if(!CGuruEx03_Base::Init(magic,Pair,slippage,lot,ATR_MAPeriod,ATR_StopLossRange,ATR_TPRange,useSLTP,_debugger))
         Print(" CGuruEx03_ThreeMM " + " unable to initiate");
     return(InitIndicators());
   }
 void CGuruEx03_ThreeMM::Deinit()
{
CGuruEx03_Base::Deinit();
      m_Fast = NULL;
      m_Indis = NULL;    
      m_Slow = NULL;
         m_Medium = NULL;
   

   Initialized = false;
   
   Print("DeInitialized OK");
}
bool CGuruEx03_ThreeMM::InitIndicators()
  {

// Create fast MA and add it to collection
   if (m_Fast == NULL) {
      if ((m_Fast = new CICustomMA_Yellow) == NULL) {
         Print("Error creating fast MA");
         return(false);
      }
   }
   if (!m_Fast.Create(m_Pair, 0, FastPeriod, 0)) {   
      Print("Error initializing fast MA");
      return(false);
   }
 //  m_Fast.BuffSize(1);
   if (!m_Indis.Add(m_Fast)) {
      Print("Error adding fast MA to indicator collection");
      return(false);
   }

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

 bool CGuruEx03_ThreeMM::LookForEntry_StrategyCrossOver()
    {   
    CArrayObj* res = new CArrayObj();
    m_Indis.Refresh();
  double Fast_MA = m_Fast.Main(0);
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
   bool buy_signal =   !Long && (Fast_MA > (Medium_MA + hysteresis))&& (Medium_MA > (Slow_MA + hysteresis));
   bool sell_signal =   Long && (Fast_MA < (Medium_MA - hysteresis))&& (Medium_MA < (Slow_MA - hysteresis));
 //  buy_signal = true;
   return(CGuruEx03_Base::CheckEntry(buy_signal,sell_signal));



   } 
    