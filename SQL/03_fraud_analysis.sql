-- Fraud patterns by demographics and incident characteristics
WITH fraud_patterns AS (
    SELECT
        insured_education_level,
        insured_occupation,
        incident_type,
        authorities_contacted,
        police_report_available,
        COUNT(policy_number)                               AS total_claims,
        COUNT(CASE WHEN fraud_reported = 'Y' THEN 1 END)   AS fraud_claims,
        ROUND(AVG(total_claim_amount)::NUMERIC, 2)         AS avg_claim_amount,
        ROUND(AVG(witnesses)::NUMERIC, 2)                  AS avg_witnesses,
        ROUND(AVG(bodily_injuries)::NUMERIC, 2)            AS avg_bodily_injuries
    FROM claims
    GROUP BY 
		insured_education_level, 
		insured_occupation, 
		incident_type, 
		authorities_contacted, 
		police_report_available
)
SELECT *,
    ROUND(fraud_claims * 100.0 / NULLIF(total_claims, 0), 2) AS fraud_rate_pct,
    RANK() OVER (ORDER BY fraud_claims DESC)                 AS fraud_rank
FROM fraud_patterns
WHERE total_claims >= 2
ORDER BY fraud_rate_pct DESC;