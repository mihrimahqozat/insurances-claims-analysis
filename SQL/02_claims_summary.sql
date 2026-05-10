-- Overall claims summary by incident type and severity
WITH claims_summary AS (
    SELECT
        incident_type,
        incident_severity,
        COUNT(policy_number)                               AS total_claims,
        ROUND(AVG(total_claim_amount)::NUMERIC, 2)         AS avg_claim_amount,
        ROUND(SUM(total_claim_amount)::NUMERIC, 2)         AS total_claim_value,
        ROUND(AVG(injury_claim)::NUMERIC, 2)               AS avg_injury_claim,
        ROUND(AVG(property_claim)::NUMERIC, 2)             AS avg_property_claim,
        ROUND(AVG(vehicle_claim)::NUMERIC, 2)              AS avg_vehicle_claim,
        COUNT(CASE WHEN fraud_reported = 'Y' THEN 1 END)   AS fraud_count
    FROM claims
    GROUP BY 
		incident_type, 
		incident_severity
)
SELECT *,
    ROUND(fraud_count * 100.0 / NULLIF(total_claims, 0), 2) AS fraud_rate_pct,
    RANK() OVER (ORDER BY total_claim_value DESC)           AS value_rank
FROM claims_summary
ORDER BY total_claim_value DESC;