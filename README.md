# Postgres-15 Docker Compose Setup

This repository contains a Docker Compose file for a straightforward installation of PostgreSQL 15, along with utility scripts for managing the setup.

## Contents

- `docker-compose.yaml`: Docker Compose file to set up PostgreSQL 15.
- `passge.sh`: Script to change the default path in `docker-compose.yaml` for PostgreSQL data storage.
- `usenv.sh`: Utility that reads and applies the `.env` file for the next command.

## Prerequisites

- Docker and Docker Compose installed on your system.

## Setup

1. **Clone the Repository**:
   ```shell
   git clone <repo-url>
   cd <repo-directory>
   ```

2. **Configure Postgres Data Path** *(Optional)*:
   - Run `passge.sh` to set a custom path for PostgreSQL data storage.
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

3. **Environment Variables**:
   - Modify the `.env` file to set your desired environment variables.

4. **Running PostgreSQL**:
   - Use `usenv.sh` to apply the `.env` file and start PostgreSQL:
     ```shell
     docker-compose up -d
     ```
