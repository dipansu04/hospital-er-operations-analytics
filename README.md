# Hospital ER Operations & Patient Flow Analytics

## Overview
This project analyzes Emergency Room (ER) operational data to identify
**wait-time bottlenecks, peak congestion periods, and department-level
contributors to delays** using **PostgreSQL** and **Power BI**.

The objective is to transform raw hospital visit data into
**decision-ready operational insights** that can support:
- staffing optimization
- department prioritization
- patient flow improvement

---

## Dataset
- Source: Hospital ER operational dataset (CSV)
- Volume: **9,216 ER visits**
- Core entities:
  - Patient visits
  - Departments
  - Admission timestamps
  - Wait times
  - Referral and admission indicators

---

## Tools & Technologies
- **PostgreSQL**
  - Data cleaning and modeling
  - Aggregations and joins
  - Window functions (`dense_rank`, `over`)
  - Percentiles (`percentile_cont`)
  - Time-based analysis
- **Power BI**
  - KPI reporting
  - Operational dashboards
  - Slicers for focused analysis
  - Executive-level visual storytelling

---

## Business Questions
- What is the average ER wait time and total visit volume?
- What percentage of patients wait more than 30 minutes?
- Which hours experience the highest congestion?
- When do patient arrivals peak?
- Which departments have the highest average wait times?
- Which departments contribute most to total system delay?
- Do admitted patients wait longer than discharged patients?
- Do referred patients experience longer waits?
- How severe are delays for the worst-served patients?

---

## Analysis & Key Insights

### Overall ER Performance
The ER handled **9,216 visits** with an **average wait time of 35.26 minutes**.
Notably, **59.32% of patients waited more than 30 minutes**, indicating that
extended waits are a **system-wide issue rather than isolated incidents**.

---

### Time-Based Congestion
- The **highest average wait time** occurs at **03:00 (37.22 minutes)**.
- **Patient arrivals peak at 23:00 (436 visits)**.

This mismatch shows that **congestion is not driven purely by volume**.
Instead, overnight delays likely stem from **staffing coverage gaps or
process inefficiencies**, suggesting targeted operational adjustments rather
than uniform staffing increases.

---

### Department-Level Bottlenecks
Departments such as **Neurology** and **Physiotherapy** show the **highest
average wait times**, marginally above the ER average.

However, **total system impact tells a different story**:
- **General Practice contributes 47.81% of total ER waiting time**
- **Orthopedics contributes 25.90%**

This highlights that **high-volume departments can drive most delays even when
their average wait times are moderate**, making them the highest-leverage
targets for improvement.

---

### Admission & Referral Flow
- Admitted and non-admitted patients experience **similar wait times**
  (≈35 minutes), indicating consistent triage handling.
- Referred and non-referred patients also show **nearly identical wait times**,
  suggesting that referral handoffs are **not a primary delay driver**.

---

### Service Inequality
While overall averages remain stable, a subset of patients experiences
**disproportionately long waits**, indicating service inequality.
Addressing these extreme cases could significantly improve patient experience
without requiring system-wide changes.

---

## Dashboard Summary
An **Executive ER Operations Dashboard** was built in Power BI to visualize:
- Core ER performance KPIs
- Hourly congestion and arrival patterns
- Department-level bottlenecks and system impact
- Referral-based flow comparison

The dashboard is designed for **hospital operations leaders** to quickly
identify:
- where delays originate
- when congestion occurs
- which departments drive system-wide waiting time

---

## Outcome
This project demonstrates the ability to:
- apply advanced SQL to real-world healthcare data
- distinguish between average performance and system-wide impact
- design executive-ready dashboards
- prioritize **decision-relevant analytics over exploratory noise**
