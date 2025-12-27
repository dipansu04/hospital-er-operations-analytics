--=====================================================
-- hospital-er-operations-analytics
--=====================================================



--staging table

create table staging_er_data (
    patient_id varchar,
    patient_admission_date varchar,
    patient_first_initial varchar,
    patient_last_name varchar,
    patient_gender varchar,
    patient_age int,
    patient_race varchar,
    department_referral varchar,
    patient_admission_flag boolean,
    patient_satisfaction_score int,
    patient_waittime int,
    patients_cm int);



--patients dimension table

create table patients (
    patient_id varchar primary key,
    patient_gender varchar(10),
    patient_age int,
    patient_race varchar(50)
);


insert into patients (patient_id, patient_gender, patient_age, patient_race)
select distinct
    patient_id,
    patient_gender,
    patient_age,
    patient_race
from staging_er_data;



--departments dimension table

create table departments (
    department_id serial primary key,
    department_name varchar(100) unique
);


insert into departments (department_name)
select distinct department_referral
from staging_er_data
where department_referral is not null
  and department_referral <> 'none'
  and department_referral <> '';


--visits fact table

create table visits (
    visit_id serial primary key,
    patient_id varchar references patients(patient_id),
    department_id int references departments(department_id),
    admission_time timestamp,
    wait_time_minutes int,
    admission_flag boolean,
    satisfaction_score int,
    patients_cm int
);


insert into visits (
    patient_id,
    department_id,
    admission_time,
    wait_time_minutes,
    admission_flag,
    satisfaction_score,
    patients_cm
)
select
    s.patient_id,
    d.department_id,
    to_timestamp(s.patient_admission_date, 'dd-mm-yyyy hh24:mi'),
    s.patient_waittime,
    s.patient_admission_flag,
    s.patient_satisfaction_score,
    s.patients_cm
from staging_er_data s
left join departments d
    on s.department_referral = d.department_name;


--indexes (performance optimization)

create index idx_visits_admission_time on visits(admission_time);
create index idx_visits_department on visits(department_id);
create index idx_visits_wait_time on visits(wait_time_minutes);

--===================================================== 

--analysis section: core hospital operations questions

--===================================================== 


--q1: what is the average patient wait time and total number of er visits?

SELECT count(*) AS total_visits
	,round(avg(wait_time_minutes), 2) AS avg_wait_time
FROM visits
WHERE wait_time_minutes IS NOT NULL;


--q2: what percentage of patients waited more than 30 minutes?

SELECT count(*) AS total_visits
	,count(*) filter(WHERE wait_time_minutes > 30) AS visits_over_30_min
	,round(100.0 * count(*) filter(WHERE wait_time_minutes > 30) / count(*), 2) AS pct_over_30_min
FROM visits
WHERE wait_time_minutes IS NOT NULL;


--q3: which hour of the day has the highest average patient wait time?

SELECT extract(hour FROM admission_time) AS hour_of_day
	,round(avg(wait_time_minutes), 2) AS avg_wait_time
FROM visits
WHERE wait_time_minutes IS NOT NULL
GROUP BY hour_of_day
ORDER BY avg_wait_time DESC limit 1;


--q4:which hour of the day has the highest number of patient arrivals?

SELECT extract(hour FROM admission_time) AS hour_of_day
	,count(*) AS patient_arrivals
FROM visits
GROUP BY hour_of_day
ORDER BY patient_arrivals DESC limit 1;


-- q5: which departments have the highest average patient wait time?

SELECT d.department_name
	,round(avg(v.wait_time_minutes), 2) AS avg_wait_time
FROM visits v
INNER JOIN departments d ON v.department_id = d.department_id
WHERE v.wait_time_minutes IS NOT NULL
GROUP BY d.department_name
ORDER BY avg_wait_time DESC;


-- q6: which departments contribute the most to total system waiting time?

SELECT d.department_name
	,sum(v.wait_time_minutes) AS total_wait_time
FROM visits v
INNER JOIN departments d ON v.department_id = d.department_id
WHERE v.wait_time_minutes IS NOT NULL
GROUP BY d.department_name
ORDER BY total_wait_time DESC;


-- q7: do admitted patients wait longer than discharged patients?

SELECT admission_flag
	,count(*) AS total_visits
	,round(avg(wait_time_minutes), 2) AS avg_wait_time
FROM visits
WHERE wait_time_minutes IS NOT NULL
GROUP BY admission_flag;


-- q8: do patients with a department referral wait longer than those without a referral?

SELECT CASE 
		WHEN department_id IS NULL
			THEN 'no referral'
		ELSE 'referred'
		END AS referral_status
	,count(*) AS total_visits
	,round(avg(wait_time_minutes), 2) AS avg_wait_time
FROM visits
WHERE wait_time_minutes IS NOT NULL
GROUP BY referral_status
ORDER BY avg_wait_time DESC;


-- q9: Which departments rank highest based on average patient wait time?

SELECT d.department_name
	,round(avg(v.wait_time_minutes), 2) avg_wait_time
	,dense_rank() OVER (
		ORDER BY round(avg(v.wait_time_minutes), 2) DESC
		) AS wait_rank
FROM visits v
INNER JOIN departments d ON v.department_id = d.department_id
GROUP BY d.department_name;


-- q10: What percentage of total system waiting time does each department contribute?

SELECT department_name
	,total_wait_time
	,round(100.0 * total_wait_time / sum(total_wait_time) OVER (), 2) AS pct_of_system_wait
FROM (
	SELECT d.department_name
		,sum(v.wait_time_minutes) total_wait_time
	FROM visits v
	INNER JOIN departments d ON v.department_id = d.department_id
	GROUP BY d.department_name
	) s
ORDER BY pct_of_system_wait DESC;


-- q11: Rank each hour of the day by average patient wait time.

SELECT hours
	,avg_wait_time
	,dense_rank() OVER (
		ORDER BY avg_wait_time DESC
		) AS wait_time_rank
FROM (
	SELECT extract(hour FROM admission_time) AS hours
		,round(avg(wait_time_minutes), 2) avg_wait_time
	FROM visits
	GROUP BY hours
	) s
ORDER BY wait_time_rank;


-- q12: How much longer do the worst 10% of patients wait compared to the median patient?

SELECT median_wait
	,p_90_min
	,p_90_min - median_wait wait_time_gap
FROM (
	SELECT percentile_cont(.5) within
	GROUP (
			ORDER BY wait_time_minutes
			) median_wait
		,percentile_cont(.9) within
	GROUP (
			ORDER BY wait_time_minutes
			) p_90_min
	FROM visits
	) s;






























