/* EXPLORATORY DATA ANALYSIS */

USE layoffs_database;

SELECT 
	company
	, MAX(total_laid_off)
	, MAX(percentage_laid_off)
	, MAX(funds_raised_millions) 
FROM layoffs_staging
GROUP BY company
ORDER BY MAX(total_laid_off) DESC;

/* set month, year, quarter columns */
ALTER TABLE layoffs_staging
ADD 
	year INT
	, month INT 
	, quarter INT;

UPDATE layoffs_staging
SET 
	year = YEAR(date)
   , month = MONTH(date)
	, quarter = DATEPART(QUARTER, date)
WHERE date IS NOT NULL;

SELECT DISTINCT year 
FROM layoffs_staging;

/* check for incorrect date values (e.g., default '1900-01-01') */
SELECT * 
FROM layoffs_staging
WHERE year = 1900
ORDER BY year ASC;

/* fix incorrect year value */
DELETE
FROM layoffs_staging
WHERE date = '1900-01-01';

/* identify and count companies that laid off all employees */
SELECT company, percentage_laid_off
FROM layoffs_staging
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT COUNT(DISTINCT company)
FROM layoffs_staging
WHERE percentage_laid_off = 1;

/* top 100 companies (with > 100 employees) with 100% employees laid off */
ALTER TABLE layoffs_staging
ADD total_employees INT;

SELECT TOP 100 * 
FROM layoffs_staging 
WHERE percentage_laid_off = 1 AND total_employees > 100 
ORDER BY total_employees DESC;

/* top 10 companies with biggest percentage of employees laid off (but less than 100%) */
SELECT 
	TOP 10 company
	, AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging  
GROUP BY company  
HAVING AVG(percentage_laid_off) <> 1  
ORDER BY avg_percentage_laid_off DESC;

/* identify industries in which those companies operate */
SELECT 
	industry
	, COUNT(company) AS number_of_bankrupt_companies
FROM layoffs_staging
WHERE percentage_laid_off = 1
GROUP BY industry
ORDER BY number_of_bankrupt_companies DESC;

/* check the timeline of the dataset */
SELECT MIN(date), MAX(date)
FROM layoffs_staging;

/* aggregating total laid off according to industry, country, year, stage */
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY country
ORDER BY 2 DESC;

SELECT year, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY year
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging
GROUP BY stage
ORDER BY 1 DESC;

/* total amount of workers per company */
UPDATE layoffs_staging
SET total_employees = CAST(total_laid_off / NULLIF(percentage_laid_off, 0) AS INT)
WHERE total_laid_off IS NOT NULL AND percentage_laid_off IS NOT NULL;

/* calculate running total of layoffs over time */
WITH running_total_cte AS (
	SELECT 
		year
		, month
		, SUM(total_laid_off) AS sum_laid_off
	FROM layoffs_staging
	WHERE DATE IS NOT NULL
	GROUP BY year, month
)
SELECT 
	year
	, month
	, sum_laid_off
	, SUM(sum_laid_off) OVER(ORDER BY year, month) AS running_total
FROM running_total_cte;

/* layoffs per company */
SELECT 
	company
	,SUM(total_laid_off) AS sum_laid_off
FROM layoffs_staging
WHERE total_laid_off IS NOT NULL
GROUP BY company
ORDER BY sum_laid_off DESC;

/* top 5 companies with most layoffs per year */
WITH company_year AS (
	SELECT 
		company
		, industry
		, year
		, SUM(total_laid_off) AS sum_laid_off
	FROM layoffs_staging
	GROUP BY 
		company
		, industry
		, year
),
	company_year_ranking_cte AS (
	SELECT 
		*
		, DENSE_RANK() OVER(PARTITION BY year ORDER BY sum_laid_off DESC) AS ranking
	FROM company_year
)

SELECT 
	company
	, industry
	, year
	, sum_laid_off
	, ranking
FROM company_year_ranking_cte
WHERE ranking <= 5
ORDER BY year, ranking;

/* total layoffs by year and quarters */
SELECT 
	year
	, quarter
	, SUM(total_laid_off) AS sum_laid_off
FROM layoffs_staging
GROUP BY year, quarter
ORDER BY year, quarter;

/* layoffs change by months and years */
SELECT 
	year
	, month
	, SUM(total_laid_off) AS sum_laid_off
FROM layoffs_staging
GROUP BY year, month
ORDER BY year, month;

/* average layoffs per month */
SELECT month, AVG(total_laid_off) AS avg_laid_off
FROM layoffs_staging
GROUP BY month
ORDER BY month;

/* layoffs change according to previous month */
WITH monthly_layoffs AS (
	SELECT 
		year
		, month
		, SUM(total_laid_off) AS total_laid_off
	FROM layoffs_staging
	GROUP BY year, month
)
SELECT 
	year
	, month
	, total_laid_off
	, LAG(total_laid_off) OVER(ORDER BY year, month) AS prev_month_laid_off
	, total_laid_off - LAG(total_laid_off) OVER(ORDER BY year, month) AS change_from_prev_month
FROM monthly_layoffs;

/* number of blanks in key columns */
SELECT COUNT(*) AS blanks_in_total_laid_off
FROM layoffs_staging
WHERE total_laid_off IS NULL;

SELECT COUNT(*) AS blanks_in_percentage_laid_off
FROM layoffs_staging
WHERE percentage_laid_off IS NULL;

/* companies that have the most blanks in key columns*/
SELECT company, COUNT(*) AS null_count
FROM layoffs_staging
WHERE total_laid_off IS NULL
GROUP BY company
ORDER BY null_count DESC;

SELECT company, COUNT(*) AS null_count
FROM layoffs_staging
WHERE percentage_laid_off IS NULL
GROUP BY company
ORDER BY null_count DESC;

/* remove unnecessary columns (prior to importing table to POWER BI) */
ALTER TABLE layoffs_staging
DROP COLUMN year, month, quarter;