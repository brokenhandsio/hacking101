# Start a Posgres DB in Docker

```bash
docker run --name postgres -e POSTGRES_DB=vapor -e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres
```

# Stop the Docker container

```bash
docker stop postgres
```

# Delete the Docker container

```bash
docker rm postgres
```
