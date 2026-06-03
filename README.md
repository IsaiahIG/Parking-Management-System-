

Create docker container:
docker compose -f sql-postgres.yml up -d

To reset:
docker compose -f sql-postgres.yml down

To start:
docker compose -f sql-postgres.yml start

To stop:
docker compose -f sql-postgres.yml stop

Login through terminal:

docker exec -it pgres_pms psql -U dbuser -d cmsc461PMS

\q to quit

Browser Login:
http://localhost:8080/browser/

username: dbuser
password: dbpass
