//+------------------------------------------------------------------+
//|                             SymbolInfoCustomProfitComparison.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\SymbolInfoCustom.mqh>
#include <ProfitComparisonViewerParameters.mqh>
#include <UtilReader.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSymbolInfoCustomProfitComparison : public CSymbolInfoCustom
  {
private:
   CArrayString      positions_to_compare_against[];
   datetime          itNextDateTime;
   datetime          dtUltimateInputositionsDate;
   int               itIndex;
   double             dAvgEntryPrice;
   double            positioning;
   double            getcomputeAverageEntryPrice();
   double            balance;
      bool            updateIterators( );
     double          nRowsPositions;
public:

                     CSymbolInfoCustomProfitComparison(string sPair) ;
                    ~CSymbolInfoCustomProfitComparison();
   bool              init(CArrayString &swap_rates[],CArrayString &com_calibs[],CArrayString &positions_to_compare_against[]);

   double computeProfitComparisonEquity();
   double            computeProfitComparisonPositioning();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSymbolInfoCustomProfitComparison::CSymbolInfoCustomProfitComparison(string sPair) : CSymbolInfoCustom(sPair)
  {
   
   
nRowsPositions = 0;
   balance = 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSymbolInfoCustomProfitComparison::~CSymbolInfoCustomProfitComparison()
  {
  }
//+------------------------------------------------------------------+
bool  CSymbolInfoCustomProfitComparison::init(CArrayString &swap_rates[],CArrayString &com_calibs[],CArrayString &positions_to_compare_against[])
//+------------------------------------------------------------------+
  {
   UtilReader::filter_array_on_column_value(positions_to_compare_against,this.positions_to_compare_against,SYMBOL_POS,this.Name());
   nRowsPositions = UtilReader::getSizeBeforeNULL(this.positions_to_compare_against);
   dtUltimateInputositionsDate = UtilReader::getUltimateDateTime(this.positions_to_compare_against,SYMBOL_POS,nRowsPositions);
      itNextDateTime = TimeCurrent();

      itIndex = UtilReader::getRawLastDateTime(this.positions_to_compare_against,TimeCurrent(),DATETIME_POS);

            
   return CSymbolInfoCustom::init(swap_rates,com_calibs);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  CSymbolInfoCustomProfitComparison::getcomputeAverageEntryPrice()
  {
return dAvgEntryPrice;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSymbolInfoCustomProfitComparison::computeProfitComparisonEquity()
  {
double ask_price = SymbolInfoDouble(this.Name(),SYMBOL_ASK);
double bid_price = SymbolInfoDouble(this.Name(),SYMBOL_BID);

datetime in_dt = TimeCurrent();
   if(in_dt > itNextDateTime)
      updateIterators(); // update of average_price and positioning
    double price = (positioning>=0)?bid_price:ask_price;

   double floating_equity =100000* positioning*(price-getcomputeAverageEntryPrice());
   return balance  + floating_equity;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSymbolInfoCustomProfitComparison::computeProfitComparisonPositioning()
  {
  return positioning;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSymbolInfoCustomProfitComparison::updateIterators()
  {
   

int itNext = itIndex+1; // on which to index
int itNextEntry = itIndex+2; // until which no udpdate anymore
   if(itIndex >= (nRowsPositions-1))
      {
   dAvgEntryPrice = 0;
    positioning = 0;
    itNextDateTime=D'2050.01.01 00:00'; 
    return false;
      }
   double entry = positions_to_compare_against[itNext].At(ENTRY_POS);
   double quantity =  positions_to_compare_against[itNext].At(QUANTITY_POS);
   double type =  positions_to_compare_against[itNext].At(TYPE_POS);

       string record_next_dt  =  positions_to_compare_against[itNextEntry].At(DATETIME_POS);
        itNextDateTime = StringToTime(record_next_dt);
   if ((itNext-1) == -1)
          balance =10000;

   else 
       balance = balance + positions_to_compare_against[itNext-1].At(PROFIT_POS);

   if (type == -1)
      positioning = positioning - (entry*quantity);
   else
      positioning = positioning + (entry*quantity);
if (entry == -1)
   dAvgEntryPrice = 0; 
else
   dAvgEntryPrice =  positions_to_compare_against[itNext].At(PRICE_POS);
itIndex = itIndex+1;
return true;
  }
//+------------------------------------------------------------------+
