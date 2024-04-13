cd /Users/henryandrus/Stata/388Data3

// Clean chat data
use chat, clear
drop if year < 1970 | year > 2000
destring railline ship_all ship_steammotor shipton_steammotor shipton_all, replace
rename country_name country

// rename countries so it is suitable for merging
replace country = "Bolivia (Plurinational State of)" if country == "Bolivia"
replace country = "Bosnia and Herzegovina" if country == "Bosnia-Herzegovina"
replace country = "Myanmar" if country == "Burma"
replace country = "Congo" if country == "Republic of the Congo"
replace country = "Côte d'Ivoire" if country == "Ivory Coast"
replace country = "D.R. of the Congo" if country == "Democratic Republic of the Congo"
replace country = "Eswatini" if country == "Swaziland"
replace country = "China, Hong Kong SAR" if country == "Hong Kong"
replace country = "Iran (Islamic Republic of)" if country == "Iran"
replace country = "Lao People's DR" if country == "Laos"
replace country = "North Macedonia" if country == "Macedonia"
replace country = "Republic of Moldova" if country == "Moldova"
replace country = "Russian Federation" if country == "Russia"
replace country = "Republic of Korea" if country == "South Korea"
replace country = "Syrian Arab Republic" if country == "Syria"
replace country = "U.R. of Tanzania: Mainland" if country == "Tanzania"
replace country = "Venezuela (Bolivarian Republic of)" if country == "Venezuala"
replace country = "Viet Nam" if country == "Vietnam"
replace country = "Slovakia" if country == "Slovak Republic"

// merge data set
merge 1:1 country year using pwt1001 
drop if _merge == 1 | _merge ==2
drop _merge
drop countrycode-rgdpo ccon-cwtfp rconna-delta pl_con-pl_k

// create developed countries dummies and gdp per capita variables
gen gdpcap = rgdpna/pop

gen developed = .
replace developed = 1 if (country == "Germany" | country == "France" | country == "Italy" | country == "Japan" | country == "United Kingdom" | country == "United States")
replace developed = 0 if developed == .


// create growth variables
local my_vars ag_harvester ag_milkingmachine ag_tractor atm aviationpkm aviationtkm bed_acute bed_hosp bed_longterm cabletv cellphone cheque computer creditdebit eft elecprod fert_total internetuser irrigatedarea kidney_dialpat kidney_homedialpat loom_auto loom_total mail med_catscanner med_lithotriptor med_mammograph med_mriunit med_radiationequip newspaper pctdaysurg_cataract pctdaysurg_cholecyst pctdaysurg_hernia pctdaysurg_lapcholecyst pctdaysurg_tonsil pctdaysurg_varicosevein pcthomedialysis pctimmunizdpt pctimmunizmeas pctirrigated pctmvbyarea pest_total pos radio railline railp railpkm railt railtkm ship_all ship_motor ship_sail ship_steam ship_steammotor shipton_all shipton_motor shipton_sail shipton_steam shipton_steammotor spindle_mule spindle_ring steel_acidbess steel_basicbess steel_bof steel_eaf steel_ohf steel_other steel_stainless surg_appendectomy surg_breastcnsv surg_cardcath surg_cataract surg_cholecyst surg_corbypass surg_corinterven surg_corstent surg_csection surg_hernia surg_hipreplace surg_hysterectomy surg_kneereplace surg_lapcholecyst surg_mastectomy surg_pacemaker surg_prostatetrans surg_prostatextrans surg_tonsil surg_varicosevein telegram telephone transplant_bonemarrow transplant_heart transplant_kidney transplant_liver transplant_lung tv txtlmat_artif txtlmat_otherraw txtlmat_synth txtlmat_totalraw vehicle_car vehicle_com visitorbeds visitorrooms xlpopulation xlrealgdp pctivprimeenroll pctivsecenroll pctivprivateinv pctivpublicinv pctivliteracy pop emp avh hc xr rgdpna gdpcap

reshape wide `my_vars', i(country) j(year)

forvalues i=1971/2000 {
	local j=`i'-1
	generate gdpcapgrowth`i' = ((gdpcap`i'/gdpcap`j') - 1)*100
}

forvalues i=1971/2000 {
	local j=`i'-1
	generate ag_tractorgrowth`i' = ((ag_tractor`i'/ag_tractor`j') - 1)*100
} //25ish

forvalues i=1971/2000 {
	local j=`i'-1
	generate elecprodgrowth`i' = ((elecprod`i'/elecprod`j') - 1)*100
} //max 62

forvalues i=1971/2000 {
	local j=`i'-1
	generate newspapergrowth`i' = ((newspaper`i'/newspaper`j') - 1)*100
} //max 45 missing (last year has 149 tho)

forvalues i=1971/2000 {
	local j=`i'-1
	generate pctimmunizdptgrowth`i' = ((pctimmunizdpt`i'/pctimmunizdpt`j') - 1)*100
} //less missing at the end

forvalues i=1971/2000 {
	local j=`i'-1
	generate radiogrowth`i' = ((radio`i'/radio`j') - 1)*100
} //most is 32 missing values, not bad

forvalues i=1971/2000 {
	local j=`i'-1
	generate telephonegrowth`i' = ((telephone`i'/telephone`j') - 1)*100
} //concave ~70

forvalues i=1971/2000 {
	local j=`i'-1
	generate tvgrowth`i' = ((tv`i'/tv`j') - 1)*100
} //not bad near end

forvalues i=1971/2000 {
	local j=`i'-1
	generate visitorroomsgrowth`i' = ((visitorrooms`i'/visitorrooms`j') - 1)*100
} //max 50-60 near end

forvalues i=1971/2000 {
	local j=`i'-1
	generate pctirrigatedgrowth`i' = ((pctirrigated`i'/pctirrigated`j') - 1)*100
} //max 50-60 near end

forvalues i=1971/2000 {
	local j=`i'-1
	generate computerg`i' = ((computer`i'/computer`j') - 1)*100
} //lots missing

forvalues i=1971/2000 {
	local j=`i'-1
	generate fert_totalg`i' = ((fert_total`i'/fert_total`j') - 1)*100
} //max 50-60 near end

forvalues i=1971/2000 {
	local j=`i'-1
	generate raillineg`i' = ((railline`i'/railline`j') - 1)*100
} //max 50-60 near end


reshape long `my_vars' gdpcapgrowth ag_tractorgrowth elecprodgrowth newspapergrowth pctimmunizdptgrowth radiogrowth telephonegrowth tvgrowth visitorroomsgrowth pctirrigatedgrowth computerg fert_totalg raillineg, i(country) j(year)

// Running regression

encode country, generate(country_id)
xtset country_id year

xtreg gdpcapgrowth visitorroomsgrowth  elecprodgrowth radiogrowth pctimmunizdptgrowth ag_tractorgrowth pop avh xr, fe

// Summary statistics for tech variables
gen elecprodthousand = (elecprod/1000000)
summ rgdpna gdpcap visitorrooms elecprodthousand radio pctimmunizdpt ag_tractor

// Collapse data, run line plots on gdpgrowth, visitorroomsgrowth, elecprodgrowth, radiogrowth, ag_tractorgrowth
preserve
collapse rgdpna gdpcap gdpcapgrowth visitorrooms visitorroomsgrowth elecprod elecprodgrowth radio radiogrowth pctimmunizdpt pctimmunizdptgrowth ag_tractor ag_tractorgrowth [aweight=pop], by(developed year)

// Summary statistics for growth variables developed vs. developing
by developed: summ gdpcap gdpcapgrowth visitorroomsgrowth elecprodgrowth radiogrowth pctimmunizdptgrowth ag_tractorgrowth
by developed: summ visitorrooms elecprod radio pctimmunizdpt ag_tractor


// Producing graphs
twoway (line gdpcapgrowth year if developed==1, lcolor(blue)) (line gdpcapgrowth year if developed==0, lcolor(red))

twoway (line visitorroomsgrowth year if developed==1 & visitorroomsgrowth < 60) (line elecprodgrowth year if developed==1) (line radiogrowth year if developed==1) (line pctimmunizdptgrowth year if developed==1 & pctimmunizdptgrowth < 50) (line ag_tractorgrowth year if developed==1)

twoway (line visitorroomsgrowth year if developed==0 & visitorroomsgrowth < 60) (line elecprodgrowth year if developed==0) (line radiogrowth year if developed==0) (line pctimmunizdptgrowth year if developed==0 & pctimmunizdptgrowth < 50) (line ag_tractorgrowth year if developed==0)
restore

// Collapse not by developed/developing
collapse rgdpna gdpcap gdpcapgrowth visitorrooms visitorroomsgrowth elecprod elecprodgrowth radio radiogrowth pctimmunizdpt pctimmunizdptgrowth ag_tractor ag_tractorgrowth [aweight=pop], by(year)

// Generate plots for whole collapsed dataset
line gdpcapgrowth year

twoway (line visitorroomsgrowth year if visitorroomsgrowth < 60) (line elecprodgrowth year) (line radiogrowth year) (line pctimmunizdptgrowth year) (line ag_tractorgrowth year)
