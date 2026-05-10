-- Claim amount rankings and cumulative totals by state and incident type
WITH state_claims AS (
    SELECT
        incident_state,
        incident_type,
        COUNT(policy_number)                             AS total_claims,
        ROUND(SUM(total_claim_amount)::NUMERIC, 2)       AS total_claim_value,
        ROUND(AVG(total_claim_amount)::NUMERIC, 2)       AS avg_claim_amount,
        COUNT(CASE WHEN fraud_reported = 'Y' THEN 1 END) AS fraud_count
    FROM claims
    GROUP BY 
		incident_state, 
		incident_type
),
ranked AS (
    SELECT *,
        RANK() OVER (ORDER BY total_claim_value DESC)           AS value_rank,
        RANK() OVER (PARTITION BY incident_state
            ORDER BY total_claim_value DESC)                    AS rank_within_state,
        ROUND(SUM(total_claim_value) OVER (
            ORDER BY total_claim_value DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW)::NUMERIC, 2)                       AS cumulative_value,
        ROUND(fraud_count * 100.0 / NULLIF(total_claims, 0), 2) AS fraud_rate_pct
    FROM state_claims
)
SELECT *
FROM ranked
ORDER BY value_rank;