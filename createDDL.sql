CREATE TABLE Users (
    user_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    user_type VARCHAR(20) NOT NULL,
    CHECK (user_type IN ('student', 'faculty', 'staff', 'visitor', 'admin'))
);

CREATE TABLE Roles (
    role_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Lots (
    lot_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    lot_name VARCHAR(50) NOT NULL UNIQUE,
    location VARCHAR(100) NOT NULL,
    lot_type VARCHAR(30) NOT NULL,
    CHECK (lot_type IN ('student', 'faculty_staff', 'visitor', 'mixed', 'restricted'))
);

CREATE TABLE PermitTypes (
    permit_type_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    permit_name VARCHAR(50) NOT NULL UNIQUE,
    eligible_role VARCHAR(30) NOT NULL,
    duration VARCHAR(30) NOT NULL,
    fee DECIMAL(10,2) NOT NULL CHECK (fee >= 0),
    CHECK (eligible_role IN ('student', 'faculty', 'staff', 'visitor', 'admin')),
    CHECK (duration IN ('daily', 'semester', 'annual'))
);

CREATE TABLE Vehicles (
    vehicle_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    license_plate VARCHAR(20) NOT NULL UNIQUE,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    color VARCHAR(30) NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE UserRoles (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (role_id) REFERENCES Roles(role_id)
);

CREATE TABLE Spots (
    spot_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    spot_number VARCHAR(10) NOT NULL,
    spot_type VARCHAR(30) NOT NULL,
    occupancy_status VARCHAR(20) NOT NULL,
    lot_id INT NOT NULL,
    UNIQUE (lot_id, spot_number),
    FOREIGN KEY (lot_id) REFERENCES Lots(lot_id),
    CHECK (spot_type IN ('general', 'handicap', 'ev', 'faculty', 'reserved', 'visitor')),
    CHECK (occupancy_status IN ('available', 'occupied', 'maintenance', 'reserved'))
);

CREATE TABLE Sensors (
    sensor_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sensor_code VARCHAR(30) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL,
    spot_id INT NOT NULL UNIQUE,
    FOREIGN KEY (spot_id) REFERENCES Spots(spot_id),
    CHECK (status IN ('active', 'inactive', 'faulty', 'maintenance'))
);

CREATE TABLE Permits (
    permit_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    issue_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    user_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    permit_type_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id),
    FOREIGN KEY (permit_type_id) REFERENCES PermitTypes(permit_type_id),
    CHECK (expiration_date >= issue_date),
    CHECK (status IN ('active', 'expired', 'revoked', 'pending'))
);

CREATE TABLE SensorEvents (
    event_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_time TIMESTAMP NOT NULL,
    event_type VARCHAR(20) NOT NULL,
    sensor_id INT NOT NULL,
    vehicle_id INT,
    FOREIGN KEY (sensor_id) REFERENCES Sensors(sensor_id),
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id),
    CHECK (event_type IN ('entry', 'exit', 'occupied', 'vacant', 'error'))
);

CREATE TABLE Reservations (
    reservation_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    user_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    spot_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id),
    FOREIGN KEY (spot_id) REFERENCES Spots(spot_id),
    CHECK (end_time > start_time),
    CHECK (status IN ('active', 'completed', 'cancelled', 'expired'))
);

CREATE TABLE Tickets (
    ticket_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    issue_time TIMESTAMP NOT NULL,
    violation_type VARCHAR(50) NOT NULL,
    fine_amount DECIMAL(10,2) NOT NULL CHECK (fine_amount >= 0),
    status VARCHAR(20) NOT NULL,
    vehicle_id INT NOT NULL,
    user_id INT NOT NULL,
    spot_id INT NOT NULL,
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (spot_id) REFERENCES Spots(spot_id),
    CHECK (status IN ('unpaid', 'paid', 'appealed', 'dismissed'))
);

CREATE TABLE Payments (
    payment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    payment_date TIMESTAMP NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    payment_type VARCHAR(20) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    reservation_id INT,
    ticket_id INT,
    user_id INT NOT NULL,
    FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id),
    FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CHECK (payment_type IN ('card', 'cash', 'mobile', 'online')),
    CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
    CHECK (
        (reservation_id IS NOT NULL AND ticket_id IS NULL)
        OR
        (reservation_id IS NULL AND ticket_id IS NOT NULL)
    )
);

CREATE OR REPLACE FUNCTION issue_permit(
    p_user_id INT,
    p_vehicle_id INT,
    p_permit_type_id INT,
    p_issue_date DATE,
    p_expiration_date DATE
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_permit_id INT;
    v_eligible_role VARCHAR(30);
BEGIN
    IF p_issue_date > p_expiration_date THEN
        RAISE EXCEPTION 'Issue date cannot be after expiration date';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM Users
        WHERE user_id = p_user_id
    ) THEN
        RAISE EXCEPTION 'User does not exist';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM Vehicles
        WHERE vehicle_id = p_vehicle_id
          AND user_id = p_user_id
    ) THEN
        RAISE EXCEPTION 'Vehicle does not belong to this user';
    END IF;

    SELECT eligible_role
    INTO v_eligible_role
    FROM PermitTypes
    WHERE permit_type_id = p_permit_type_id;

    IF v_eligible_role IS NULL THEN
        RAISE EXCEPTION 'Permit type does not exist';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM UserRoles ur
        JOIN Roles r ON ur.role_id = r.role_id
        WHERE ur.user_id = p_user_id
          AND LOWER(r.role_name) = LOWER(v_eligible_role)
    ) THEN
        RAISE EXCEPTION 'User is not eligible for this permit type';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM Permits
        WHERE vehicle_id = p_vehicle_id
          AND status = 'active'
          AND p_issue_date <= expiration_date
          AND p_expiration_date >= issue_date
    ) THEN
        RAISE EXCEPTION 'Vehicle already has an overlapping active permit';
    END IF;

    INSERT INTO Permits (
        issue_date,
        expiration_date,
        status,
        user_id,
        vehicle_id,
        permit_type_id
    )
    VALUES (
        p_issue_date,
        p_expiration_date,
        'active',
        p_user_id,
        p_vehicle_id,
        p_permit_type_id
    )
    RETURNING permit_id INTO v_permit_id;

    RETURN v_permit_id;
END;
$$;

CREATE OR REPLACE FUNCTION update_spot_occupancy()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_spot_id INT;
BEGIN
    SELECT spot_id
    INTO v_spot_id
    FROM Sensors
    WHERE sensor_id = NEW.sensor_id;

    IF NEW.event_type IN ('entry', 'occupied') THEN
        UPDATE Spots
        SET occupancy_status = 'occupied'
        WHERE spot_id = v_spot_id;
    ELSIF NEW.event_type IN ('exit', 'vacant') THEN
        UPDATE Spots
        SET occupancy_status = 'available'
        WHERE spot_id = v_spot_id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_update_spot_occupancy
AFTER INSERT ON SensorEvents
FOR EACH ROW
EXECUTE FUNCTION update_spot_occupancy();

CREATE OR REPLACE PROCEDURE auto_ticket_violations()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Tickets (
        issue_time,
        violation_type,
        fine_amount,
        status,
        vehicle_id,
        user_id,
        spot_id
    )
    SELECT
        CURRENT_TIMESTAMP,
        'No Valid Permit',
        50.00,
        'unpaid',
        latest.vehicle_id,
        v.user_id,
        s.spot_id
    FROM (
        SELECT DISTINCT ON (se.sensor_id)
            se.sensor_id,
            se.vehicle_id,
            se.event_time,
            se.event_type
        FROM SensorEvents se
        WHERE se.vehicle_id IS NOT NULL
        ORDER BY se.sensor_id, se.event_time DESC
    ) AS latest
    JOIN Sensors sn
        ON latest.sensor_id = sn.sensor_id
    JOIN Spots s
        ON sn.spot_id = s.spot_id
    JOIN Vehicles v
        ON latest.vehicle_id = v.vehicle_id
    WHERE s.occupancy_status = 'occupied'
      AND NOT EXISTS (
            SELECT 1
            FROM Permits p
            WHERE p.vehicle_id = latest.vehicle_id
              AND p.status = 'active'
              AND CURRENT_DATE BETWEEN p.issue_date AND p.expiration_date
      )
      AND NOT EXISTS (
            SELECT 1
            FROM Tickets t
            WHERE t.vehicle_id = latest.vehicle_id
              AND t.spot_id = s.spot_id
              AND t.status = 'unpaid'
              AND t.violation_type = 'No Valid Permit'
      );
END;
$$;

CREATE OR REPLACE VIEW CurrentActivePermits AS
SELECT
    p.permit_id,
    p.user_id,
    u.first_name,
    u.last_name,
    p.vehicle_id,
    v.license_plate,
    pt.permit_name,
    p.issue_date,
    p.expiration_date,
    p.status
FROM Permits p
JOIN Users u ON p.user_id = u.user_id
JOIN Vehicles v ON p.vehicle_id = v.vehicle_id
JOIN PermitTypes pt ON p.permit_type_id = pt.permit_type_id
WHERE p.status = 'active'
  AND CURRENT_DATE BETWEEN p.issue_date AND p.expiration_date;

CREATE OR REPLACE VIEW CurrentLotAvailability AS
SELECT
    l.lot_id,
    l.lot_name,
    COUNT(s.spot_id) AS total_spots,
    SUM(CASE WHEN s.occupancy_status = 'available' THEN 1 ELSE 0 END) AS available_spots,
    SUM(CASE WHEN s.occupancy_status = 'occupied' THEN 1 ELSE 0 END) AS occupied_spots,
    SUM(CASE WHEN s.occupancy_status = 'reserved' THEN 1 ELSE 0 END) AS reserved_spots,
    SUM(CASE WHEN s.occupancy_status = 'maintenance' THEN 1 ELSE 0 END) AS maintenance_spots
FROM Lots l
LEFT JOIN Spots s ON l.lot_id = s.lot_id
GROUP BY l.lot_id, l.lot_name;