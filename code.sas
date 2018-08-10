libname utd 'E:\Users\axt174830\Downloads'; run;


proc sort data=utd.wen; by CUSTOMER_KEY; run;

/*proc print data= utd.wenstd; run;*/

*missing value;
data utd.wennew;
set utd.wen;
if missing(cats(of _all_)) then delete;
run;

proc reg data=utd.wennew;
model TOT_SALES=
_DM				_EM					_SMS
SIZE_HH			HH_INCOME			DMA
TENURE			NUM_TXNS			_avg_TB_TRANS
TOT_rewards_EARN					NUM_EARN_REDEEM
REDEEM_WELCOME	DYPT_PCT_BR			DYPT_PCT_LU
DYPT_PCT_AF		DYPT_PCT_DINNER		DYPT_PCT_EVEN
DYPT_PCT_NITE	BAKERY_PCT			CHICKN_PCT
HAMBRGR_PCT		MealDeal_PCT		FRSTY_PCT
SALAD_PCT		KID_PCT				OTHER_PCT
TOT_UNITS		BEVRG_QTY			HAMBR_QTY
CHICK_QTY		FRY_QTY				VALU_QTY
FRST_QTY		KID_QTY				SALD_QTY
BAKR_QTY		MEALDEAL_QTY		AVG_PRICE;
output out = utd.wenresid p = PUNITS r = RUNITS student = student;
run;

/*proc print data= utd.wenresid; run;*/

data utd.wenstud;
set utd.wenresid;
if student > 3.00 then delete;
if student < -3.00 then delete;
run;


*standardization;
proc standard data= utd.wenstud mean=0 std=1 out= utd.wenstd;
var TOT_SALES
_DM				_EM					_SMS
SIZE_HH			HH_INCOME			DMA
TENURE			NUM_TXNS			_avg_TB_TRANS
TOT_rewards_EARN					NUM_EARN_REDEEM
REDEEM_WELCOME	DYPT_PCT_BR			DYPT_PCT_LU
DYPT_PCT_AF		DYPT_PCT_DINNER		DYPT_PCT_EVEN
DYPT_PCT_NITE	BAKERY_PCT			CHICKN_PCT
HAMBRGR_PCT		MealDeal_PCT		FRSTY_PCT
SALAD_PCT		KID_PCT				OTHER_PCT
TOT_UNITS		BEVRG_QTY			HAMBR_QTY
CHICK_QTY		FRY_QTY				VALU_QTY
FRST_QTY		KID_QTY				SALD_QTY
BAKR_QTY		MEALDEAL_QTY		AVG_PRICE;
run;


*collinearity: NUM_TXNS and TOT_UNITS's correlation is 0.82371;
proc corr data=utd.wenstd;
var
_DM				_EM					_SMS
SIZE_HH			HH_INCOME			TENURE			
NUM_TXNS		_avg_TB_TRANS		TOT_rewards_EARN					
NUM_EARN_REDEEM	REDEEM_WELCOME		DYPT_PCT_BR			
DYPT_PCT_LU		DYPT_PCT_AF			DYPT_PCT_DINNER		
DYPT_PCT_EVEN	DYPT_PCT_NITE		BEVRG_QTY			
HAMBR_QTY		CHICK_QTY			FRY_QTY				
VALU_QTY		FRST_QTY			KID_QTY				
SALD_QTY		BAKR_QTY			MEALDEAL_QTY		
AVG_PRICE;
run;
*TOT_units has collinearity with avg_tb_trans, and tot_units had high VIF so we removed it.;

proc reg data=utd.wenstd;
model TOT_SALES=
_DM				_EM					_SMS
SIZE_HH			HH_INCOME			TENURE			
NUM_TXNS		_avg_TB_TRANS		TOT_rewards_EARN					
NUM_EARN_REDEEM	REDEEM_WELCOME		DYPT_PCT_BR			
DYPT_PCT_LU		DYPT_PCT_AF			DYPT_PCT_DINNER		
DYPT_PCT_EVEN	DYPT_PCT_NITE		BEVRG_QTY			
HAMBR_QTY		CHICK_QTY			FRY_QTY				
VALU_QTY		FRST_QTY			KID_QTY				
SALD_QTY		BAKR_QTY			MEALDEAL_QTY		
AVG_PRICE/VIF COLLIN;
run;quit;


*k means: 4 clusters;
proc fastclus data = utd.wenstud
out= utd.wenfinal maxc=4 maxiter=20;
/*maxclusters = 4 out = utd.wenstud1(keep = CUSTOMER_KEY cluster);*/
var
_DM				_EM				_SMS		
SIZE_HH			HH_INCOME		NUM_TXNS		
_avg_TB_TRANS	NUM_EARN_REDEEM	REDEEM_WELCOME	
DYPT_PCT_BR		DYPT_PCT_LU		DYPT_PCT_AF		
DYPT_PCT_DINNER	DYPT_PCT_EVEN	DYPT_PCT_NITE				
CHICKN_PCT		HAMBRGR_PCT		MealDeal_PCT		
FRSTY_PCT		SALAD_PCT		KID_PCT				
OTHER_PCT		AVG_PRICE;
run;


**merge clustr with original data;
proc sort data = utd.wenfinal; by CUSTOMER_KEY; run;
proc sort data = utd.wenstud; by CUSTOMER_KEY; run;


data utd.final_1;
merge utd.wenfinal utd.wenstud; by CUSTOMER_KEY ; run;

proc print data= utd.final_1; run;

* discrim tests for best solution *;
***need to check the result again;

proc discrim data= utd.final_1 out=output scores = x method=normal anova;
   class cluster ;
   priors prop;
   id CUSTOMER_KEY;
   var  
TOT_SALES
_DM				_EM					_SMS
SIZE_HH			HH_INCOME			DMA
TENURE			NUM_TXNS			_avg_TB_TRANS
TOT_rewards_EARN					NUM_EARN_REDEEM
REDEEM_WELCOME	DYPT_PCT_BR			DYPT_PCT_LU
DYPT_PCT_AF		DYPT_PCT_DINNER		DYPT_PCT_EVEN
DYPT_PCT_NITE	BAKERY_PCT			CHICKN_PCT
HAMBRGR_PCT		MealDeal_PCT		FRSTY_PCT
SALAD_PCT		KID_PCT				OTHER_PCT
TOT_UNITS		BEVRG_QTY			HAMBR_QTY
CHICK_QTY		FRY_QTY				VALU_QTY
FRST_QTY		KID_QTY				SALD_QTY
BAKR_QTY		MEALDEAL_QTY		AVG_PRICE;
run;

proc sort data = utd.final_1; by cluster; run;


proc means data = utd.final_1; by cluster; 
output out = means; run;




*elasticity modeling;
data utd.cluster1; 
set utd.final_1;
if student > 3.00 then delete;
if student < -3.00 then delete;
where cluster=1;run;


data utd.cluster2; 
set utd.final_1;
if student > 3.00 then delete;
if student < -3.00 then delete;
where cluster=2;run;

data utd.cluster3; 
set utd.final_1;
if student > 3.00 then delete;
if student < -3.00 then delete;
where cluster=3;run;

data utd.cluster4; 
set utd.final_1;
if student > 3.00 then delete;
if student < -3.00 then delete;
where cluster=4;run;


proc reg data=utd.cluster1;
model TOT_UNITS=
_DM				_EM				_SMS		
SIZE_HH			HH_INCOME		NUM_TXNS		
_avg_TB_TRANS	NUM_EARN_REDEEM	REDEEM_WELCOME	
DYPT_PCT_BR		DYPT_PCT_LU		DYPT_PCT_AF		
DYPT_PCT_DINNER	DYPT_PCT_EVEN	DYPT_PCT_NITE				
CHICKN_PCT		HAMBRGR_PCT		MealDeal_PCT		
FRSTY_PCT		SALAD_PCT		KID_PCT				
OTHER_PCT		AVG_PRICE;
run;
proc means data=utd.cluster1;
run;


proc reg data=utd.cluster2;
model TOT_UNITS=
_DM				_EM				_SMS		
SIZE_HH			HH_INCOME		NUM_TXNS		
_avg_TB_TRANS	NUM_EARN_REDEEM	REDEEM_WELCOME	
DYPT_PCT_BR		DYPT_PCT_LU		DYPT_PCT_AF		
DYPT_PCT_DINNER	DYPT_PCT_EVEN	DYPT_PCT_NITE				
CHICKN_PCT		HAMBRGR_PCT		MealDeal_PCT		
FRSTY_PCT		SALAD_PCT		KID_PCT				
OTHER_PCT		AVG_PRICE;
run;
proc means data=utd.cluster2;
run;


proc reg data=utd.cluster3;
model TOT_UNITS=
_DM				_EM				_SMS		
SIZE_HH			HH_INCOME		NUM_TXNS		
_avg_TB_TRANS	NUM_EARN_REDEEM	REDEEM_WELCOME	
DYPT_PCT_BR		DYPT_PCT_LU		DYPT_PCT_AF		
DYPT_PCT_DINNER	DYPT_PCT_EVEN	DYPT_PCT_NITE				
CHICKN_PCT		HAMBRGR_PCT		MealDeal_PCT		
FRSTY_PCT		SALAD_PCT		KID_PCT				
OTHER_PCT		AVG_PRICE;
run;
proc means data=utd.cluster3;
run;


proc reg data=utd.cluster4;
model TOT_UNITS=
_DM				_EM				_SMS		
SIZE_HH			HH_INCOME		NUM_TXNS		
_avg_TB_TRANS	NUM_EARN_REDEEM	REDEEM_WELCOME	
DYPT_PCT_BR		DYPT_PCT_LU		DYPT_PCT_AF		
DYPT_PCT_DINNER	DYPT_PCT_EVEN	DYPT_PCT_NITE				
CHICKN_PCT		HAMBRGR_PCT		MealDeal_PCT		
FRSTY_PCT		SALAD_PCT		KID_PCT				
OTHER_PCT		AVG_PRICE;
run;
proc means data=utd.cluster4;
run;



/*marcom*/
*marcom cluster 1;  *(R^2=0.1961);
proc reg data = utd.cluster1;
model tot_sales = _dm _em _sms /vif collin;
output out = marcom_resid1 p = Prev1 r = Rrev1 student = student1;
run;quit;

*marcom cluster 2;  *(R^2=0.2161);
proc reg data = utd.cluster2;
model tot_sales = _dm _em _sms /vif collin;
output out = marcom_resid2 p = Prev1 r = Rrev2 student = student2;
run;quit;

*marcom cluster 3;  *(R^2=0.1934);
proc reg data = utd.cluster3;
model tot_sales = _dm _em _sms /vif collin;
output out = marcom_resid3 p = Prev3 r = Rrev3 student = student3;
run;quit;

*marcom: cluster 4;  *(R^2=0.3156);  
proc reg data = utd.cluster4;
model tot_sales = _dm _em _sms /vif collin;
output out = marcom_resid4 p = Prev4 r = Rrev4 student = student4;
run;quit;

**marcom try more var;

*marcom cluster 1;  *(R^2=0.8948);
proc reg data = utd.cluster1;
model tot_sales = tot_units avg_price _dm _em _sms /vif collin;
output out = marcom_resid1 p = Prev1 r = Rrev1 student = student1;
run;quit;

*marcom cluster 2;  *(R^2=0.91);
proc reg data = utd.cluster2;
model tot_sales = tot_units avg_price _dm _em _sms /vif collin;
output out = marcom_resid2 p = Prev1 r = Rrev2 student = student2;
run;quit;

*marcom cluster 3;  *(R^2=0.8863);
proc reg data = utd.cluster3;
model tot_sales = tot_units avg_price _dm _em _sms /vif collin;
output out = marcom_resid3 p = Prev3 r = Rrev3 student = student3;
run;quit;

*marcom: cluster 4;  *(R^2=0.9523);  
proc reg data = utd.cluster4;
model tot_sales = tot_units avg_price _dm _em _sms /vif collin;
output out = marcom_resid4 p = Prev4 r = Rrev4 student = student4;
run;quit;


*MBA: cluster1;
data utd.wenmbac1;
set utd.cluster1;
lo_BEVRG_QTY=0;
lo_HAMBR_QTY=0;
lo_CHICK_QTY=0;		
lo_FRY_QTY=0;
lo_VALU_QTY=0;
lo_FRST_QTY=0;
lo_KID_QTY=0;
lo_SALD_QTY=0;
lo_BAKR_QTY=0;
lo_MEALDEAL_QTY=0;
if BEVRG_QTY>0 then lo_BEVRG_QTY=1;
if HAMBR_QTY>0 then lo_HAMBR_QTY=1;
if CHICK_QTY>0 then lo_CHICK_QTY=1;		
if FRY_QTY>0 then lo_FRY_QTY=1;
if VALU_QTY>0 then lo_VALU_QTY=1;
if FRST_QTY>0 then lo_FRST_QTY=1;
if KID_QTY>0 then lo_KID_QTY=1;
if SALD_QTY>0 then lo_SALD_QTY=1;
if BAKR_QTY>0 then lo_BAKR_QTY=1;
if MEALDEAL_QTY>0 then lo_MEALDEAL_QTY=1;

proc print data= utd.wenmbac1;
run;
proc logistic descending data= utd.wenmbac1;
model lo_BEVRG_QTY=

lo_HAMBR_QTY
lo_CHICK_QTY		
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac1;
model lo_HAMBR_QTY=
lo_BEVRG_QTY
lo_CHICK_QTY		
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac1;
model lo_CHICK_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac1;
model lo_FRY_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	

lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;

proc logistic descending data= utd.wenmbac1;
model lo_VALU_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY

lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac1;
model lo_FRST_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY

lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
**All observations have the same response.  No statistics are computed.;
proc logistic descending data= utd.wenmbac1;
model lo_KID_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY

lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac1;
model lo_SALD_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY

lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac1;
model lo_BAKR_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY

lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac1;
model lo_MEALDEAL_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
;
run;

*mba: cluster2;
data utd.wenmbac2;
set utd.cluster2;
lo_BEVRG_QTY=0;
lo_HAMBR_QTY=0;
lo_CHICK_QTY=0;		
lo_FRY_QTY=0;
lo_VALU_QTY=0;
lo_FRST_QTY=0;
lo_KID_QTY=0;
lo_SALD_QTY=0;
lo_BAKR_QTY=0;
lo_MEALDEAL_QTY=0;
if BEVRG_QTY>0 then lo_BEVRG_QTY=1;
if HAMBR_QTY>0 then lo_HAMBR_QTY=1;
if CHICK_QTY>0 then lo_CHICK_QTY=1;		
if FRY_QTY>0 then lo_FRY_QTY=1;
if VALU_QTY>0 then lo_VALU_QTY=1;
if FRST_QTY>0 then lo_FRST_QTY=1;
if KID_QTY>0 then lo_KID_QTY=1;
if SALD_QTY>0 then lo_SALD_QTY=1;
if BAKR_QTY>0 then lo_BAKR_QTY=1;
if MEALDEAL_QTY>0 then lo_MEALDEAL_QTY=1;

proc print data= utd.wenmbac2;
run;
proc logistic descending data= utd.wenmbac2;
model lo_BEVRG_QTY=

lo_HAMBR_QTY
lo_CHICK_QTY		
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac2;
model lo_HAMBR_QTY=
lo_BEVRG_QTY
lo_CHICK_QTY		
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac2;
model lo_CHICK_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac2;
model lo_FRY_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	

lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;

proc logistic descending data= utd.wenmbac2;
model lo_VALU_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY

lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac2;
model lo_FRST_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY

lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
**All observations have the same response.  No statistics are computed.;
proc logistic descending data= utd.wenmbac2;
model lo_KID_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY

lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac2;
model lo_SALD_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY

lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac2;
model lo_BAKR_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY

lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac2;
model lo_MEALDEAL_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
;
run;
*_________________________________________________________________________;

*mba: cluster3;
data utd.wenmbac3;
set utd.cluster3;
lo_BEVRG_QTY=0;
lo_HAMBR_QTY=0;
lo_CHICK_QTY=0;		
lo_FRY_QTY=0;
lo_VALU_QTY=0;
lo_FRST_QTY=0;
lo_KID_QTY=0;
lo_SALD_QTY=0;
lo_BAKR_QTY=0;
lo_MEALDEAL_QTY=0;
if BEVRG_QTY>0 then lo_BEVRG_QTY=1;
if HAMBR_QTY>0 then lo_HAMBR_QTY=1;
if CHICK_QTY>0 then lo_CHICK_QTY=1;		
if FRY_QTY>0 then lo_FRY_QTY=1;
if VALU_QTY>0 then lo_VALU_QTY=1;
if FRST_QTY>0 then lo_FRST_QTY=1;
if KID_QTY>0 then lo_KID_QTY=1;
if SALD_QTY>0 then lo_SALD_QTY=1;
if BAKR_QTY>0 then lo_BAKR_QTY=1;
if MEALDEAL_QTY>0 then lo_MEALDEAL_QTY=1;

proc print data= utd.wenmbac3;
run;
proc logistic descending data= utd.wenmbac3;
model lo_BEVRG_QTY=

lo_HAMBR_QTY
lo_CHICK_QTY		
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac3;
model lo_HAMBR_QTY=
lo_BEVRG_QTY
lo_CHICK_QTY		
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac3;
model lo_CHICK_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac3;
model lo_FRY_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	

lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;

proc logistic descending data= utd.wenmbac3;
model lo_VALU_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY

lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac3;
model lo_FRST_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY

lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
**All observations have the same response.  No statistics are computed.;
proc logistic descending data= utd.wenmbac3;
model lo_KID_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY

lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac3;
model lo_SALD_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY

lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac3;
model lo_BAKR_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY

lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac3;
model lo_MEALDEAL_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
;
run;

*_________________________________________________________________________;

*mba: cluster4;
data utd.wenmbac4;
set utd.cluster4;
lo_BEVRG_QTY=0;
lo_HAMBR_QTY=0;
lo_CHICK_QTY=0;		
lo_FRY_QTY=0;
lo_VALU_QTY=0;
lo_FRST_QTY=0;
lo_KID_QTY=0;
lo_SALD_QTY=0;
lo_BAKR_QTY=0;
lo_MEALDEAL_QTY=0;
if BEVRG_QTY>0 then lo_BEVRG_QTY=1;
if HAMBR_QTY>0 then lo_HAMBR_QTY=1;
if CHICK_QTY>0 then lo_CHICK_QTY=1;		
if FRY_QTY>0 then lo_FRY_QTY=1;
if VALU_QTY>0 then lo_VALU_QTY=1;
if FRST_QTY>0 then lo_FRST_QTY=1;
if KID_QTY>0 then lo_KID_QTY=1;
if SALD_QTY>0 then lo_SALD_QTY=1;
if BAKR_QTY>0 then lo_BAKR_QTY=1;
if MEALDEAL_QTY>0 then lo_MEALDEAL_QTY=1;

proc print data= utd.wenmbac4;
run;
proc logistic descending data= utd.wenmbac4;
model lo_BEVRG_QTY=

lo_HAMBR_QTY
lo_CHICK_QTY		
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac4;
model lo_HAMBR_QTY=
lo_BEVRG_QTY
lo_CHICK_QTY		
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac4;
model lo_CHICK_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac4;
model lo_FRY_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	

lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;

proc logistic descending data= utd.wenmbac4;
model lo_VALU_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY

lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac4;
model lo_FRST_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY

lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
**All observations have the same response.  No statistics are computed.;
proc logistic descending data= utd.wenmbac4;
model lo_KID_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY

lo_SALD_QTY
lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac4;
model lo_SALD_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY

lo_BAKR_QTY
lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac4;
model lo_BAKR_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY

lo_MEALDEAL_QTY;
run;
proc logistic descending data= utd.wenmbac4;
model lo_MEALDEAL_QTY=

lo_BEVRG_QTY
lo_HAMBR_QTY
lo_CHICK_QTY	
lo_FRY_QTY
lo_VALU_QTY
lo_FRST_QTY
lo_KID_QTY
lo_SALD_QTY
lo_BAKR_QTY
;
run;


