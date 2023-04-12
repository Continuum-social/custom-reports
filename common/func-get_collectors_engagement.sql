-- this function returns a number of collectors who have collected a certain number of trophies 
-- for a given tag sice a given date

CREATE OR REPLACE FUNCTION get_collectors_engagement(
    p_target_tag_name TEXT,
    p_start_date DATE
)
RETURNS TABLE (
    "Trophies Count" BIGINT,
    "Collectors count" BIGINT
)
AS $$
BEGIN
    RETURN QUERY
        SELECT
            stat.trophies_count,
            COUNT(DISTINCT stat.collector_id) AS collectors_count
        FROM (
            SELECT
                tr.owner_id AS collector_id,
                COUNT(DISTINCT tr.object_version_id) AS trophies_count
            FROM
                trophies tr
            WHERE
                DATE(to_timestamp(tr.timestamp / 1000) AT TIME ZONE 'UTC') >= p_start_date
                AND tr.owner_id IN (
                    SELECT
                        inner_tr.owner_id
                    FROM
                        trophies inner_tr
                        INNER JOIN map_object_versions mov ON inner_tr.object_version_id = mov.id
                        INNER JOIN public.map_object_object_tag moot ON moot.map_objects_id = mov.object_id
                        INNER JOIN tags t ON t.id = moot.tags_id
                    WHERE
                        t.name = p_target_tag_name
                )
            GROUP BY
                tr.owner_id
        ) stat
    GROUP BY
        stat.trophies_count;
END;
$$ LANGUAGE plpgsql;
