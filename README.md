# Layoffs Data Analysis

## Project Overview
This project focuses on cleaning and analyzing a dataset related to global layoffs between March 2020 and March 2023. The dataset includes layoff data from 1,622 companies. The goal was to analyze periods of significant layoffs and identify the industries, companies, and countries most affected worldwide. Additional correlations between layoffs, company size, and funding stage were also examined. Key findings and insights were visualized using Power BI.

## Dataset
The dataset contains information about layoffs in various companies, including:
- Company name
- Industry
- Location
- Number of employees laid off
- Percentage of workforce affected
- Date of layoffs
- Investment funding (in millions)

## Data Cleaning Process
The data cleaning process was conducted using **Microsoft SQL Server** and included the following steps:

1. Removing duplicates
2. Standardizing data
3. Handling NULL and blank values
4. Adjusting data types
5. Removing unwanted records

## Exploratory Data Analysis (EDA)
After cleaning, an exploratory data analysis (EDA) was performed to identify key trends and patterns in the dataset. This included mainly:
- Checking overall trends in layoffs over time
- Identifying companies and industries most affected by layoffs
- Examining geographic distribution of layoffs

## Power BI Visualization - key findings
Last step in this project was to create dashboard in Power BI to visualize key insights. This includes charts and KPIs highlighting trends in layoffs across industries, countries, and time periods. The repository includes a .pdf file with a static dashboard preview and a .pbix file for an interactive experience.

# Layoff Trends Over Time
The largest waves of layoffs occurred in 2020, peaking in May and July, followed by another significant wave in November. The highest peak was observed at the beginning of 2023.
Across all three years, layoffs were most frequent in the first and last quarters, particularly in January and November.
# Most Affected Industries
The industries most affected by layoffs across the entire period were retail, consumer, transportation, and finance. In 2020, the transportation and travel industries were hit hardest, likely due to the COVID-19 pandemic and global lockdowns. In 2023, which saw the highest number of laid-off employees, layoffs were spread across various industries rather than concentrated in a few.
# Companies with the Highest Layoffs
Amazon had the highest number of layoffs in absolute terms, though this represented only 3% of its workforce.
Many smaller companies shut down entirely, with 115 companies ceasing operations, the majority in late 2022.
On average, 25% of employees were laid off across all analyzed companies in this period. Almost half of the analyzed companies laid off no more than 20% of their workforce, while around one-third laid off between 20-40%.
# Company Size and Funding Stage
Layoffs were most severe among early-stage companies (Seed) and smaller firms (Stages A-C) in terms of the number of companies affected. Larger, more financially stable companies, particularly those in the Acquired and Post-IPO stages, were less affected in terms of the proportion of employees laid off. 
However, in absolute numbers, Post-IPO companies saw the highest total number of layoffs.
# Geographic Distribution
The United States experienced the highest number of layoffs—significantly more than any other country.

# Data Completeness and Limitations:
Some columns contained missing values:
378 missing values in total_laid_off
423 missing values in percentage_laid_off
While these missing values did not significantly impact major trends, they should still be considered when interpreting the results. The dataset is sourced from third-party data, meaning that additional validation or direct access to company HR records could improve accuracy in a real-world business setting.

## Tools Used
- **Microsoft SQL Server** – Data cleaning and preparation
- **Power BI** (Desktop version) – Data visualization and dashboard creation

## Repository Structure
- `layoffs_data.csv` - source data file
- `data_cleaning.sql` – SQL script for data cleaning
- `exploratory_data_analysis.sql` – SQL queries for exploratory data analysis
- `layoffs_dashboard_power_bi.pbix` - file with fully interactive dashboard
- `layoffs_dashboard_power_bi.pdf` - static file for quick dashborad overview
- `README.md` – Project documentation

## Author
This project was conducted as part of my portfolio to demonstrate SQL data cleaning, exploratory analysis, and visualization skills.


