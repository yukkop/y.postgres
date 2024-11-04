changes in postgresql config for plrust only
```ignore
shared_preload_libraries = 'plrust'
plrust.work_dir = '/tmp'
```
# Postgres-15 Docker Compose Setup

This repository contains a Docker Compose file for a straightforward installation of PostgreSQL 15, along with utility scripts for managing the setup.

## Contents

- `docker-compose.yaml`: Docker Compose file to set up PostgreSQL 15.
- `passge.sh`: Script to change the default path in `docker-compose.yaml` for PostgreSQL data storage.
- `usenv.sh`: Utility that reads and applies the `.env` file for the next command.

## Dependencies
- `docker`
- `docker-compose`

## Prerequisites

- Docker and Docker Compose installed on your system.

## Setup

1. **Clone the Repository**:
   ```shell
   git clone <repo-url>
   cd <repo-directory>
   ```

2. **Configure Postgres Data Password** *(Optional)*:
   - Run `passge.sh` to set a custom password for PostgreSQL data storage.
     ```shell
     bash ./passge.sh
     ```
     or
     ```shell
     sh ./passge.sh
     ```
     or 
     ```shell
     chmod 555 ./passge.sh; ./passge.sh
     ```

     it will change password in docker compose file and write it for you

3. **Configure Postgres Data Port** *(Optional)*:
   - Run `passge.sh` to set a custom port for PostgreSQL data storage.
     ```shell
     bash ./portge.sh
     ```
     or
     ```shell
     sh ./portge.sh
     ```
     or 
     ```shell
     chmod 555 ./portge.sh; ./portge.sh
     ```

     it will change password in docker compose file and write it for you

4. **Environment Variables**:
   - Modify the `.env` file to set your desired environment variables.

5. **Running PostgreSQL**:
   - Use `usenv.sh` to apply the `.env` file and start PostgreSQL:
     ```shell
     docker-compose up -d
     ```
