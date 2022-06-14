//+------------------------------------------------------------------+
//|                                     DistributionFigure_class.mqh |
//|                                                           denkir |
//|                                                 denkir@gmail.com |
//+------------------------------------------------------------------+
#property copyright "denkir"
#property link      "denkir@gmail.com"

#include <Distribution_class.mqh>
#include <Trade\SymbolInfo.mqh>
//#include <Trace.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Dist_type  // distribution type
  {
   Normal,
   Lognormal,
   Cauchy,
   Hypersec,
   Studentt,
   Logistic,
   Exponential,
   Gamma,
   Beta,
   Laplace,
   Binomial,
   Poisson
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Dist_mode // distribution mode
  {
   pdf,cdf,invcdf,sf
  };
//+------------------------------------------------------------------+
//|           Distribution Figure class definition                   |
//+------------------------------------------------------------------+
class CDistributionFigure
  {
private:
   Dist_type         type;  //distribution type 
   Dist_mode         mode;  //distribution mode (pdf,cdf,invcdf,sf)
   double            x;     //step start
   double            x11;   //left side limit
   double            x12;   //right side limit
   int               d;     //number of points
   double            st;    //step

public:
   double            xAr[]; //array of random variables
   double            p1[];  //array of probabilities
   void              CDistributionFigure();  //constructor 
   void              setDistribution(Dist_type Type,Dist_mode Mode,double X11,double X12,double St); //set-method
   void              calculateDistribution(double nn,double mm,double ss); //distribution parameter calculation
   void              filesave(); //saving distribution parameters
  };
//+------------------------------------------------------------------+
//|           Saving distribution parameters                         |
//+------------------------------------------------------------------+
void  CDistributionFigure::filesave()
  {
   int fhandle;
   ResetLastError();
   fhandle=FileOpen("dataDist.txt",FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(fhandle<0){Print("File open failed, error ",GetLastError());return;}
   string str="var data=[",ef;
   int Len=ArraySize(xAr);
   for(int i=0;i<Len-1;i++)
     {
      if(type==10 || type==11) //for discrete distributions
        {
         if(xAr[i]<0.5e-4)continue;
         ef=expForm(xAr[i]);
         str+="["+ef+","+DoubleToString(NormalizeDouble(p1[i],6),6)+"],";
        }
      else
         str+="["+DoubleToString(NormalizeDouble(xAr[i],5),5)+","+DoubleToString(NormalizeDouble(p1[i],6),6)+"],";
     }
   if(type==10 || type==11) //for discrete distributions         
      str+="["+expForm(xAr[Len-1])+","+DoubleToString(NormalizeDouble(p1[Len-1],6),6)+"]];";
   else
      str+="["+DoubleToString(NormalizeDouble(xAr[Len-1],5),5)+","+DoubleToString(NormalizeDouble(p1[Len-1],6),6)+"]];";
   string chart_title="var chart_title="+"\""+EnumToString(type)+" Distribution\";";
   string series_name="var series_name="+"\""+EnumToString(mode)+"\";";
   FileWriteString(fhandle,chart_title+"\n");
   FileWriteString(fhandle,series_name+"\n");
   FileWriteString(fhandle,str+"\n");
   FileClose(fhandle);
  }
//+------------------------------------------------------------------+
//|            Expression in exponential form                        |
//+------------------------------------------------------------------+
string expForm(double x)
  {
   double lf,sk;//qw=0.00021,
   lf=floor(fabs(log10(x)));
   string sq;
   sk=NormalizeDouble(pow(10,fabs(lf))*x,3);
   sq=DoubleToString(sk,3)+"e-"+DoubleToString(NormalizeDouble(lf,0),0);
   return sq;
  }
//+------------------------------------------------------------------+
//|             Distribution parameter calculation                   |
//+------------------------------------------------------------------+
void  CDistributionFigure::calculateDistribution(double nn,double mm,double ss)
  {
   switch(type)
     {
      case 0:
        {
         CNormaldist N; N.mu=mm;N.sig=ss;
         switch(mode) //(pdf,cdf,invcdf,sf)
           {
            case 0: //pdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.pdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 1: //cdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.cdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 2: //invcdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  xAr[i]=N.cdf(xAr[i]);
                  p1[i]=N.invcdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 3: //sf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.sf(xAr[i]);
                  x+=st;
                 }
               break;
              }
           }
         break;
        }
      case 1:
        {
         CLognormaldist N;N.mu=mm;N.sig=ss;
         switch(mode) //(pdf,cdf,invcdf,sf)
           {
            case 0: //pdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.pdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 1: //cdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.cdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 2: //invcdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  xAr[i]=N.cdf(xAr[i]);
                  p1[i]=N.invcdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 3: //sf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.sf(xAr[i]);
                  x+=st;
                 }
               break;
              }
           }
         break;
        }
      case 2:
        {
         CCauchydist N;N.mu=mm;N.sig=sqrt(ss);
         switch(mode) //(pdf,cdf,invcdf,sf)
           {
            case 0: //pdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.pdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 1: //cdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.cdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 2: //invcdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  xAr[i]=N.cdf(xAr[i]);
                  p1[i]=N.invcdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 3: //sf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.sf(xAr[i]);
                  x+=st;
                 }
               break;
              }
           }
         break;
        }
      case 3:
        {
         CHypersecdist N;N.mu=mm;N.sig=sqrt(ss);
         switch(mode) //(pdf,cdf,invcdf,sf)
           {
            case 0: //pdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.pdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 1: //cdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.cdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 2: //invcdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  xAr[i]=N.cdf(xAr[i]);
                  p1[i]=N.invcdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 3: //sf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.sf(xAr[i]);
                  x+=st;
                 }
               break;
              }
           }
         break;
        }
      case 4:
        {
         CStudenttdist N;N.nu=(int)nn;N.mu=mm;N.sig=sqrt(ss);
         switch(mode) //(pdf,cdf,invcdf,sf)
           {
            case 0: //pdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.pdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 1: //cdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.cdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 2: //invcdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  xAr[i]=N.cdf(xAr[i]);
                  p1[i]=N.invcdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 3: //sf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.sf(xAr[i]);
                  x+=st;
                 }
               break;
              }
           }
         break;
        }
      case 5:
        {
         CLogisticdist N;N.alph=mm;N.bet=sqrt(ss);
         switch(mode) //(pdf,cdf,invcdf,sf)
           {
            case 0: //pdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.pdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 1: //cdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.cdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 2: //invcdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  xAr[i]=N.cdf(xAr[i]);
                  p1[i]=N.invcdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 3: //sf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.sf(xAr[i]);
                  x+=st;
                 }
               break;
              }
           }
         break;
        }
      case 6:
        {
         CExpondist N;
         N.lambda=ss; //???
         switch(mode) //(pdf,cdf,invcdf,sf)
           {
            case 0: //pdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.pdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 1: //cdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.cdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 2: //invcdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  xAr[i]=N.cdf(xAr[i]);
                  p1[i]=N.invcdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 3: //sf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.sf(xAr[i]);
                  x+=st;
                 }
               break;
              }
           }
         break;
        }
      case 7:
        {
         CGammadist N;
         N.setCGammadist(mm,ss);
         switch(mode) //(pdf,cdf,invcdf,sf)
           {
            case 0: //pdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.pdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 1: //cdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.cdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 2: //invcdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  xAr[i]=N.cdf(xAr[i]);
                  p1[i]=N.invcdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 3: //sf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.sf(xAr[i]);
                  x+=st;
                 }
               break;
              }
           }
         break;
        }
      case 8:
        {
         CBetadist N;
         N.setCBetadist(mm,ss);
         switch(mode) //(pdf,cdf,invcdf,sf)
           {
            case 0: //pdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.pdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 1: //cdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.cdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 2: //invcdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  xAr[i]=N.cdf(xAr[i]);
                  p1[i]=N.invcdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 3: //sf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.sf(xAr[i]);
                  x+=st;
                 }
               break;
              }
           }
         break;
        }
      case 9:
        {
         CLaplacedist N;N.alph=mm;N.bet=ss;
         switch(mode) //(pdf,cdf,invcdf,sf)
           {
            case 0: //pdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.pdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 1: //cdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.cdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 2: //invcdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  xAr[i]=N.cdf(xAr[i]);
                  p1[i]=N.invcdf(xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 3: //sf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.sf(xAr[i]);
                  x+=st;
                 }
               break;
              }
           }
         break;
        }
      case 10:
        {
         CBinomialdist N;
         N.setCBinomialdist((int)mm,ss);
         switch(mode) //(pdf,cdf,invcdf,sf)
           {
            case 0: //pdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.pdf((int)xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 1: //cdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.cdf((int)xAr[i]);
                  xAr[i]--;
                  x+=st;
                 }
               break;
              }
            case 2: //invcdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  xAr[i]=N.cdf((int)xAr[i]);
                  x+=st;
                  if(xAr[i]==0)continue;
                  p1[i]=N.invcdf(xAr[i]);
                  p1[i]--;
                 }
               break;
              }
            case 3: //sf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.sf((int)xAr[i]);
                  x+=st;
                 }
               break;
              }
           }
         break;
        }
      case 11:
        {
         CPoissondist N;N.lambda=mm;
         switch(mode) //(pdf,cdf,invcdf,sf)
           {
            case 0: //pdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.pdf((int)xAr[i]);
                  x+=st;
                 }
               break;
              }
            case 1: //cdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.cdf((int)xAr[i]);
                  xAr[i]--;
                  x+=st;
                 }
               break;
              }
            case 2: //invcdf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  xAr[i]=N.cdf((int)xAr[i]);
                  x+=st;
                  if(xAr[i]==0)continue;
                  p1[i]=N.invcdf(xAr[i]);
                  p1[i]--;
                 }
               break;
              }
            case 3: //sf
              {
               for(int i=0;i<d;i++)
                 {
                  xAr[i]=x;
                  p1[i]=N.sf((int)xAr[i]);
                  x+=st;
                 }
               break;
              }
           }
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//| CDistributionFigure class constructor                            |
//+------------------------------------------------------------------+
void CDistributionFigure::CDistributionFigure()
  {
   setDistribution(0,0,-5.,5.,0.05);
  }
//+------------------------------------------------------------------+
//| CDistributionFigure class set-method                             |
//+------------------------------------------------------------------+
void CDistributionFigure::setDistribution(Dist_type Type,Dist_mode Mode,double X11,double X12,double St)
  {
   type=Type; mode=Mode;
   x11=X11;x12=X12;st=St;
   x=x11;
   d=(int)((x12-x11)/st);
//st_s=floor(log10(st));
   ArrayResize(xAr,d);ArrayResize(p1,d);
  }
//+------------------------------------------------------------------+
