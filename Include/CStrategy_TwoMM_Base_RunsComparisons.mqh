//+------------------------------------------------------------------+
//|                                    StrategyBase_Instanciable.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <CStrategy_TwoMM_Base.mqh>
#include <Indicators\CICustomMA.mqh>
#include <Indicators\CICustomMA_Yellow.mqh>
#include <Indicators\CICustomMA_Cyan.mqh>
#include <Indicators\CICustomMA_White.mqh>
#include <Indicators\CiMA_Enhanced.mqh>
//+------------------------------------------------------------------+
//|                          Strategy_BaseCustomProfitComparison.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <CStrategy_TwoMM_Base.mqh>
#include <Trade\SymbolInfoCustomProfitComparison.mqh> 
class CStrategy_TwoMM_Base_RunsComparisons : public CStrategy_TwoMM_Base
  {
private:
   CiProfit            *m_EquityProfitComparison;
   CiPosition             *m_PositionsProfitComparison;
      void              setProfitComparisonIndicatorsValues();
   CArrayString* positions;
public:
                     CStrategy_TwoMM_Base_RunsComparisons(enMaTypes _MAMethod,int slowPeriod,int fastPeriod,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange);
                    ~CStrategy_TwoMM_Base_RunsComparisons();
   bool              Init(string Pair,int _magicNumber,int slippage,double lot,bool _useStopTP,CSVDebugger* _debugger,CArrayString& swap_rates[],CArrayString& commissions_calibrations[]);
   bool              InitIndicators();
   bool              InitPositions(CArrayString& positions[]);
   void setIndicatorsValue();

  };
  void CStrategy_TwoMM_Base_RunsComparisons::setIndicatorsValue()
  {

   this.setProfitComparisonIndicatorsValues();
   CStrategy_TwoMM_Base::setIndicatorsValue();

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStrategy_TwoMM_Base_RunsComparisons::Init(string Pair,int _magicNumber,int slippage,double lot,bool _useStopTP,CSVDebugger* _debugger,CArrayString& swap_rates[],CArrayString& commissions_calibrations[])
  {
   m_Symbol = new CSymbolInfoCustomProfitComparison(Pair);
   CSymbolInfoCustomProfitComparison *m_SymbolProfitComparison = dynamic_cast<CSymbolInfoCustomProfitComparison *>(m_Symbol);

   if(!m_SymbolProfitComparison.init(swap_rates,commissions_calibrations))
      return false;
  
   if(!CStrategy_TwoMM_Base::Init(Pair, _magicNumber, slippage, lot, _useStopTP,_debugger,swap_rates,commissions_calibrations))
      return false;
      return(InitIndicators());

  }
  bool CStrategy_TwoMM_Base_RunsComparisons::InitPositions(CArrayString& positions[])
  {
     CSymbolInfoCustomProfitComparison *m_SymbolProfitComparison = dynamic_cast<CSymbolInfoCustomProfitComparison *>(m_Symbol);

      if(!m_SymbolProfitComparison.initPositions(positions_to_compare_against)
      return false;   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStrategy_TwoMM_Base_RunsComparisons::~CStrategy_TwoMM_Base_RunsComparisons()
  {
  }
//+------------------------------------------------------------------+
void CStrategy_TwoMM_Base_RunsComparisons::setProfitComparisonIndicatorsValues()
  {
   CSymbolInfoCustomProfitComparison *m_SymbolProfitComparison = dynamic_cast<CSymbolInfoCustomProfitComparison *>(m_Symbol);
   if(UtilTerminal::displayEquity())
     {

      double equityProfitComparison = m_SymbolProfitComparison.computeProfitComparisonEquity();
      double positioningProfitComparison = m_SymbolProfitComparison.computeProfitComparisonPositioning();

      string sEquityVarName = m_SymbolProfitComparison.Name() + "_equityComparisonsRuns";

      string sPositioningVarName = m_SymbolProfitComparison.Name() + "_netPositioningComparisonsRuns";

      GlobalVariableSet(sEquityVarName,equityProfitComparison);

      GlobalVariableSet(sPositioningVarName,positioningProfitComparison);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStrategy_TwoMM_Base_RunsComparisons::InitIndicators()
  {

   if(UtilTerminal::displayEquity())
     {
      if(m_EquityProfitComparison == NULL)
        {
         if((m_EquityProfitComparison = new CiProfit("EquityIndicatorRunsComparisons",2)) == NULL)
           {
            Print("CStrategy_TwoMM_Base_RunsComparisons::Error creating EquityIndicatorRunsComparisons");
            return(false);
           }
        }
      if(!m_EquityProfitComparison.Create(m_Pair, 0))
        {
         Print("CStrategy_TwoMM_Base_RunsComparisons::Error initializing EquityIndicatorRunsComparisons");
         return(false);
        }

      if(!m_Indis.Add(m_EquityProfitComparison))
        {
         Print("CStrategy_TwoMM_Base_RunsComparisons::Error adding Profit to indicator EquityIndicatorRunsComparisons");
         return(false);
        }



      if(m_PositionsProfitComparison == NULL)
        {
         if((m_PositionsProfitComparison = new CiPosition("PosIndicatorWithComparisons",2))== NULL)
           {
            Print("CStrategy_TwoMM_Base_RunsComparisons::Error creating PositionIndicatorRunComparisons");
            return(false);
           }
        }
      if(!m_PositionsProfitComparison.Create(m_Pair, 0))
        {
         Print("CStrategy_TwoMM_Base_RunsComparisons::Error initializing PositionIndicatorRunComparisons");
         return(false);
        }
      if(!m_Indis.Add(m_PositionsProfitComparison))
        {
         Print("CStrategy_TwoMM_Base_RunsComparisons::Error adding CiPosition to indicator collection");
         return(false);
        }
     }
     CStrategy_TwoMM_Base::InitMainIndicators();
   return true;
  }


//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStrategy_TwoMM_Base_RunsComparisons::CStrategy_TwoMM_Base_RunsComparisons(enMaTypes _MAMethod,int slowPeriod,int fastPeriod,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange)  : CStrategy_TwoMM_Base( _MAMethod, slowPeriod, fastPeriod, _ATR_MAPeriod, _ATR_StopLossRange, _ATR_TPRange)        // Constructor
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
