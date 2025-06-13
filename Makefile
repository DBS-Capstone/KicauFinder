# Makefile for Kicau Mono Repo

# default target
.DEFAULT_GOAL := help

COMPOSE_FILE := docker-compose.yml
ADMIN_PROFILE := --profile admin
NESTJS_DIR := Backend/web-service
PYTHON_DIR := Backend/inference-service
FRONTEND_DIR := Frontend

.PHONY: help
help:
	@echo "Kicau Mono Repo - Available Commands"
	@echo "=================================="
	@awk 'BEGIN {FS = ":.*##"; printf "\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  %-20s %s\n", $$1, $$2 } /^##@/ { printf "\n%s\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Service Management
.PHONY: up
up: ## Start all services
	@echo "Starting all services..."
	docker-compose up -d
	@echo "Services started successfully!"
	@echo "NestJS Backend: http://localhost:3000"
	@echo "Python Backend: http://localhost:8000"
	@echo "React Frontend: http://localhost:5173"
	@echo "PostgreSQL: localhost:5432"

.PHONY: up-admin
up-admin: ## Start all services with pgAdmin
	@echo "Starting all services with pgAdmin..."
	docker-compose $(ADMIN_PROFILE) up -d
	@echo "Services started successfully!"
	@echo "NestJS Backend: http://localhost:3000"
	@echo "Python Backend: http://localhost:8000"
	@echo "React Frontend: http://localhost:5173"
	@echo "PostgreSQL: localhost:5432"
	@echo "pgAdmin: http://localhost:8080"

.PHONY: down
down: ## Stop all services
	@echo "Stopping all services..."
	docker-compose down
	@echo "Services stopped successfully!"

.PHONY: restart
restart: down up ## Restart all services

.PHONY: restart-admin
restart-admin: down up-admin ## Restart all services with pgAdmin

.PHONY: build
build: ## Build all services
	@echo "Building all services..."
	docker-compose build
	@echo "Build completed!"

.PHONY: build-nocache
build-nocache: ## Build all services without cache
	@echo "Building all services without cache..."
	docker-compose build --no-cache
	@echo "Build completed!"

.PHONY: rebuild
rebuild: down build up ## Stop, build, and start all services

.PHONY: rebuild-admin
rebuild-admin: down build up-admin ## Stop, build, and start all services with pgAdmin

##@ Individual Services
.PHONY: nestjs-up
nestjs-up: ## Start NestJS service with PostgreSQL
	@echo "Starting NestJS service..."
	docker-compose up -d postgres nestjs-backend

.PHONY: python-up
python-up: ## Start Python service with PostgreSQL
	@echo "Starting Python service..."
	docker-compose up -d postgres python-backend

.PHONY: frontend-up
frontend-up: ## Start Frontend service with backends
	@echo "Starting Frontend service..."
	docker-compose up -d postgres nestjs-backend python-backend frontend

.PHONY: postgres-up
postgres-up: ## Start PostgreSQL service only
	@echo "Starting PostgreSQL service..."
	docker-compose up -d postgres

.PHONY: pgadmin-up
pgadmin-up: ## Start PostgreSQL and pgAdmin
	@echo "Starting PostgreSQL and pgAdmin..."
	docker-compose $(ADMIN_PROFILE) up -d postgres pgadmin

##@ Monitoring
.PHONY: logs
logs: ## View logs from all services
	docker-compose logs -f

.PHONY: logs-nestjs
logs-nestjs: ## View NestJS service logs
	docker-compose logs -f nestjs-backend

.PHONY: logs-python
logs-python: ## View Python service logs
	docker-compose logs -f python-backend

.PHONY: logs-frontend
logs-frontend: ## View Frontend service logs
	docker-compose logs -f frontend

.PHONY: logs-postgres
logs-postgres: ## View PostgreSQL service logs
	docker-compose logs -f postgres

.PHONY: logs-pgadmin
logs-pgadmin: ## View pgAdmin service logs
	docker-compose logs -f pgadmin

.PHONY: status
status: ## Show service status
	@echo "Service Status:"
	docker-compose ps

##@ Database Operations
.PHONY: db-migrate
db-migrate: ## Run database migrations
	@echo "Running database migrations..."
	docker-compose exec nestjs-backend npx prisma migrate deploy

.PHONY: db-seed
db-seed: ## Seed database with initial data
	@echo "Seeding database..."
	docker-compose exec nestjs-backend npm run prisma:seed

.PHONY: db-studio
db-studio: ## Open Prisma Studio
	@echo "Opening Prisma Studio..."
	docker-compose exec nestjs-backend npx prisma studio

.PHONY: db-reset
db-reset: ## Reset database (WARNING: deletes all data)
	@echo "WARNING: This will delete all database data!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ]
	docker-compose exec nestjs-backend npx prisma migrate reset --force

.PHONY: db-backup
db-backup: ## Create database backup
	@echo "Creating database backup..."
	@mkdir -p backups
	docker-compose exec postgres pg_dump -U kicau_user -d kicau_db > backups/backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "Backup created in backups/ directory"

.PHONY: db-restore
db-restore: ## Restore database from backup (specify BACKUP_FILE=filename)
	@if [ -z "$(BACKUP_FILE)" ]; then echo "Please specify BACKUP_FILE=filename"; exit 1; fi
	@echo "Restoring database from $(BACKUP_FILE)..."
	docker-compose exec -T postgres psql -U kicau_user -d kicau_db < backups/$(BACKUP_FILE)
	@echo "Database restored successfully!"

##@ Shell Access
.PHONY: shell-nestjs
shell-nestjs: ## Access NestJS container shell
	docker-compose exec nestjs-backend sh

.PHONY: shell-python
shell-python: ## Access Python container shell
	docker-compose exec python-backend bash

.PHONY: shell-frontend
shell-frontend: ## Access Frontend container shell
	docker-compose exec frontend sh

.PHONY: shell-postgres
shell-postgres: ## Access PostgreSQL shell
	docker-compose exec postgres psql -U kicau_user -d kicau_db

##@ Development
.PHONY: lint-nestjs
lint-nestjs: ## Run NestJS linting
	@echo "Running NestJS linting..."
	docker-compose exec nestjs-backend npm run lint

.PHONY: test-nestjs
test-nestjs: ## Run NestJS tests
	@echo "Running NestJS tests..."
	docker-compose exec nestjs-backend npm run test

.PHONY: test-python
test-python: ## Run Python tests
	@echo "Running Python tests..."
	docker-compose exec python-backend python -m pytest

.PHONY: install-nestjs
install-nestjs: ## Install NestJS dependencies
	@echo "Installing NestJS dependencies..."
	docker-compose exec nestjs-backend npm install

.PHONY: install-python
install-python: ## Install Python dependencies
	@echo "Installing Python dependencies..."
	docker-compose exec python-backend pip install -r requirements.txt

.PHONY: install-frontend
install-frontend: ## Install Frontend dependencies
	@echo "Installing Frontend dependencies..."
	docker-compose exec frontend npm install

##@ Cleanup
.PHONY: clean
clean: ## Clean up containers and volumes
	@echo "Cleaning up containers and volumes..."
	docker-compose down -v --remove-orphans
	@echo "Cleanup completed!"

.PHONY: clean-images
clean-images: ## Remove built images
	@echo "Removing built images..."
	docker-compose down --rmi all
	@echo "Images removed!"

.PHONY: clean-all
clean-all: ## Complete cleanup (WARNING: removes everything)
	@echo "WARNING: This will remove all containers, volumes, and images!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ]
	docker-compose down -v --rmi all --remove-orphans
	docker system prune -f
	@echo "Complete cleanup finished!"

##@ Health Checks
.PHONY: health
health: ## Check all services health
	@echo "Checking service health..."
	@docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

.PHONY: health-nestjs
health-nestjs: ## Check NestJS health endpoint
	@echo "Checking NestJS health..."
	@curl -f http://localhost:3000/health || echo "NestJS service is not healthy"

.PHONY: health-python
health-python: ## Check Python health endpoint
	@echo "Checking Python health..."
	@curl -f http://localhost:8000/health || echo "Python service is not healthy"

.PHONY: health-frontend
health-frontend: ## Check Frontend availability
	@echo "Checking Frontend availability..."
	@curl -f http://localhost:5173 || echo "Frontend service is not available"

##@ Quick Start
.PHONY: first-run
first-run: build up-admin db-seed ## First-time setup (build, start with pgAdmin, seed database)
	@echo "First-time setup completed!"
	@echo "Your services are now running:"
	@echo "  - NestJS Backend: http://localhost:3000"
	@echo "  - Python Backend: http://localhost:8000"
	@echo "  - React Frontend: http://localhost:5173"
	@echo "  - pgAdmin: http://localhost:8080"
	@echo "  - PostgreSQL: localhost:5432"

.PHONY: dev
dev: up ## Start development environment
	@echo "Development environment started!"
	@echo "Use 'make logs' to see all logs"
