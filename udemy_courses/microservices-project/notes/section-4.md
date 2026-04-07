This looks like a solid breakdown of the microservices deployment workflow! I've converted your notes into a clean, professional `README.md` format with clear sections, syntax highlighting, and visual structure.

---

# 🚀 Deployment, Portability & Scalability of Microservices using Docker

This guide covers the end-to-end process of containerizing Java microservices using **Google Jib**, managing them with **Docker**, and orchestrating the entire ecosystem using **Docker Compose**.

---

## 🔹 1. Building Docker Images using Google Jib

Instead of writing complex Dockerfiles, we use **Google Jib** to build optimized Docker images directly from Maven.

### ✅ Step 1: Add Jib Plugin in `pom.xml`
Include the following configuration in your Maven build section:

```xml
<plugin>
    <groupId>com.google.cloud.tools</groupId>
    <artifactId>jib-maven-plugin</artifactId>
    <version>3.5.1</version>
    <configuration>
        <to>
            <image>shreyash/${project.artifactId}:s4</image>
        </to>
    </configuration>
</plugin>
```

> **Note:**
> * The `<image>` tag defines the target repository and tag.
> * `${project.artifactId}` dynamically pulls the service name (e.g., *accounts*, *loans*, *cards*).

### ✅ Step 2: Build the Docker Image
Execute this command from the root folder of the specific microservice:

```bash
.\mvnw.cmd compile jib:dockerBuild
```

**What this does:**
1.  **Compiles** the Java project.
2.  **Builds** a layered, optimized Docker image.
3.  **Stores** it directly in your local Docker daemon.

---

## 🔹 2. Running Individual Containers

To test a single service, use the `docker run` command:

```bash
docker run -d -p 8080:8080 shreyash/accounts:s4
```

| Flag | Description |
| :--- | :--- |
| `-d` | **Detached mode**: Runs the container in the background. |
| `-p 8080:8080` | **Port Mapping**: Maps host port 8080 to container port 8080. |
| `shreyash/accounts:s4` | The image name and tag to run. |

**Access the application at:** `http://localhost:8080`

---

## 🔹 3. Pushing Images to Docker Hub

To share your images or prepare for cloud deployment, push them to a registry:

```bash
docker image push docker.io/shreyash/accounts:s4
```

> **Prerequisites:**
> * Ensure you are logged in via `docker login`.
> * The repository must exist (or your account must have permissions to create it).

---

That is a great addition. Using the `-f` (file) flag is much more realistic for real-world projects where configuration files are often kept in a dedicated `infrastructure` or `docker` folder rather than the root.

Here is the updated **Section 4** for your `README.md`:

---

## 🔹 4. Orchestration with Docker Compose
Using `docker-compose.yml` ensures that all services (Accounts, Loans, Cards) start with the correct networking and resource constraints.

### ✅ Advanced `docker-compose.yml`
*Ensure this file is located at `./infrastructure/docker-compose.yml`.*

```yaml
services:
  accounts:
    image: "shreyash/accounts:s4"
    container_name: accounts-ms
    ports:
      - "8080:8080"
    deploy:
      resources:
        limits:
          memory: 700m
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - shreyashbank

  loans:
    image: "shreyash/loans:s4"
    container_name: loans-ms
    ports:
      - "8090:8090"
    deploy:
      resources:
        limits:
          memory: 700m
    networks:
      - shreyashbank

  cards:
    image: "shreyash/cards:s4"
    container_name: cards-ms
    ports:
      - "9000:9000"
    deploy:
      resources:
        limits:
          memory: 700m
    networks:
      - shreyashbank

networks:
  shreyashbank:
    driver: bridge
```

### ✅ Execution Command
To start the entire infrastructure when your compose file is located in a subfolder, use the `-f` flag to specify the path:

```powershell
docker compose -f .\infrastructure\docker-compose.yml up -d
```

**Breakdown of the command:**
* `docker compose`: The command-line interface for Docker Compose.
* `-f .\infrastructure\docker-compose.yml`: Points to the specific location of the configuration file.
* `up`: Builds, (re)creates, and starts containers.
* `-d`: Runs the containers in **detached mode** (background).

---

## 🔹 5. Architecture Overview



The following diagram represents how the Host Machine interacts with the Docker Bridge Network:

```text
🌐 Host Machine (Your PC)
-------------------------------------------------
|                                               |
|  http://localhost:8080   http://localhost:8090   http://localhost:9000
|           │                        │                      │
|           ▼                        ▼                      ▼
|     ┌────────────┐         ┌────────────┐        ┌────────────┐
|     │  accounts  │         │   loans    │        │   cards    │
|     │  (8080)    │         │  (8090)    │        │  (9000)    │
|     │ accounts-ms│         │ loans-ms   │        │ cards-ms   │
|     └─────┬──────┘         └─────┬──────┘        └─────┬──────┘
|           │                      │                     │
|           └──────────┬───────────┴──────────┬──────────┘
|                      │                      │
|              🌐 Docker Network (bridge)
|                 "shreyashbank"
|                                               |
-------------------------------------------------
```

---

## 🔹 6. Essential Docker Compose Commands

| Task | Command |
| :--- | :--- |
| **Start all services** | `docker-compose up -d` |
| **Stop all services** | `docker-compose down` |
| **View running containers**| `docker ps` |
| **Stream service logs** | `docker-compose logs -f` |
| **Rebuild and restart** | `docker-compose up --build` |

---

## 💡 Best Practices

* **Environment Variables:** Avoid hardcoding configurations; use `${VARIABLE_NAME}` syntax.
* **Health Checks:** Implement health checks in `docker-compose.yml` to ensure services are ready before dependent services start.
* **.env Files:** Store sensitive or environment-specific data in a `.env` file.
* **Persistence:** Use **Docker Volumes** for any services requiring data persistence (like databases).
* **Resource Limits:** Always define memory and CPU limits to prevent a single container from crashing the host.

---

## 🎯 Summary
* **Jib:** Builds Docker images without writing Dockerfiles.
* **Docker:** Runs individual containers.
* **Docker Hub:** Centralized storage for sharing images.
* **Docker Compose:** Orchestrates multiple microservices and networking.
* **Bridge Network:** Facilitates internal communication between containers.