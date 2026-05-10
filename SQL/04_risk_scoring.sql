-- Risk score per claim based on multiple fraud indicators
WITH risk_factors AS (
    SELECT
        policy_number,
        insured_occupation,
        incident_type,
        incident_severity,
        total_claim_amount,
        witnesses,
        bodily_injuries,
        police_report_available,
        authorities_contacted,
        fraud_reported,
		-- Assign risk points based on known fraud indicators
        CASE WHEN police_report_available = 'NO'        THEN 2 ELSE 0 END +
        CASE WHEN witnesses = 0                         THEN 2 ELSE 0 END +
        CASE WHEN bodily_injuries >= 2                  THEN 1 ELSE 0 END +
        CASE WHEN incident_severity = 'Major Damage'    THEN 1 ELSE 0 END +
        CASE WHEN incident_severity = 'Total Loss'      THEN 2 ELSE 0 END +
        CASE WHEN authorities_contacted = 'None'        THEN 2 ELSE 0 END +
        CASE WHEN total_claim_amount > 70000            THEN 2 ELSE 0 END
                                                        AS risk_score
    FROM claims
),
risk_tiered AS (
    SELECT *,
        CASE
            WHEN risk_score >= 6 THEN 'High Risk'
            WHEN risk_score >= 3 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS risk_tier
    FROM risk_factors
)
SELECT
    risk_tier,
    COUNT(policy_number)                               AS total_claims,
    COUNT(CASE WHEN fraud_reported = 'Y' THEN 1 END)   AS confirmed_fraud,
    ROUND(COUNT(CASE WHEN fraud_reported = 'Y'
          THEN 1 END) * 100.0 /
          NULLIF(COUNT(policy_number), 0), 2)          AS fraud_rate_pct,
    ROUND(AVG(total_claim_amount)::NUMERIC, 2)         AS avg_claim_amount,
    ROUND(AVG(risk_score)::NUMERIC, 2)                 AS avg_risk_score
FROM risk_tiered
GROUP BY risk_tier
ORDER BY avg_risk_score DESC;