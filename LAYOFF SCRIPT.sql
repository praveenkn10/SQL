#create a table copy and delete the duplicates in table
CREATE TABLE layoffs1
LIKE layoffs;

INSERT layoffs1
SELECT *
FROM layoffs;

CREATE TABLE `layoffs2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  row_num int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs2
SELECT *, ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
FROM layoffs1
ORDER BY 1;

DELETE
FROM layoffs2
WHERE row_num >1;

# standardize table

UPDATE layoffs2
SET company = TRIM(company);

UPDATE layoffs2
SET `date` = STR_TO_DATE(`date`, "%m/%d/%Y");

ALTER TABLE layoffs2
MODIFY COLUMN `date` DATE;

UPDATE layoffs2
SET industry = 'Crypto'
WHERE industry like "Crypto%";

UPDATE layoffs
SET country = TRIM(trailing '.' FROM country);

# removing null vaules

DELETE
FROM layoffs2
WHERE total_laid_off is null and percentage_laid_off is null;

UPDATE layoffs2
SET industry = null
WHERE industry = '';

UPDATE layoffs2 a
JOIN layoffs2 b
	ON	a.company = b.company
    AND a.location = b.location
SET a.industry = b.industry
WHERE a.industry IS NULL AND
b.industry IS NOT NULL;

ALTER TABLE layoffs2
DROP COLUMN row_num;