/* DATA CLEANING PROCESS */

USE layoffs_database;

SELECT * 
FROM layoffs_data_world;

/* =====================================================
STEP 1: Remove duplicates
===================================================== */

/* create staging table to avoid removing raw data */
SELECT * 
INTO layoffs_staging 
FROM layoffs_data_world;

/* identify duplicate records based on key columns and remove them */
WITH duplicates AS (
	SELECT *,
	   ROW_NUMBER() OVER(
			PARTITION BY 
				company
				, location
				, industry
				, total_laid_off
	         , percentage_laid_off
				, date
				, stage
				, country
				, funds_raised_millions 
	      ORDER BY company
			) AS row_num
	FROM layoffs_staging
)
DELETE FROM layoffs_staging
WHERE EXISTS (
	SELECT company
	FROM duplicates d
	WHERE d.row_num > 1 AND d.company = layoffs_staging.company
);

/* =====================================================
STEP 2: Standardize the data 
===================================================== */

SELECT DISTINCT company 
FROM layoffs_staging;

SELECT * 
FROM layoffs_staging 
WHERE company = 'Oda';

/* one record needs to be updated (country name) */
UPDATE layoffs_staging
SET country = 'Norway'
WHERE company = 'Oda' AND funds_raised_millions = 377;

/* trim unwanted spaces */
UPDATE layoffs_staging
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging
ORDER BY industry;

SELECT DISTINCT industry
FROM layoffs_staging
WHERE industry LIKE('Crypto%');

/* unify industry names */
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT * 
FROM layoffs_staging 
WHERE country LIKE 'United States%';

/* remove trailing dots from country names */
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging
ORDER BY 1;

UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

/* fix date types (nvarchar instead of date) */
SELECT DISTINCT date, CONVERT(DATE, LTRIM(RTRIM(date)))
FROM layoffs_staging;

/* check up problem with converting date column format */
SELECT * 
FROM layoffs_staging 
WHERE TRY_CONVERT(DATE, LTRIM(RTRIM(date))) IS NULL AND date IS NOT NULL;

/* looks like the is string NULL instead of proper NULL value in one row */
SELECT date, COUNT(*)
FROM layoffs_staging
WHERE date = 'NULL'
GROUP BY date;

/* for now change that to real NULL value for the whole column date type conversion to work 
(unfortunately in this column NULL values are not allowed) */
UPDATE layoffs_staging
SET date = ''
WHERE date = 'NULL';

ALTER TABLE layoffs_staging
ALTER COLUMN date DATE NULL;

UPDATE layoffs_staging
SET date = CONVERT(DATE, LTRIM(RTRIM(date)));

ALTER TABLE layoffs_staging
ALTER COLUMN date DATE;

/* =====================================================
STEP 3: Handle NULL/blank values (many NULL values are 'NULL' values here because of source file)
======================================================== */

/* identify rows useless for analysis */
SELECT * FROM layoffs_staging
WHERE total_laid_off = 'NULL' AND percentage_laid_off = 'NULL';

/* convert 'NULL' and empty strings to actual NULL values in the industry column */
SELECT *
FROM layoffs_staging
WHERE industry = '' OR industry = 'NULL' OR industry IS NULL;

SELECT * 
FROM layoffs_staging 
WHERE company = 'Airbnb';

UPDATE layoffs_staging
SET industry = NULL
WHERE industry = 'NULL' OR industry = '';

/* fill missing industry values based on the same company */
SELECT * 
FROM layoffs_staging t1
JOIN layoffs_staging t2
	ON t1.company = t2.company 
	WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging t1
JOIN layoffs_staging t2 
	ON t1.company = t2.company
	WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

SELECT * 
FROM layoffs_staging
WHERE industry IS NULL;

/* only one company left with NULL value in the industry column */
SELECT * 
FROM layoffs_staging 
WHERE company = 'Bally''s Interactive';

/* change 'NULL' to real NULL values */
UPDATE layoffs_staging
SET total_laid_off = NULL
WHERE total_laid_off = 'NULL' OR total_laid_off = '';

UPDATE layoffs_staging
SET percentage_laid_off = NULL
WHERE percentage_laid_off = 'NULL' OR percentage_laid_off = '';

UPDATE layoffs_staging
SET stage = NULL
WHERE stage = 'NULL' OR stage = '';

UPDATE layoffs_staging
SET funds_raised_millions = NULL
WHERE funds_raised_millions = 'NULL' OR funds_raised_millions = '';

/* other data type changes */
ALTER TABLE  layoffs_staging
ALTER COLUMN total_laid_off INT;

ALTER TABLE layoffs_staging  
ALTER COLUMN percentage_laid_off DECIMAL(5,2);

ALTER TABLE  layoffs_staging
ALTER COLUMN funds_raised_millions DECIMAL(10,2);

/* fix for stage column to unify records where stage is unknown */
UPDATE layoffs_staging
SET stage = 'Unknown'
WHERE stage = 'NULL';

/* =====================================================
STEP 4: Remove unwanted rows
===================================================== */

DELETE
FROM layoffs_staging
WHERE total_laid_off = 'NULL' AND percentage_laid_off = 'NULL';