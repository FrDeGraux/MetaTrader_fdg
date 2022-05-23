//+------------------------------------------------------------------+
//|                                                TableCalendar.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00" 
#include "dbCalendarClass.mqh"
#include "SqlTable.mqh"
//#include "recordCalendar.mqh"
#include <Arrays\ArrayString.mqh>
bool createTableOnStart = false;
string colNames = "(dt,symbol,type,mode,volume,sl,tp,comment)";
class TableCalendar : public SqlTable
  {
private:

           
                      bool createTable();
                      CArrayString* get_record(int rec);
public:
                     TableCalendar(string sName,dbClass* _db);
                    
                    ~TableCalendar();
                    CArrayString* requestOnCountry(string ctry);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TableCalendar::TableCalendar(string sName,dbClass* _db) : SqlTable(sName + "_CALENDAR",_db,createTableOnStart,colNames)
  {
 
     
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
CArrayString* TableCalendar::requestOnCountry(string ctry)
{
 string rqst = "SELECT * FROM " + sTableName + " WHERE country = '" + ctry + "'";
  int request=DatabasePrepare(this.dbFull.getDB(),rqst);
  int v = GetLastError();
     if(request==INVALID_HANDLE)
     {
      Alert("DB: ", sTableName, " request failed with code ", GetLastError());
     
     }
     CArrayString* records = get_record(request);
     return records;
}
CArrayString* TableCalendar::get_record(int request)
{

string dTime;
string country;
string eventName;
string impact;
string actual;
string previous;
string consensus;
string revised;
string res;
CArrayString* vector_res=new CArrayString;
   for(int i=0; DatabaseRead(request); i++)
     {
      //--- read the values of each field from the obtained entry
      if(DatabaseColumnText(request, 0, dTime) && DatabaseColumnText(request, 1, country) &&
         DatabaseColumnText(request, 2, eventName) && DatabaseColumnText(request, 3, impact) && DatabaseColumnText(request, 4, actual) && DatabaseColumnText(request, 5, previous) && DatabaseColumnText(request, 6, consensus) && DatabaseColumnText(request, 7, revised))
               int x = 0;
      else
        {
         DatabaseFinalize(request);
         delete vector_res;
         Alert(i, ": DatabaseRead() failed with code ", GetLastError());
         
    
        }
            res = dTime + ";" +  country + ";" +  eventName + ";" +  impact + ";" +  actual + ";" +  previous + ";" +consensus  + ";" + revised;
            vector_res.Add(res);
     }
     
     
//--- remove the query after use
DatabaseFinalize(request);
return vector_res;
}
//--- print all entries with the salary greater than 15000
