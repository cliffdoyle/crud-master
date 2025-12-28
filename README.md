# 🎬 Movie Streaming Platform: Microservices Architecture

![Status](https://img.shields.io/badge/Status-Completed-success)
![Python](https://img.shields.io/badge/Python-3.8+-blue)
![Vagrant](https://img.shields.io/badge/Infrastructure-Vagrant-orange)
![RabbitMQ](https://img.shields.io/badge/Broker-RabbitMQ-green)

A distributed microservices infrastructure designed to simulate a real-world movie streaming backend. This project demonstrates the decoupling of services using **Synchronous** (REST/HTTP) and **Asynchronous** (Message Queues) communication patterns, orchestrated by a central API Gateway.

---

## 🏗 Architecture Overview

The system operates on three isolated Virtual Machines (VMs) provisioned via Vagrant. This ensures strictly segregated environments for each microservice.

### 🧩 The Components

| Service          | IP Address      | Tech Stack                     | Role                                                                                 |
| :--------------- | :-------------- | :----------------------------- | :----------------------------------------------------------------------------------- |
| **Gateway VM**   | `192.168.56.10` | Python Flask                   | **The Entry Point.** Routes traffic and handles protocol translation (HTTP -> AMQP). |
| **Inventory VM** | `192.168.56.11` | Flask + PostgreSQL             | **Synchronous.** Manages movie metadata (CRUD) via REST HTTP.                        |
| **Billing VM**   | `192.168.56.12` | Python + RabbitMQ + PostgreSQL | **Asynchronous.** Background worker that processes payment orders from a queue.      |

---

## 🔄 Data Flow Diagram

```text
[ CLIENT (Laptop/Postman) ]
        |
        | HTTP Request (Port 8080)
        v
+-----------------------+
|    API GATEWAY VM     |
+-----------------------+
        |
        +--------------------------+
        |                          |
        | (HTTP)                   | (AMQP Message)
        v                          v
+------------------+       +------------------+
|   INVENTORY VM   |       |    BILLING VM    |
| (Movie Database) |       |  (Message Queue) |
+------------------+       +------------------+
                                   |
                                   v
                           [ Billing Worker ]
                                   |
                           +----------------+
                           |  Orders DB     |
                           +----------------+
```

---

## 🚀 Prerequisites

* VirtualBox (Hypervisor)
* Vagrant (VM Management)
* Git (Version Control)
* Postman or `curl` (API Testing)

---

## 🛠 Installation & Setup

### 1. Infrastructure Provisioning

Clone the repository and launch the virtual machines:

```bash
git clone <your-repo-url>
cd movie-streaming-platform
vagrant up
```

> ⏳ This may take a few minutes as Vagrant downloads the Ubuntu base images.

---

### 2. Service Configuration

Run the provisioning scripts to install Python, PostgreSQL, and RabbitMQ inside the respective VMs.

```bash
# Set up Inventory (DB + API)
vagrant ssh inventory-vm -c "chmod +x /scripts/setup_inventory.sh && /scripts/setup_inventory.sh"

# Set up Billing (RabbitMQ + DB + Worker)
vagrant ssh billing-vm -c "chmod +x /scripts/setup_billing.sh && /scripts/setup_billing.sh"

# Set up Gateway (Router)
vagrant ssh gateway-vm -c "chmod +x /scripts/setup_gateway.sh && /scripts/setup_gateway.sh"
```

---

### 3. Start Applications (Process Management)

We use **PM2** to ensure our services run in the background and automatically restart on failure.

#### Inventory Service

```bash
vagrant ssh inventory-vm
cd /app
pm2 start app.py --interpreter ./venv/bin/python3 --name inventory-api
exit
```

#### Billing Service

```bash
vagrant ssh billing-vm
cd /app
pm2 start consumer.py --interpreter ./venv/bin/python3 --name billing-worker
exit
```

#### API Gateway

```bash
vagrant ssh gateway-vm
cd /app
pm2 start app.py --interpreter ./venv/bin/python3 --name api-gateway
exit
```

---

## 🔑 Environment Variables

Configuration is handled via `.env` variables injected into the application context.

| Variable            | Service             | Default Value               | Description                    |
| :------------------ | :------------------ | :-------------------------- | :----------------------------- |
| `POSTGRES_USER`     | Inventory / Billing | `myuser`                    | Database username              |
| `POSTGRES_PASSWORD` | Inventory / Billing | `mypassword`                | Database password              |
| `INVENTORY_URL`     | Gateway             | `http://192.168.56.11:5000` | Internal URL for Inventory API |
| `RABBIT_HOST`       | Gateway / Billing   | `192.168.56.12`             | Internal IP for Message Broker |

---

## 📡 API Documentation

All external requests are sent to the **API Gateway** at:

```
http://localhost:8080
```

### 1. Movie Management (Synchronous)

The Gateway proxies these requests directly to the Inventory Service and waits for a response.

#### GET /api/movies

Retrieve all available movies.

```bash
curl http://localhost:8080/api/movies
```

#### POST /api/movies

Create a new movie entry.

```bash
curl -X POST http://localhost:8080/api/movies \
  -H "Content-Type: application/json" \
  -d '{"title": "The Matrix", "description": "Sci-Fi Classic"}'
```

#### DELETE /api/movies

Delete all movies from the database.

---

### 2. Payment Processing (Asynchronous)

The Gateway pushes these requests to RabbitMQ and responds immediately. The Billing service processes them in the background.

#### POST /api/billing

Submit a new payment order.

```bash
curl -X POST http://localhost:8080/api/billing \
  -H "Content-Type: application/json" \
  -d '{"user_id": "88", "number_of_items": "2", "total_amount": "45.00"}'
```

**Response:**

```json
{
  "message": "Order queued for processing",
  "status": "queued"
}
```

ℹ️ See `srcs/api-gateway/openapi.yaml` for the full OpenAPI / Swagger specification.

---

## 🧪 Testing & Resilience

A key feature of this architecture is **fault tolerance**.

### Scenario: Billing Service Goes Offline

1. Stop the billing worker:

   ```bash
   pm2 stop billing-worker
   ```

   (inside `billing-vm`)
2. Send a `POST /api/billing` request via the Gateway.
3. **Result:** The client still receives `200 OK (queued)`.
4. Restart the worker:

   ```bash
   pm2 start billing-worker
   ```
5. **Result:** Pending messages are consumed and written to the database.

---

## 📂 Project Structure

```text
.
├── Vagrantfile              # VM Infrastructure Definition
├── README.md                # Documentation
├── scripts/                 # Provisioning shell scripts
└── srcs/
    ├── api-gateway/         # Flask Router
    │   ├── app.py
    │   └── openapi.yaml
    ├── inventory-app/       # CRUD Service
    │   ├── app.py
    │   └── requirements.txt
    └── billing-app/         # Worker Service
        ├── consumer.py
        └── requirements.txt
```

---

## 🧠 Design Decisions

* **Microservices vs Monolith**: Separating Inventory and Billing ensures failures are isolated and independently scalable.
* **Event-Driven Billing**: RabbitMQ buffers traffic spikes (e.g. 10,000 payments at once) and protects the database.
* **API Gateway Pattern**: Internal network details (`192.168.x.x`) are hidden behind a single public entry point (`localhost:8080`).

---

## ✍️ Author

**Cliff Oyoh**
