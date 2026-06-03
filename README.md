# UMBC Parking Management System


## Project Overview


This project implements a PostgreSQL database for a UMBC Parking Management System. The system manages users, roles, vehicles, permit types, permits, parking lots, parking spots, sensors, sensor events, reservations, tickets, and payments.


The project demonstrates relational database design, primary keys, foreign keys, CHECK constraints, UNIQUE constraints, triggers, stored procedures, views, indexes, query optimization, and transaction/concurrency control.


The final concurrency-control demo shows how the database prevents double booking when two users try to reserve the same parking spot during overlapping time windows.


---


## Required Software


- Docker Desktop
- PostgreSQL 16 through Docker
- pgAdmin 4 through Docker
- Terminal, Command Prompt, or PowerShell


---


## Project Files


The final package should include these files:


```text
docker-compose.yml
README.md
dropDDL.sql
createDDL.sql
loadAll.sql
queryAll.sql
indexAll.sql
transaction.sql
report.pdf
```


Optional files such as `smoke_test.sql` may also be included, but they are not required for the final run order.


---


## Docker Setup


The Docker file for this project is named:


```text
docker-compose.yml
```


To create and start the containers, run this command from the project folder:


```bash
docker compose up -d
```


If your file is renamed to `sql-postgres.yml`, then use this instead:


```bash
docker compose -f sql-postgres.yml up -d
```


---


## Stop the Containers


```bash
docker compose stop
```


---


## Start Existing Containers


```bash
docker compose start
```


---


## Reset the Containers


To stop and remove the containers without deleting the database volume:


```bash
docker compose down
```


To completely reset the database volume and rebuild from scratch:


```bash
docker compose down -v
docker compose up -d
```


---


## Database and pgAdmin Information


### PostgreSQL Container Information


```text
Container name: pgres_pms
Database: cmsc461PMS
Username: dbuser
Password: dbpass
Port: 5432
```


### pgAdmin Login


Open pgAdmin in a browser:


```text
http://localhost:8080/browser/
```


Login with:


```text
Email: isaiahg2@umbc.edu
Password: admin
```


### Register PostgreSQL Server in pgAdmin


Inside pgAdmin, register a new server using this information:


```text
Host name/address: postgres
Port: 5432
Maintenance database: cmsc461PMS
Username: dbuser
Password: dbpass
```


If connecting from a local database client outside Docker, use:


```text
Host name/address: localhost
Port: 5432
Database: cmsc461PMS
Username: dbuser
Password: dbpass
```


---


## Terminal Login


To connect to PostgreSQL through the terminal, run:


```bash
docker exec -it pgres_pms psql -U dbuser -d cmsc461PMS
```


To quit PostgreSQL:


```sql
\q
```


---


## Exact Script Run Order


The grader should run the files in this exact order.


The easiest terminal method is to run each SQL file from the project folder using `docker exec -i`.


---


### 1. Drop Existing Tables and Objects


```bash
docker exec -i pgres_pms psql -U dbuser -d cmsc461PMS < dropDDL.sql
```


This resets the database by dropping existing tables. It is okay if PostgreSQL prints messages such as:


```text
NOTICE: table does not exist, skipping
```


Those notices are normal when the database is already empty.


---


### 2. Create Tables, Constraints, Functions, Triggers, Procedures, and Views


```bash
docker exec -i pgres_pms psql -U dbuser -d cmsc461PMS < createDDL.sql
```


This file creates the full schema and database logic.


It creates these main tables:


- Users
- Roles
- Lots
- PermitTypes
- Vehicles
- UserRoles
- Spots
- Sensors
- Permits
- SensorEvents
- Reservations
- Tickets
- Payments


It also creates:


- `issue_permit` function
- `update_spot_occupancy` trigger function
- `trg_update_spot_occupancy` trigger
- `auto_ticket_violations` procedure
- `CurrentActivePermits` view
- `CurrentLotAvailability` view


---


### 3. Load Sample Data


```bash
docker exec -i pgres_pms psql -U dbuser -d cmsc461PMS < loadAll.sql
```


This file inserts sample users, roles, vehicles, permit types, permits, lots, spots, sensors, sensor events, reservations, tickets, and payments.


---


### 4. Run System Queries


```bash
docker exec -i pgres_pms psql -U dbuser -d cmsc461PMS < queryAll.sql
```


This file runs the main reporting and demonstration queries for the system.


The queries show:


- Active permits
- Current lot availability
- Users and vehicles
- Permit counts by permit type
- Unpaid tickets
- Ticket counts by violation type
- Reservation history
- Users with no tickets
- Latest sensor events
- Occupied spots where the vehicle has no currently valid active permit


---


### 5. Run Performance Tests Before Indexing


Before running `indexAll.sql`, run the expensive queries from `queryAll.sql` with `EXPLAIN ANALYZE`.


Example:


```sql
EXPLAIN ANALYZE
SELECT
    se.sensor_id,
    se.event_id,
    se.event_time,
    se.event_type,
    se.vehicle_id
FROM SensorEvents se
JOIN (
    SELECT sensor_id, MAX(event_time) AS latest_time
    FROM SensorEvents
    GROUP BY sensor_id
) latest
ON se.sensor_id = latest.sensor_id
AND se.event_time = latest.latest_time
ORDER BY se.sensor_id;
```


Save a screenshot of the execution plan and execution time for the final report.


---


### 6. Create Indexes


```bash
docker exec -i pgres_pms psql -U dbuser -d cmsc461PMS < indexAll.sql
```


This file creates indexes to improve query performance.


The indexes include:


- Permit lookup by vehicle, status, and dates
- Sensor event lookup by sensor and event time
- Spot lookup by lot and occupancy status
- Ticket lookup by status and issue time
- Reservation lookup by spot and time window


---


### 7. Run Performance Tests After Indexing


After running `indexAll.sql`, run the same `EXPLAIN ANALYZE` queries again.


Compare the before-index and after-index execution times in the final report.


---


### 8. Run the Transaction / Concurrency Control Demo


The concurrency demo uses:


```text
transaction.sql
```


This demo must be run using two separate database sessions, such as two pgAdmin query windows or two terminal windows.


Do not run the entire `transaction.sql` file from top to bottom in one query window because the assignment requires two active sessions to show locking behavior.


---


## Transaction Demo Goal


The concurrency problem is double booking.


Double booking means two users try to reserve the same parking spot for overlapping times.


The database prevents this problem using a trigger that locks the selected row in the `Spots` table with:


```sql
FOR UPDATE
```


When Session 1 reserves a spot and leaves the transaction open, Session 2 is forced to wait when it tries to reserve the same spot. After Session 1 commits, Session 2 checks again and fails because the spot already has an overlapping active reservation.


---


## How to Run transaction.sql


### Step 1: Run the Setup Section Once


Open `transaction.sql` and run only the setup section first.


The setup section creates:


- `prevent_double_booking` trigger function
- `trg_prevent_double_booking` trigger


It also deletes old demo reservations using the future demo date so the test can be rerun.


---


### Step 2: Open Two Query Windows


Open two separate pgAdmin query windows.


Use them as:


```text
Session 1 = first user trying to reserve the spot
Session 2 = second user trying to reserve the same spot
```


---


### Step 3: Run Session 1 Block


In Session 1, run the Session 1 block from `transaction.sql`.


Session 1 starts a transaction and inserts this reservation:


```text
Spot: 1
Time: 2030-05-01 10:00:00 to 2030-05-01 12:00:00
Status: active
```


Important: do not run `COMMIT` immediately.


Leave the transaction open.


---


### Step 4: Run Session 2 Block


In Session 2, run the Session 2 block from `transaction.sql`.


Session 2 attempts to insert an overlapping reservation:


```text
Spot: 1
Time: 2030-05-01 10:30:00 to 2030-05-01 11:30:00
Status: active
```


Expected result:


```text
Session 2 should wait or appear blocked.
```


This happens because Session 1 is still holding the row lock for spot 1.


---


### Step 5: Commit Session 1


Go back to Session 1 and run:


```sql
COMMIT;
```


Session 1 should succeed.


---


### Step 6: Observe Session 2 Failure


After Session 1 commits, Session 2 should stop waiting and fail with an error similar to:


```text
ERROR: Double booking prevented: spot 1 already has an overlapping active reservation.
```


Then run this in Session 2:


```sql
ROLLBACK;
```


---


### Step 7: Verify the Final Result


Run the verification query at the bottom of `transaction.sql`.


Expected result:


```text
Only one active reservation should exist for spot 1 during the demo time window.
```


This proves the database prevented the double booking.


---


## System Walkthrough for Final Report


The final report should include a system walkthrough showing the main workflows of the database.


### Permit Issuance


The system supports permit issuance through the `Permits` table and the `issue_permit` function. A permit connects a user, vehicle, and permit type. The function checks that the user exists, the vehicle belongs to the user, the permit type exists, the user is eligible for that permit type, and the vehicle does not already have an overlapping active permit.


### Reservation


The system supports reservations through the `Reservations` table. A reservation connects a user, vehicle, spot, start time, end time, status, and amount. The transaction demo shows that overlapping active reservations for the same spot are prevented at the database level.


### Sensor Occupancy Update


The system supports parking sensor updates through the `SensorEvents` table. When a new sensor event is inserted, the `trg_update_spot_occupancy` trigger updates the related spot in the `Spots` table. Entry and occupied events mark a spot as occupied, while exit and vacant events mark a spot as available.


### Ticket Creation


The system supports ticket creation through the `Tickets` table and the `auto_ticket_violations` stored procedure. The procedure checks current occupied spots and creates a ticket when a vehicle does not have a currently valid active permit.


### Payment Processing


The system supports payments through the `Payments` table. A payment can apply to either a reservation or a ticket. The database uses a CHECK constraint to make sure each payment is connected to exactly one of those options.


---


## Final Submission Checklist


Before submitting, confirm that:


- Docker starts successfully.
- pgAdmin opens successfully.
- The database connection works.
- `dropDDL.sql` runs successfully.
- `createDDL.sql` runs successfully.
- `loadAll.sql` runs successfully.
- `queryAll.sql` runs successfully.
- `indexAll.sql` runs successfully.
- The before-index and after-index `EXPLAIN ANALYZE` screenshots are included in the report.
- `transaction.sql` shows Session 2 blocking and then failing after Session 1 commits.
- The report includes the final system walkthrough.
- The final ZIP package includes all required files.






