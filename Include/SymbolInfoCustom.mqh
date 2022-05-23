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
CArrayDouble* cumulated_balance;   
CArrayDouble* cumulated_equity;   
string         sGlobalBalanceVarNameBalance;
double         balance;
double         computeFloatingEquity();
public:
                     CSymbolInfoCustom();
                    ~CSymbolInfoCustom();
                    double computeBalance();
                    double computeEquity();
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
double CSymbolInfoCustom::computeEquity()
{
balance = computeBalance();
double res = balance + computeFloatingEquity();
return res;
}
double CSymbolInfoCustom::computeFloatingEquity()
{

//--- Find out the number of deals
   int pos_total=::PositionsTotal();
   string msg = "";
     for(int i=0; i<pos_total; i++)
     {
            CPositionInfo m_position_info;
            string msg_base  =Name() +  "_POSITION_" + IntegerToString(i) ;
                 if(!m_position_info.SelectByIndex(i))
                         continue;
            if(m_position_info.Symbol()==Name() && m_position_info.Profit()!=0)
            {
               double new_equity = cumulated_equity.At(cumulated_equity.Total()-1) +m_position_info.Profit()+m_position_info.Swap()+m_position_info.Commission();
               cumulated_equity.Add(new_equity);
                msg = msg_base + " ( " + m_position_info.Symbol() + " ) " + " : new equity is : " + DoubleToString(new_equity);
            }
               //--- Show a trade in the balance with this symbol. Consider swap and commission

            //--- Otherwise, write the previous value
            else
              {
             
                    double new_equity = cumulated_equity.At(cumulated_equity.Total()-1);
                                   msg = msg_base + " ( " + m_position_info.Symbol() + " ) " + " : Reported Equity is : " + DoubleToString(new_equity);
                      cumulated_equity.Add(new_equity);
             
            //    Print(msg);
              }
     }
     return cumulated_equity.At(cumulated_equity.Total()-1);
     
}
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
            //    Print(msg);
              }
     }
 
     return cumulated_balance.At(cumulated_balance.Total()-1);
     
     
     
     
}