-- this function convert emotion code to emotion name in english
CREATE OR REPLACE FUNCTION emotion_code_to_name(emotion_code INTEGER)
RETURNS TEXT AS $$
BEGIN
    RETURN
        (CASE
            WHEN emotion_code = 1 THEN 'Happy'
            WHEN emotion_code = 2 THEN 'Curious'
            WHEN emotion_code = 4 THEN 'Calm'
            WHEN emotion_code = 8 THEN 'Accomplished'
            WHEN emotion_code = 16 THEN 'Worried'
            WHEN emotion_code = 32 THEN 'Frustrated'
            ELSE 'Unknown'
        END);
END;
$$ LANGUAGE plpgsql;