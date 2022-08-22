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

   string            sGlobalBalanceVarNameBalance;
   double            new_balance;
   double            previous_balance;

public:
                     CSymbolInfoCustom();
                    ~CSymbolInfoCustom();
   double            computeSymbolBalance();
   double            computeSymbolBalance_v2();
   double            computeSymbolEquity();
   double            computeSymbolFloatingEquity();
   double            computeNetPositioning();

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


   int nProcessedDeals = 0;
   new_balance = 0;
   previous_balance = 0;
   sGlobalBalanceVarNameBalance = Name()  + "_balance";

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSymbolInfoCustom::~CSymbolInfoCustom()
  {
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSymbolInfoCustom::computeSymbolEquity()
  {


   double balance = computeSymbolBalance();
   double floating = computeSymbolFloatingEquity();

   return balance + floating;
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
         Print("CSymbolInfoCustom:: Unable to select position " + IntegerToString(i));
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


      if(!m_position_info.SelectByIndex(i))
        {
         Print("CSymbolInfoCustom::Unable to select position " + IntegerToString(i));
         continue;
        }
      string s1 = m_position_info.Symbol();
      string s2 = Name();

      if(m_position_info.Symbol()==Name() && m_position_info.Profit()!=0)
        {
         new_equity = new_equity +m_position_info.Profit()+m_position_info.Swap()+m_position_info.Commission();

        }

     }
   return new_equity;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSymbolInfoCustom::computeSymbolBalance()
  {
// Balance is realized, equity is floating one
// @ epoch t, balance
// Balance is realized, equity is floating one
// @ epoch t, balance

//--- Find out the number of deals
   ::HistorySelect(0,LONG_MAX);
   int nDeals = 0;
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
         Print("CSymbolInfoCustom::Unabrzle to select deal " + IntegerToString(i));
         continue;
        }

      if(m_deal_info.Symbol()!=Name() && (m_deal_info.DealType()!=DEAL_TYPE_BALANCE))
         continue;

      if(m_deal_info.DealType()==DEAL_TYPE_BALANCE)
        {
         new_balance = AccountInfoDouble(ACCOUNT_BALANCE);
         previous_balance = new_balance;

         GlobalVariableSet("initial_balance",new_balance);

         nProcessedDeals = nProcessedDeals+1;

        }


      else
        {
         if(m_deal_info.Symbol()==Name() && m_deal_info.Profit()!=0)
           {
           
           nDeals=nDeals + 1;
           /*
           if(Name() == "GBPUSD")
           {
           Print(" i has the value " + DoubleToString(i));
           Print("PRofit is " + DoubleToString(m_deal_info.Profit()));
           Print("Swap is " + DoubleToString(m_deal_info.Swap()));
           Print("Commission is " + DoubleToString(m_deal_info.Commission()));
           }
           */
             new_balance = previous_balance +m_deal_info.Profit()+m_deal_info.Swap()+m_deal_info.Commission();
            previous_balance = new_balance;
            nProcessedDeals = i+1;
            /*
                    if(Name() == "GBPUSD")
           {
            Print(" Previous balance is " + DoubleToString(previous_balance));
            
            Print(" new_balance balance is " + DoubleToString(new_balance));
            
            Print(" nDeals  is " + DoubleToString(nDeals));
              Print(" processed_deals_already  is " + DoubleToString(processed_deals_already));
                Print(" deals_total  is " + DoubleToString(deals_total));
                
            }
            */
           }
        }


     }






   return new_balance;



  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
