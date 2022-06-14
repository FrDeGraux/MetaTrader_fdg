//+------------------------------------------------------------------+
//|                                             SymbolInfoCustom.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\SymbolInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Arrays\ArrayDouble.mqh>
class CSymbolInfoCustom : public CSymbolInfo
  {
private:
   CArrayDouble*     cumulated_balance;
   CArrayDouble*     cumulated_equity;
   string            sGlobalBalanceVarNameBalance;
   double            balance;

public:
                     CSymbolInfoCustom();
                    ~CSymbolInfoCustom();
   double            computeSymbolBalance();
   double            computeSymbolBalance_v2();
   double            computeSymbolEquity();
   double            computeSymbolFloatingEquity();
   double            computeNetPositioning();
   void              addInitialBalance();
   int               nProcessedDeals;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSymbolInfoCustom::CSymbolInfoCustom()
  {
   cumulated_balance = new CArrayDouble();
   cumulated_equity = new CArrayDouble();
   cumulated_equity.Add(0);
   int nProcessedDeals = 0;
   sGlobalBalanceVarNameBalance = Name()  + "_balance";

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSymbolInfoCustom::~CSymbolInfoCustom()
  {
  }
//+------------------------------------------------------------------+
void CSymbolInfoCustom::addInitialBalance()
  {
   if(cumulated_balance.Total() == 0)
     {
      if(GlobalVariableCheck("initial_balance"))
         cumulated_balance.Add(GlobalVariableGet("initial_balance"));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSymbolInfoCustom::computeSymbolEquity()
  {


   balance = computeSymbolBalance();
   double res = balance + computeSymbolFloatingEquity();
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSymbolInfoCustom::computeNetPositioning()
  {
// Balance is realized, equity is floating one


//--- Find out the number of deals
   int pos_total=::PositionsTotal();
   string msg = "";
   if(pos_total == 0)
      return 0;
   double new_positioning = 0;
   for(int i=0; i<pos_total; i++)
     {
      CPositionInfo m_position_info;
      string msg_base  =Name() +  "_POSITION_" + IntegerToString(i) ;
      if(!m_position_info.SelectByIndex(i))
        {
         Print("Unable to select position " + IntegerToString(i));
         continue;
        }
      string s1 = m_position_info.Symbol();
      string s2 = Name();

      if(m_position_info.Symbol()==Name())
        {
         int factor;
         if(m_position_info.PositionType() == POSITION_TYPE_BUY)
            factor = 1;
         if(m_position_info.PositionType() == POSITION_TYPE_SELL)
            factor = -1;
         new_positioning = new_positioning +factor*m_position_info.Volume();

         msg = msg_base + " ( " + m_position_info.Symbol() + " ) " + " : new Positioning is : " + DoubleToString(new_positioning);
        }
      //--- Show a trade in the balance with this symbol. Consider swap and commission

      //--- Otherwise, write the previous value

      //  Print(msg);
     }
   return new_positioning;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSymbolInfoCustom::computeSymbolFloatingEquity()
  {
// Balance is realized, equity is floating one


//--- Find out the number of deals
   int pos_total=::PositionsTotal();
   string msg = "";
   if(pos_total == 0)
      return 0;
   double new_equity = 0;
   for(int i=0; i<pos_total; i++)
     {
      CPositionInfo m_position_info;
      string msg_base  =Name() +  "_POSITION_" + IntegerToString(i) ;
      if(!m_position_info.SelectByIndex(i))
        {
         Print("Unable to select position " + IntegerToString(i));
         continue;
        }
      string s1 = m_position_info.Symbol();
      string s2 = Name();

      if(m_position_info.Symbol()==Name() && m_position_info.Profit()!=0)
        {
         new_equity = new_equity +m_position_info.Profit()+m_position_info.Swap()+m_position_info.Commission();
         cumulated_equity.Add(new_equity);
         msg = msg_base + " ( " + m_position_info.Symbol() + " ) " + " : new equity is : " + DoubleToString(new_equity);
        }
      //--- Show a trade in the balance with this symbol. Consider swap and commission

      //--- Otherwise, write the previous value

      //  Print(msg);
     }
   return new_equity;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSymbolInfoCustom::computeSymbolBalance()
  {
// Balance is realized, equity is floating one
// @ epoch t, balance
   addInitialBalance();
//--- Find out the number of deals
   ::HistorySelect(0,LONG_MAX);
//--- Find out the numberof deals
   int deals_total=::HistoryDealsTotal();
   string msg = "";

   int processed_deals_already = nProcessedDeals;
   for(int i=processed_deals_already; i<deals_total; i++) //  New deals
     {
      // DEAL_1 is the empty one
      // DEAL_2
      CDealInfo m_deal_info;
      string s1 = m_deal_info.Symbol();
      string s2 = Name();
      int type = m_deal_info.DealType();
      if(!m_deal_info.SelectByIndex(i))
        {
         Print("Unabrzle to select deal " + IntegerToString(i));
         continue;
        }

      if(m_deal_info.Symbol()!=Name() && (m_deal_info.DealType()!=DEAL_TYPE_BALANCE))
         continue;

      if(m_deal_info.DealType()==DEAL_TYPE_BALANCE)
        {
         double new_balance = AccountInfoDouble(ACCOUNT_BALANCE);
         cumulated_balance.Add(new_balance);

         GlobalVariableSet("initial_balance",new_balance);

         nProcessedDeals = nProcessedDeals+1;

        }


      else
        {
         if(m_deal_info.Symbol()==Name() && m_deal_info.Profit()!=0)
           {
            double new_balance = cumulated_balance.At(cumulated_balance.Total()-1) +m_deal_info.Profit()+m_deal_info.Swap()+m_deal_info.Commission();
            cumulated_balance.Add(new_balance);
            nProcessedDeals = nProcessedDeals+1;
           }
        }


     }




  

return cumulated_balance.At(cumulated_balance.Total()-1);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
