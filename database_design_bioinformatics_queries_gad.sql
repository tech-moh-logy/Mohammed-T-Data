show variables where variable_name like '%local%';
set global local_infile=ON;
DROP DATABASE IF EXISTS gad;
CREATE DATABASE gad;

USE gad;

DROP TABLE IF EXISTS gad;
CREATE TABLE gad (

gad_id int,
association text,
phenotype text,
disease_class text,
chromosome text,
chromosome_band text,
dna_start long,
dna_end long,
gene text,
gene_name text,
reference text,
pubmed_id int,
year int, 
population text);

LOAD DATA LOCAL 
INFILE 'C:\\Users\\maria\\Downloads\\gad.csv'
INTO TABLE gad
FIELDS TERMINATED BY "," 
OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS;

SELECT count(*) from gad;
SELECT * FROM gad;



use gad;
-- 1.
-- Explore the content of the various columns in your gad table.
-- List all genes that are "G protein-coupled" receptors in alphabetical order by gene symbol
-- Output the gene symbol, gene name, and chromosome
-- (These genes are often the target for new drugs, so are of particular interest)
SELECT gene, gene_name, chromosome
FROM gad 
WHERE gene_name LIKE '%G protein-coupled%'
ORDER BY gene_name;

-- 2.
-- How many records are there for each disease class?
-- Output your list from most frequent to least frequent
SELECT disease_class, COUNT(*) AS record_count
FROM gad
GROUP BY disease_class
ORDER BY record_count;

-- 3.
-- List all distinct phenotypes related to the disease class "IMMUNE"
-- Output your list in alphabetical order
SELECT DISTINCT phenotype
FROM gad
WHERE disease_class = 'IMMUNE'
ORDER BY phenotype;

-- 4.
-- Show the immune-related phenotypes
-- based on the number of records reporting a positive association with that phenotype.
-- Display both the phenotype and the number of records with a positive association
-- Only report phenotypes with at least 60 records reporting a positive association.
-- Your list should be sorted in descending order by number of records
-- Use a column alias: "num_records"
SELECT phenotype,
       COUNT(*) AS num_records
FROM gad
WHERE disease_class = 'IMMUNE' AND association = 'Y'
GROUP BY phenotype
HAVING num_records >= 60
ORDER BY num_records;

-- 5.
-- List the gene symbol, gene name, and chromosome attributes related
-- to genes positively linked to asthma (association = Y).
-- Include in your output any phenotype containing the substring "asthma"
-- List each distinct record once
-- Sort gene symbol
SELECT DISTINCT gene, gene_name, chromosome
FROM gad
WHERE (association = 'Y' AND phenotype LIKE '%asthma%')
ORDER BY gene;

-- 6.
-- For each chromosome, over what range of nucleotides do we find
-- genes mentioned in GAD?
-- Exclude cases where the dna_start value is 0 or where the chromosome is unlisted.
-- Sort your data by chromosome. Don't be concerned that
-- the chromosome values are TEXT. (1, 10, 11, 12, ...)
SELECT chromosome,
       MIN(dna_start),
       MAX(dna_end)
FROM gad
WHERE dna_start != 0 AND chromosome != 'unlisted'
GROUP BY chromosome
ORDER BY CAST(chromosome AS UNSIGNED);

-- 7
-- For each gene, what is the earliest and latest reported year
-- involving a positive association
-- Ignore records where the year isn't valid. (Explore the year column to determine
-- what constitutes a valid year.)
-- Output the gene, min-year, max-year, and number of GAD records
-- order from most records to least.
-- Columns with aggregation functions should be aliased
SELECT gene,
       MIN(year),
       MAX(year),
       COUNT(*) AS num_records
FROM gad
WHERE association = 'Y' AND year > 1900
GROUP BY gene
ORDER BY num_records;

-- 8.
-- Which genes have a total of at least 100 positive association records (across
-- all phenotypes)?
-- Give the gene symbol, gene name, and the number of associations
-- Use a 'num_records' alias in your query wherever possible
SELECT  gene,
       gene_name,
       SUM(CASE WHEN association = 'Y' THEN 1 ELSE 0 END) AS num_records
FROM gad
GROUP BY gene, gene_name
HAVING num_records >= 100
ORDER BY num_records;

-- 9.
-- How many total GAD records are there for each population group?
-- Sort in descending order by count
-- Show only the top five results based on number of records
-- Do NOT include cases where the population is blank
SELECT population,
       COUNT(*) AS record_count
FROM gad
WHERE population != ''
GROUP BY population
ORDER BY record_count DESC
LIMIT 5;

-- 10.
-- In question 5, we found asthma-linked genes
-- But these genes might also be implicated in other diseases
-- Output gad records involving a positive association between ANY asthma-linked
-- gene and ANY disease/phenotype
-- Sort your output alphabetically by phenotype
-- Output the gene, gene_name, association (should always be 'Y'), phenotype,
-- disease_class, and population
-- Hint: Use a subselect in your WHERE class and the IN operator
SELECT gene,
       gene_name,
       association,
       phenotype,
       disease_class,
       population
FROM gad
WHERE phenotype IN (
    SELECT DISTINCT phenotype
    FROM gad
    WHERE phenotype LIKE '%asthma%'
)
AND association = 'Y'
ORDER BY phenotype;

-- 11.
-- Modify your previous query.
-- Let's count how many times each of these asthma-gene-linked phenotypes occurs
-- in our output table produced by the previous query.
-- Output just the phenotype, and a count of the number of occurrences for the top
-- 5 phenotypes
-- with the most records involving an asthma-linked gene (EXCLUDING asthma itself).
SELECT phenotype,
       COUNT(*) AS occurrence_count
FROM (
    SELECT DISTINCT phenotype
    FROM gad
    WHERE gene IN (
        SELECT DISTINCT gene
        FROM gad
        WHERE phenotype LIKE '%asthma%'
    )
    AND association = 'Y'
) AS subquery
GROUP BY phenotype
ORDER BY occurrence_count DESC
LIMIT 5;

-- 12.
-- Interpret your analysis
-- a) Search the Internet. Does existing biomedical research support a connection
-- between asthma and the
-- top phenotype you identified above? Cite some sources and justify your
-- conclusion!
-- 
-- Existing biomedical research supports a strong connection between asthma and 
-- allergic rhinitis (hay fever). Both conditions often coexist, 
-- and studies have shown that individuals with one condition are at a higher risk of developing the other. 
-- This relationship is supported by research articles and clinical guidelines.


-- citation: 
-- Mayo Clinic Staff. (n.d.). Allergies and asthma. Mayo Clinic. 
-- https://www.mayoclinic.org/diseases-conditions/asthma/in-depth/allergies-and-asthma/art-20047458#
-- :~:text=Allergies%20and%20asthma%20often%20occur,allergies%20can%20cause%20asthma%20symptoms.

-- b) Why might a drug company be interested in instances of such "overlapping"
-- phenotypes?

-- Drug companies may be interested in overlapping phenotypes because they suggest 
-- shared underlying biological mechanisms. Developing drugs that target multiple related 
-- conditions can be more cost-effective and improve patient outcomes. Addressing comorbid conditions 
-- can enhance patient quality of life and adherence to treatments, leading to improved outcomes and potential cost savings.
