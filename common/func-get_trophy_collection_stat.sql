-- this function is used to get the trophy collection stat for a specific tag and time range
CREATE OR REPLACE FUNCTION get_trophy_collection_stat(
    p_target_tag_name TEXT,
    p_start_date DATE,
    p_end_date DATE,
	p_timezone TEXT,
    p_string_to_replace TEXT
)
RETURNS TABLE (
    "Date" DATE,
    "Country of origin" TEXT,
    "Trophy" TEXT,
    "Emotion" TEXT,
    "Unique users" BIGINT
)
AS $$
BEGIN
    RETURN QUERY
        SELECT
            trophy_info.collection_date AS "Date",
            trophy_info.country::TEXT AS "Country of origin",
            trophy_info.trophy_name::TEXT AS "Trophy",
            trophy_info.emotion AS "Emotion",
            COUNT(trophy_info.*) AS "Unique users"
        FROM (
            SELECT
                DATE(to_timestamp(tr.timestamp / 1000) AT TIME ZONE 'UTC' AT TIME ZONE p_timezone) AS collection_date,
                cnt.name AS country,
                REPLACE(mov.display_name, p_string_to_replace, '') AS trophy_name,
                emotion_code_to_name(tr.emotion) as emotion
            FROM
                trophies tr
                INNER JOIN map_object_versions mov ON tr.object_version_id = mov.id
                INNER JOIN map_objects ON map_objects.active_version_id = mov.id
                INNER JOIN public.map_object_object_tag moot ON moot.map_objects_id = mov.object_id
                INNER JOIN tags t ON t.id = moot.tags_id
                INNER JOIN collectors c ON c.id = tr.owner_id
                LEFT JOIN countries cnt ON c.country_id = cnt.id
            WHERE
                t.name = p_target_tag_name
                AND DATE(to_timestamp(tr.timestamp / 1000) AT TIME ZONE 'UTC' AT TIME ZONE p_timezone) BETWEEN p_start_date AND p_end_date
        ) AS trophy_info
        GROUP BY
            trophy_info.collection_date,
            trophy_info.country,
            trophy_info.trophy_name,
            trophy_info.emotion
        ORDER BY
            trophy_info.collection_date,
            trophy_info.country,
            trophy_info.trophy_name;
END;
$$ LANGUAGE plpgsql;
