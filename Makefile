# Kicau Mono Repo

A full-stack bird sound identification application with NestJS backend, Python inference service, React frontend, and PostgreSQL database, all containerized with Docker.

## 🏗️ Architecture

- **React Frontend** (Port 5173) - Web interface built with Vite
- **NestJS Backend** (Port 3000) - Web service API with Prisma ORM
- **Python Inference Service** (Port 8000) - Machine learning inference service
- **PostgreSQL** (Port 5432) - Database
- **pgAdmin** (Port 8080) - Database administration (optional)

## 📋 Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop/)
- [Docker Compose](https://docs.docker.com/compose/install/) (included with Docker Desktop)
- Make (for Unix/Linux/Mac) or use native Docker commands for Windows

## 🚀 Quick Start

### Option 1: Using Make (Unix/Linux/Mac)

```bash
# First-time setup (builds images, starts all services with pgAdmin, seeds database)
make first-run

# Start all services
make up

# Start all services with pgAdmin
make up-admin

# Stop all services
make down

# View all available commands
make help
```

### Option 2: Native Docker Commands (Windows/All Platforms)

#### First-Time Setup
```bash
# Build all services
docker-compose build

# Start all services with pgAdmin
docker-compose --profile admin up -d

# Run database migrations
docker-compose exec nestjs-backend npx prisma migrate deploy

# Seed the database
docker-compose exec nestjs-backend npm run prisma:seed
```

#### Daily Development Commands
```bash
# Start all services (without pgAdmin)
docker-compose up -d

# Start all services with pgAdmin
docker-compose --profile admin up -d

# Stop all services
docker-compose down

# View service status
docker-compose ps

# View logs (all services)
docker-compose logs -f

# View logs (specific service)
docker-compose logs -f nestjs-backend
docker-compose logs -f python-backend
docker-compose logs -f frontend
docker-compose logs -f postgres
```

## 🔧 Development Commands

### Service Management

#### Using Make
```bash
# Start individual services
make nestjs-up      # NestJS + PostgreSQL
make python-up      # Python + PostgreSQL
make frontend-up    # Frontend + all backends
make postgres-up    # PostgreSQL only
make pgadmin-up     # PostgreSQL + pgAdmin

# Restart services
make restart        # All services
make restart-admin  # All services with pgAdmin

# Build services
make build          # Build all
make build-nocache  # Build without cache
make rebuild        # Stop, build, start
make rebuild-admin  # Stop, build, start with pgAdmin
```

#### Using Docker Commands
```bash
# Start individual services
docker-compose up -d postgres nestjs-backend
docker-compose up -d postgres python-backend
docker-compose up -d postgres nestjs-backend python-backend frontend
docker-compose up -d postgres
docker-compose --profile admin up -d postgres pgadmin

# Restart services
docker-compose restart

# Build services
docker-compose build
docker-compose build --no-cache
```

### Database Operations

#### Using Make
```bash
make db-migrate     # Run migrations
make db-seed        # Seed database
make db-studio      # Open Prisma Studio
make db-reset       # Reset database (WARNING: deletes data)
make db-backup      # Create backup
make db-restore BACKUP_FILE=filename # Restore from backup
```

#### Using Docker Commands
```bash
# Run migrations
docker-compose exec nestjs-backend npx prisma migrate deploy

# Seed database
docker-compose exec nestjs-backend npm run prisma:seed

# Open Prisma Studio
docker-compose exec nestjs-backend npx prisma studio

# Reset database (WARNING: deletes all data)
docker-compose exec nestjs-backend npx prisma migrate reset --force

# Create database backup
mkdir -p backups
docker-compose exec postgres pg_dump -U kicau_user -d kicau_db > backups/backup_$(date +%Y%m%d_%H%M%S).sql

# Restore database from backup
docker-compose exec -T postgres psql -U kicau_user -d kicau_db < backups/your_backup_file.sql
```

### Shell Access

#### Using Make
```bash
make shell-nestjs   # Access NestJS container
make shell-python   # Access Python container
make shell-frontend # Access Frontend container
make shell-postgres # Access PostgreSQL
```

#### Using Docker Commands
```bash
# Access container shells
docker-compose exec nestjs-backend sh
docker-compose exec python-backend bash
docker-compose exec frontend sh
docker-compose exec postgres psql -U kicau_user -d kicau_db
```

### Development & Testing

#### Using Make
```bash
# Linting and Testing
make lint-nestjs        # Lint NestJS code
make test-nestjs        # Run NestJS tests
make test-python        # Run Python tests

# Install Dependencies
make install-nestjs     # Install NestJS dependencies
make install-python     # Install Python dependencies
make install-frontend   # Install Frontend dependencies
```

#### Using Docker Commands
```bash
# NestJS linting and testing
docker-compose exec nestjs-backend npm run lint
docker-compose exec nestjs-backend npm run test

# Python testing
docker-compose exec python-backend python -m pytest

# Install dependencies
docker-compose exec nestjs-backend npm install
docker-compose exec python-backend pip install -r requirements.txt
docker-compose exec frontend npm install
```

### Monitoring & Logs

#### Using Make
```bash
# View logs
make logs           # All services
make logs-nestjs    # NestJS service only
make logs-python    # Python service only
make logs-frontend  # Frontend service only
make logs-postgres  # PostgreSQL service only
make logs-pgadmin   # pgAdmin service only

# Check status
make status         # Show service status
```

#### Using Docker Commands
```bash
# View logs
docker-compose logs -f                    # All services
docker-compose logs -f nestjs-backend     # NestJS service
docker-compose logs -f python-backend     # Python service
docker-compose logs -f frontend           # Frontend service
docker-compose logs -f postgres           # PostgreSQL service
docker-compose logs -f pgadmin           # pgAdmin service

# Check service status
docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
```

### Health Checks

#### Using Make
```bash
make health         # Check all services
make health-nestjs  # Check NestJS health endpoint
make health-python  # Check Python health endpoint
make health-frontend # Check Frontend availability
```

#### Using Docker Commands
```bash
# Check service status
docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# Health check endpoints (requires curl or use browser)
curl http://localhost:3000/health
curl http://localhost:8000/health
curl http://localhost:5173
```

## 🧹 Cleanup Commands

#### Using Make
```bash
make clean          # Remove containers and volumes
make clean-images   # Remove built images
make clean-all      # Complete cleanup (WARNING: removes everything)
```

#### Using Docker Commands
```bash
# Basic cleanup
docker-compose down -v --remove-orphans

# Remove images
docker-compose down --rmi all

# Complete cleanup (WARNING: removes everything)
docker-compose down -v --rmi all --remove-orphans
docker system prune -f
```

## 🌐 Service URLs

After starting the services, you can access:

- **React Frontend**: http://localhost:5173
- **NestJS API**: http://localhost:3000
- **Python Inference API**: http://localhost:8000
- **pgAdmin**: http://localhost:8080 (when using admin profile)
- **PostgreSQL**: localhost:5432

### pgAdmin Login (if using admin profile)
- **Email**: admin@kicau.com
- **Password**: admin123

### Database Connection Details
- **Host**: postgres (internal) / localhost (external)
- **Port**: 5432
- **Database**: kicau_db
- **Username**: kicau_user
- **Password**: kicau_password

## 📁 Project Structure

```
.
├── Backend/
│   ├── inference-service/     # Python ML inference service
│   │   ├── Dockerfile
│   │   ├── server.py
│   │   ├── kicau_model.h5     # Trained ML model
│   │   └── requirements.txt
│   └── web-service/           # NestJS backend API
│       ├── Dockerfile
│       ├── prisma/            # Database schema & migrations
│       ├── src/               # NestJS source code
│       │   ├── birds/         # Birds module
│       │   └── ...
│       └── package.json
├── Frontend/                  # React frontend
│   ├── Dockerfile
│   ├── nginx.conf
│   ├── src/
│   │   ├── components/        # React components
│   │   ├── pages/            # Page components
│   │   ├── services/         # API services
│   │   ├── store/            # State management
│   │   └── ...
│   └── package.json
├── MachineLearning/          # ML development & training
│   ├── app.py
│   ├── notebook.ipynb        # Training notebook
│   ├── kicau_model.h5        # Model file
│   └── requirements.txt
├── backups/                  # Database backups
├── docker-compose.yml        # Docker services configuration
├── docker-compose.prod.yml   # Production configuration
├── Makefile                 # Development commands
└── README.md               # This file
```

## 🐛 Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   # Check what's using the port
   netstat -ano | findstr :5173  # Windows (Frontend)
   netstat -ano | findstr :3000  # Windows (NestJS)
   netstat -ano | findstr :8000  # Windows (Python)
   lsof -i :5173                 # Mac/Linux (Frontend)
   lsof -i :3000                 # Mac/Linux (NestJS)
   lsof -i :8000                 # Mac/Linux (Python)
   ```

2. **Docker daemon not running**
   - Make sure Docker Desktop is running
   - On Windows: Check system tray for Docker icon

3. **Permission denied (Linux/Mac)**
   ```bash
   sudo chmod +x Makefile
   # or use docker commands directly
   ```

4. **Database connection issues**
   ```bash
   # Restart PostgreSQL service
   docker-compose restart postgres

   # Check if migrations are applied
   make db-migrate
   ```

5. **Frontend not loading**
   ```bash
   # Check if all backend services are running
   make status

   # Restart frontend service
   docker-compose restart frontend
   ```

6. **ML model not found**
   - Ensure `kicau_model.h5` exists in both `Backend/inference-service/` and `MachineLearning/` directories
   - Check Python service logs: `make logs-python`

### Logs and Debugging

```bash
# View logs for troubleshooting
make logs-nestjs      # NestJS backend
make logs-python      # Python inference service
make logs-frontend    # React frontend
make logs-postgres    # PostgreSQL database

# Follow logs in real-time
make logs             # All services
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test using the provided commands
5. Submit a pull request

## 📝 Notes for Windows Users

- Use PowerShell or Command Prompt for Docker commands
- If you have WSL2, you can use the Make commands there
- Make sure Docker Desktop is configured to use WSL2 backend for better performance
- Use `docker-compose` instead of `make` commands if Make is not available

## 🔄 Development Workflow

1. **Start development environment**:
   ```bash
   make dev  # or make up
   ```

2. **Make code changes** in:
   - `Frontend/src/` for React frontend
   - `Backend/web-service/src/` for NestJS API
   - `Backend/inference-service/` for Python ML service
   - `MachineLearning/` for ML model development

3. **View logs** to debug:
   ```bash
   make logs  # All services
   make logs-frontend  # Frontend only
   make logs-nestjs    # NestJS only
   make logs-python    # Python only
   ```

4. **Database operations**:
   ```bash
   make db-migrate  # Apply schema changes
   make db-seed     # Seed with sample data
   make db-studio   # Visual database editor
   ```

5. **Restart services** if needed:
   ```bash
   make restart  # All services
   ```

## 🚀 Production Deployment

For production deployment, use the production Docker Compose file:

```bash
# Production build and start
docker-compose -f docker-compose.prod.yml up -d --build

# Production with custom environment
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d
```

## 📊 Features

- **Bird Sound Identification**: Upload audio files or record sounds to identify bird species
- **Birdpedia**: Browse and learn about different bird species
- **History**: Track your identification history
- **RESTful API**: Complete backend API for bird data and identification
- **Machine Learning**: TensorFlow/Keras model for audio classification
- **Responsive Design**: Mobile-friendly React frontend
