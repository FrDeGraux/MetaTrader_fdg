//+------------------------------------------------------------------+
//|                                              dbCalendarClass.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#define EXECUTION_LOG_MODE false
class dbClass
{
public : 
 dbClass(string in_sDBFilePath);
 bool openDataBase();
void closeDB();
int getDB();
string getDBName();
private : 
bool isDBClosed;
int db;
string db_name;
};
int dbClass::getDB()
{return db;}
void dbClass::closeDB()
{
 DatabaseClose(this.db);
 this.isDBClosed = 1;
}
bool dbClass::openDataBase()
{
if(this.db_name=="")
     {
      PrintFormat("Error. Database file not specified.");
      return(false);
     }
//--- 1. open database
    this.db=DatabaseOpen(this.db_name,0x46);
   if(this.db==INVALID_HANDLE)
     {
      PrintFormat("Can't open database. Error code=%d",GetLastError());
      return(false);
     }
   if(EXECUTION_LOG_MODE)
   {
      PrintFormat("1. Database opened successfully.");
      this.isDBClosed = 0;
    }
   return true;
}
dbClass::dbClass(string database_name)
{
this.db_name = database_name;
this.isDBClosed = 1;
 if(!this.openDataBase())
    {
         Alert("Unable to access db :  " + this.db_name  );
         ExpertRemove();
   }
 }

 string dbClass::getDBName()
{
return db_name;
}