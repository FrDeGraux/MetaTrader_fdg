//+------------------------------------------------------------------+
//|                                                   SVDEbugger.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
class CSVDebugger
  {
private:

public:
                     CSVDebugger(string ctx);
                     CSVDebugger();
                    ~CSVDebugger();
                    void init(string ctx);
                    bool writeMsg(string msg);
private : 
                     string filename;
                     int handleFile;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string buildFileName()
{
string sTime = TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES );
StringReplace(sTime,".",'_');
StringReplace(sTime,":",'_');

return sTime;
}
void CSVDebugger::init(string ctx)
{
   this.filename = buildFileName() + ".csv" ; 
   this.handleFile = FileOpen(this.filename,FILE_CSV|FILE_READ|FILE_WRITE, ',');
   if(this.handleFile > 0)
       Print("File " + this.filename + " is opened");
}
CSVDebugger::CSVDebugger()
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSVDebugger::~CSVDebugger()
  {
   FileClose(this.handleFile);
      Print("File " + this.filename + " is closed");
  }
//+------------------------------------------------------------------+
bool CSVDebugger::writeMsg(string msg)
{
      Print("going to write msg : " + msg);
      return(FileWrite(this.handleFile,msg) > 0);
    
}