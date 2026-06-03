CREATE OR REPLACE FUNCTION prevent_double_booking()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM 1
    FROM Spots
    WHERE spot_id = NEW.spot_id
    FOR UPDATE;

    IF EXISTS (
        SELECT 1
        FROM Reservations r
        WHERE r.spot_id = NEW.spot_id
          AND r.status = 'active'
          AND (TG_OP = 'INSERT' OR r.reservation_id <> NEW.reservation_id)
          AND NEW.start_time < r.end_time
          AND NEW.end_time > r.start_time
    ) THEN
        RAISE EXCEPTION
        'Double booking prevented: spot % already has an overlapping active reservation.',
        NEW.spot_id;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_prevent_double_booking ON Reservations;

CREATE TRIGGER trg_prevent_double_booking
BEFORE INSERT OR UPDATE OF spot_id, start_time, end_time, status
ON Reservations
FOR EACH ROW
WHEN (NEW.status = 'active')
EXECUTE FUNCTION prevent_double_booking();

DELETE FROM Reservations
WHERE spot_id = 1
  AND start_time < TIMESTAMP '2030-05-01 12:00:00'
  AND end_time > TIMESTAMP '2030-05-01 10:00:00';

BEGIN;

INSERT INTO Reservations (
    start_time,
    end_time,
    status,
    amount,
    user_id,
    vehicle_id,
    spot_id
)
VALUES (
    TIMESTAMP '2030-05-01 10:00:00',
    TIMESTAMP '2030-05-01 12:00:00',
    'active',
    12.00,
    1,
    1,
    1
);

COMMIT;

BEGIN;

INSERT INTO Reservations (
    start_time,
    end_time,
    status,
    amount,
    user_id,
    vehicle_id,
    spot_id
)
VALUES (
    TIMESTAMP '2030-05-01 10:30:00',
    TIMESTAMP '2030-05-01 11:30:00',
    'active',
    10.00,
    2,
    2,
    1
);

ROLLBACK;

SELECT
    reservation_id,
    start_time,
    end_time,
    status,
    amount,
    user_id,
    vehicle_id,
    spot_id
FROM Reservations
WHERE spot_id = 1
  AND status = 'active'
  AND start_time < TIMESTAMP '2030-05-01 12:00:00'
  AND end_time > TIMESTAMP '2030-05-01 10:00:00'
ORDER BY start_time;