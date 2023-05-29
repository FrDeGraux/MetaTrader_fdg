//+------------------------------------------------------------------+
//|                          Strategy_BaseCustomProfitComparison.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <CStrategy_Base_Common.mqh>
#include <Trade\SymbolInfoCustomProfitComparison.mqh>
class CStrategy_BaseCustomProfitComparison : public CStrategy_Base_Common
  {
private:
   CiProfit            *m_EquityProfitComparison;
   CiPosition             *m_PositionsProfitComparison;
      void              setProfitComparisonIndicatorsValues();
   CArrayString* positions;
public:
                     CStrategy_BaseCustomProfitComparison();
                    ~CStrategy_BaseCustomProfitComparison();
   bool              Init(string Pair,int _magicNumber,int slippage,double lot,bool _useStopTP,CSVDebugger* _debugger,CArrayString& swap_rates[],CArrayString& commissions_calibrations[],CArrayString& positions[]);
   bool              InitIndicators();
   void setIndicatorsValue();

  };
  void CStrategy_BaseCustomProfitComparison::setIndicatorsValue()
  {

   this.setProfitComparisonIndicatorsValues();
   CStrategy_Base_Common::setIndicatorsValue();

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStrategy_BaseCustomProfitComparison::CStrategy_BaseCustomProfitComparison()
  {
   m_PositionsProfitComparison = NULL;
   m_EquityProfitComparison = NULL;


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStrategy_BaseCustomProfitComparison::Init(string Pair,int _magicNumber,int slippage,double lot,bool _useStopTP,CSVDebugger* _debugger,CArrayString& swap_rates[],CArrayString& commissions_calibrations[],CArrayString& positions[])
  {
   m_Symbol = new CSymbolInfoCustomProfitComparison(Pair);
   CSymbolInfoCustomProfitComparison *m_SymbolProfitComparison = dynamic_cast<CSymbolInfoCustomProfitComparison *>(m_Symbol);

   if(!m_SymbolProfitComparison.init(swap_rates,commissions_calibrations,positions))
      return false;
   return CStrategy_Base_Common::Init(Pair, _magicNumber, slippage, lot, _useStopTP,_debugger,swap_rates,commissions_calibrations);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStrategy_BaseCustomProfitComparison::~CStrategy_BaseCustomProfitComparison()
  {
  }
//+------------------------------------------------------------------+
void CStrategy_BaseCustomProfitComparison::setProfitComparisonIndicatorsValues()
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
bool CStrategy_BaseCustomProfitComparison::InitIndicators()
  {

   if(UtilTerminal::displayEquity())
     {
      if(m_EquityProfitComparison == NULL)
        {
         if((m_EquityProfitComparison = new CiProfit("EquityWithComparisons",2)) == NULL)
           {
            Print("CStrategy_BaseCustomProfitComparison::Error creating EquityIndicatorRunsComparisons");
            return(false);
           }
        }
      if(!m_EquityProfitComparison.Create(m_Pair, 0))
        {
         Print("CStrategy_BaseCustomProfitComparison::Error initializing EquityIndicatorRunsComparisons");
         return(false);
        }

      if(!m_Indis.Add(m_EquityProfitComparison))
        {
         Print("CStrategy_BaseCustomProfitComparison::Error adding Profit to indicator EquityIndicatorRunsComparisons");
         return(false);
        }



      if(m_PositionsProfitComparison == NULL)
        {
         if((m_PositionsProfitComparison = new CiPosition("PositionIndicatorRunComparisons",2))== NULL)
           {
            Print("CStrategy_BaseCustomProfitComparison::Error creating PositionIndicatorRunComparisons");
            return(false);
           }
        }
      if(!m_PositionsProfitComparison.Create(m_Pair, 0))
        {
         Print("CStrategy_BaseCustomProfitComparison::Error initializing PositionIndicatorRunComparisons");
         return(false);
        }
      if(!m_Indis.Add(m_PositionsProfitComparison))
        {
         Print("CStrategy_BaseCustomProfitComparison::Error adding CiPosition to indicator collection");
         return(false);
        }
     }
   return true;
  }


//+------------------------------------------------------------------+
