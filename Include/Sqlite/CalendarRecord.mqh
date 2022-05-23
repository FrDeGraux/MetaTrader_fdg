//+------------------------------------------------------------------+
//|                                               calendarRecord.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
   #include <Object.mqh>

class CalendarRecord : public CObject
  {
private:
 datetime dt;
            string country;
            string eventName;
            string s_Expected;
            string s_Actual;
            string s_Previous;
        
            string s_Consensus;
            string s_Impact;

      

          
public :  
              CalendarRecord(string dt,string country,string eventName,string s_Expected,string s_Actual,string s_Previous,string s_Consensus);
            string getcountry(){return country;};
            string geteventName(){return eventName;};
            string gets_Expected(){return s_Expected;};
            string gets_Actual(){return s_Actual;};
            string gets_Previous(){return s_Previous;};
       
            string gets_Consensus(){return s_Consensus;};
            string gets_Impact(){return s_Impact;};
      
         
            
};
  CalendarRecord::CalendarRecord(string dt,string country,string eventName,string s_Expected,string s_Actual,string s_Previous,string s_Consensus)
  {
    this.dt = StringToTime(TimeToString(dt,TIME_DATE|TIME_SECONDS));

  this.country = country;
  this.eventName =eventName;
  this.s_Expected =s_Expected;
  this.s_Actual =s_Actual;
  this.s_Previous =s_Previous;

  this.s_Impact =s_Impact;

  }