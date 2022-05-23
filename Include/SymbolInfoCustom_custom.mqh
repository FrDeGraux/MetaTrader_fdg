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
  #include <Arrays\ArrayDouble.mqh>
class CSymbolInfoCustom : CSymbolInfo
  {
private:
CArrayDouble* cumulated_balance;    
string         sGlobalBalanceVarNameBalance;
public:
                     CSymbolInfoCustom();
                    ~CSymbolInfoCustom();
                    double computeBalance();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSymbolInfoCustom::CSymbolInfoCustom()
  {
    cumulated_balance = new CArrayDouble();
    sGlobalBalanceVarNameBalance = Name()  + "_balance";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSymbolInfoCustom::~CSymbolInfoCustom()
  {
  }
//+------------------------------------------------------------------+
double CSymbolInfoCustom::computeBalance()
{
   ::HistorySelect(0,LONG_MAX);
//--- Find out the number of deals
   int deals_total=::HistoryDealsTotal();
   string msg = "";
     for(int i=0; i<deals_total; i++)
     {
            CDealInfo m_deal_info;
            string msg_base  =Name() +  "_DEAL_" + IntegerToString(i) ;
                 if(!m_deal_info.SelectByIndex(i))
                         continue;
            if(m_deal_info.Symbol()==Name() && m_deal_info.Profit()!=0)
            {
               double new_balance = cumulated_balance.At(cumulated_balance.Total()-1) +m_deal_info.Profit()+m_deal_info.Swap()+m_deal_info.Commission();
               cumulated_balance.Add(new_balance);
                msg = msg_base + " ( " + m_deal_info.Symbol() + " ) " + " : new balance is : " + DoubleToString(new_balance);
            }
               //--- Show a trade in the balance with this symbol. Consider swap and commission

            //--- Otherwise, write the previous value
            else
              {
               //--- In case of a "balance deposit" deal (first deal), the balance is the same for all symbols
               if(m_deal_info.DealType()==DEAL_TYPE_BALANCE)
               {
                     double new_balance = AccountInfoDouble(ACCOUNT_BALANCE);
                        cumulated_balance.Add(new_balance);
                       msg = msg_base + " ( " + m_deal_info.Symbol() + " ) " + " : Initial Balancing is : " + DoubleToString(new_balance);
               }
               
               //--- Otherwise, write the previous value to the current index
               else
               {
                    double new_balance = cumulated_balance.At(cumulated_balance.Total()-1);
                                   msg = msg_base + " ( " + m_deal_info.Symbol() + " ) " + " : Reported Balancing is : " + DoubleToString(new_balance);
                      cumulated_balance.Add(new_balance);
               }
                Print(msg);
              }
     }
     return cumulated_balance.At(cumulated_balance.Total()-1);
     
     
     
     
}