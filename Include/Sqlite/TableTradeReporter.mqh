//+------------------------------------------------------------------+
//|                                                TableCalendar.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Arrays\ArrayString.mqh>
#include <Sqlite\dbClass.mqh>
#include "SqlTable.mqh"
string colNames = "(dt,symbol,type,mode,volume,sl,tp,comment)";
bool createTableOnStart = true;
class TableTradeReporter : public SqlTable
  {
private:

          
                   
                    
public:
                     TableTradeReporter(string sStrategyName,dbClass* _db );
                     bool insert_trade(datetime dt,string sSymbol,bool type,bool open_or_close,double volume,double sl,double tp,string comment);
                    ~TableTradeReporter();
                   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TableTradeReporter::TableTradeReporter(string sStrategyName,dbClass* _db ) : SqlTable(sStrategyName + "_TRADES",_db,createTableOnStart,colNames)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TableTradeReporter::~TableTradeReporter()
  {
  }


bool TableTradeReporter::insert_trade(datetime dt,string sSymbol,bool type,bool open_or_close,double volume,double sl,double tp,string comment)
{
string sdt = IntegerToString((long)dt);
string sVolume = DoubleToString(volume);
string sSL = DoubleToString(sl);
string sTP = DoubleToString(tp);
string sType;
string sOpenClose;
if(type) 
   sType = "BUY";
else
 sType = "SELL";
 
if (open_or_close)
 sOpenClose = "OPEN";
else
sOpenClose = "CLOSE";


string rqst = "INSERT INTO " + sTableName + " VALUES (" + sdt + "," + sSymbol + "," + sType + "," + sOpenClose + "," + sVolume + "," + sSL + "," + sTP + ")";
   if(!DatabaseExecute(db,rqst))
     {
      Print("DB: ", this.dbFull.getDBName(), " insert failed with code ", GetLastError());
      DatabaseClose(db);
      return false;
     }
     return true;
}