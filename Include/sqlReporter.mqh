//+------------------------------------------------------------------+
//|                                                  sqlReporter.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "Sqlite\TableTradeReporter.mqh"
#include "Sqlite\dbClass.mqh"
string dbName = "dbReporting";
class sqlReporter
  {
private:
         dbClass*    db;
         TableTradeReporter*  objTableTrade;
         string strategy_name;
public:
                     sqlReporter(string strategy_name);
                     bool insertTrade(datetime dt,string sSymbol,bool type,bool open_or_close,double volume,double sl,double tp,string comment);
                    ~sqlReporter();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
sqlReporter::sqlReporter(string _strategy_name) : strategy_name(_strategy_name)
  {
  db  = new dbClass(dbName);
  objTableTrade = new TableTradeReporter(strategy_name,db);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
sqlReporter::~sqlReporter()
  {
  delete objTableTrade; 
  }
bool sqlReporter::insertTrade(datetime dt,string sSymbol,bool type,bool open_or_close,double volume,double sl,double tp,string comment)
{
   return(objTableTrade.insert_trade(dt,sSymbol,type,open_or_close,volume,sl,tp,comment));
}
//+------------------------------------------------------------------+
