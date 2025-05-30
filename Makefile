.DEFAULT_GOAL := help

MAKEFLAGS += $(if $(value VERBOSE),,--no-print-directory)

###
# ENVIRONMENT VARIABLES
###

# Create a dotEnv file if does not exists
$(shell test -f .env || echo "APP_ENV=dev" > .env)

# Load variables from dotEnv file
include .env
export $(shell sed 's/=.*//' .env);

###
# CONSTANTS
###

SERVICE_CADDY = caddy
SERVICE_AB    = ab

#---

WEBSITE_URL = https://localhost

#---

HOST_USER_ID    := $(shell id --user)
HOST_USER_NAME  := $(shell id --user --name)
HOST_GROUP_ID   := $(shell id --group)
HOST_GROUP_NAME := $(shell id --group --name)

#---

DOCKER_COMPOSE_APP     = docker compose --file docker/app/docker-compose.yml --file docker/app/docker-compose.override.$(APP_ENV).yml
DOCKER_COMPOSE_AB      = docker compose --file docker/ab/docker-compose.yml

DOCKER_BUILD_ARGUMENTS = --build-arg="HOST_USER_ID=$(HOST_USER_ID)" --build-arg="HOST_USER_NAME=$(HOST_USER_NAME)" --build-arg="HOST_GROUP_ID=$(HOST_GROUP_ID)" --build-arg="HOST_GROUP_NAME=$(HOST_GROUP_NAME)"
DOCKER_ENV_VARIABLES   = HOST_USER_ID=$(HOST_USER_ID) HOST_USER_NAME=$(HOST_USER_NAME) HOST_GROUP_ID=$(HOST_GROUP_ID) HOST_GROUP_NAME=$(HOST_GROUP_NAME)

DOCKER_RUN_AS_ROOT     = $(DOCKER_COMPOSE_APP) run -it --rm $(SERVICE_CADDY)
DOCKER_RUN_AS_USER     = $(DOCKER_COMPOSE_APP) run -it --rm --user $(HOST_USER_ID):$(HOST_GROUP_ID) $(SERVICE_CADDY)

#---

IS_INSTALLED_GUM := $(shell dpkg -s gum 2>/dev/null | grep -q 'Status: install ok installed' && echo 0 || echo 1)

###
# FUNCTIONS
###

define showInfo
	@echo ":small_orange_diamond: $(1)" | gum format -t emoji
	@echo ""
endef

define showAlert
	@echo ":heavy_exclamation_mark: $(1)" | gum format -t emoji
	@echo ""
endef

define taskDone
	@echo ""
	@echo ":small_blue_diamond: Task done!" | gum format -t emoji
	@echo ""
endef

define createDockerIgnore
	@echo 'vendor' >> ./src/.dockerignore
	@echo 'tests' >> ./src/.dockerignore
	@echo 'phpunit.xml' >> ./src/.dockerignore
endef

###
# MISCELANEOUS
###

.PHONY: get-webserver-ip-address
get-webserver-ip-address:
	$(eval WEBSERVER_IPADDRESS=$(shell docker inspect --format "{{json .NetworkSettings.Networks.app_default.Gateway}}" $(SERVICE_CADDY) | jq -r))

.PHONY: set-environment
set-environment:
	$(eval APP_ENV=$(shell gum choose --header "Setting up Makefile environment..." --selected "dev" "dev" "prod"))
	@gum spin --spinner dot --title "Persisting your selection..." -- sleep 1
	@sed -i 's/^APP_ENV=.*/APP_ENV=$(APP_ENV)/' .env
	$(MAKE) help

.PHONY: ensure_gum_is_installed
ensure_gum_is_installed:
	@if [ "${IS_INSTALLED_GUM}" = "1" ] ; then \
    	clear ; \
    	echo "🔸 Installing dependencies..." ; \
    	echo "" ; \
    	sudo mkdir -p /etc/apt/keyrings ; \
		curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg ; \
		echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list ; \
		sudo apt update && sudo apt install gum ; \
	fi;

.PHONY: require-confirmation
require-confirmation:
	$(eval CONFIRMATION=$(shell gum confirm "Are you sure?" && echo "Y" || echo "N"))

.PHONY: exit
exit:
	$(call showInfo,"See you soon!")
	@exit 0;

.PHONY: welcome
welcome:
	$(eval SERVICES=$(shell docker ps --format '{{.Names}}'))
	@clear
	@gum style --align center --width 80 --padding "1 2" --border double --border-foreground 99 ".: AVAILABLE COMMANDS :."
	@echo ':small_blue_diamond: HOST USER ..... {{ Color "212" "0" " ($(HOST_USER_ID)) $(HOST_USER_NAME) " }}' | gum format -t emoji | gum format -t template; echo ''
	@echo ':small_blue_diamond: HOST GROUP .... {{ Color "212" "0" " ($(HOST_GROUP_ID)) $(HOST_GROUP_NAME) " }}' | gum format -t emoji | gum format -t template; echo ''
	@echo ':small_blue_diamond: ENVIRONMENT ... {{ Color "212" "0" " $(APP_ENV) " }}' | gum format -t emoji | gum format -t template; echo ''
	@echo ':small_blue_diamond: DOMAIN URL .... {{ Color "212" "0" " $(WEBSITE_URL) " }}' | gum format -t emoji | gum format -t template; echo ''
	@echo ':small_blue_diamond: SERVICE(S) .... {{ Color "212" "0" " $(SERVICES) " }}' | gum format -t emoji | gum format -t template; echo ''
	@echo ''

###
# HELP
###

.PHONY: help
help: ensure_gum_is_installed welcome
	$(eval OPTION=$(shell gum choose --height 15 --header "Choose a command..." --selected "exit" "exit" "set-environment" "build" "up" "down" "restart" "logs" "inspect" "shell" "composer-dump" "composer-install" "composer-update" "composer-require" "composer-require-dev" "install-caddy-certificate" "install-skeleton" "install-laravel" "install-lumen" "install-symfony" "uninstall-app" "open-website" "get-xdebug-client-host" "test-stress"))
	@$(MAKE) ${OPTION}

###
# DOCKER RELATED
###

.PHONY: build
build:
	$(call showInfo,"Building Docker [ $(SERVICE_CADDY) $(SERVICE_AB) ]...")
	@COMPOSE_BAKE=true $(DOCKER_COMPOSE_APP) build $(DOCKER_BUILD_ARGUMENTS)
	@COMPOSE_BAKE=true WEBSERVER_IPADDRESS=$(WEBSERVER_IPADDRESS) $(DOCKER_ENV_VARIABLES) $(DOCKER_COMPOSE_AB) build
	$(call taskDone)

.PHONY: up
up:
	$(call showInfo,"Starting service [ $(SERVICE_CADDY) ]...")
	@$(DOCKER_COMPOSE_APP) up --remove-orphans --detach
	$(call taskDone)

.PHONY: down
down:
	$(call showInfo,"Starting service [ $(SERVICE_CADDY) ]...")
	@$(DOCKER_COMPOSE_APP) down --remove-orphans
	$(call taskDone)

.PHONY: restart
restart:
	$(call showInfo,"Starting service [ $(SERVICE_CADDY) ]...")
	@$(DOCKER_COMPOSE_APP) restart
	$(call taskDone)

.PHONY: logs
logs:
	$(call showInfo,"Exposing [ $(SERVICE_CADDY) ] logs...")
	@$(DOCKER_COMPOSE_APP) logs -f $(SERVICE_CADDY)
	$(call taskDone)

.PHONY: inspect
inspect:
	$(call showInfo,"Inspecting [ $(SERVICE_CADDY) ] health...")
	@docker inspect --format "{{json .State.Health}}" $(SERVICE_CADDY) | jq
	$(call taskDone)

.PHONY: shell
shell:
	$(call showInfo,"Establishing a shell terminal with [ $(SERVICE_CADDY) ] service...")
	@$(DOCKER_RUN_AS_USER) sh
	$(call taskDone)

###
# CADDY / SSL CERTIFICATE
###

.PHONY: install-caddy-certificate
install-caddy-certificate:
	$(call showInfo,"Installing [ Caddy 20XX ECC Root ] as a valid Local Certificate Authority")
	@gum spin --spinner dot --title "Copy the root certificate from Caddy Docker container..." -- sleep 1
	@docker cp $(SERVICE_CADDY):/data/caddy/pki/authorities/local/root.crt ./caddy-root-ca-authority.crt
	@gum pager < README-CADDY.md
	$(call taskDone)

###
# APP / COMPOSER RELATED
###

.PHONY: composer-dump
composer-dump:
	$(call showInfo,"Executing [ composer dump-auto ] inside [ $(SERVICE_CADDY) ] container service...")
	@$(DOCKER_RUN_AS_USER) composer dump-auto
	$(call taskDone)

.PHONY: composer-install
composer-install:
	$(call showInfo,"Executing [ composer install ] inside [ $(SERVICE_CADDY) ] container service...")
	@$(DOCKER_RUN_AS_USER) composer install
	$(call taskDone)

.PHONY: composer-update
composer-update:
	$(call showInfo,"Executing [ composer update ] inside [ $(SERVICE_CADDY) ] container service...")
	@$(DOCKER_RUN_AS_USER) composer update
	$(call taskDone)

.PHONY: composer-require
composer-require:
	$(call showInfo,"Executing [ composer require ] inside [ $(SERVICE_CADDY) ] container service...")
	@$(DOCKER_RUN_AS_USER) composer require
	$(call taskDone)

.PHONY: composer-require-dev
composer-require-dev:
	$(call showInfo,"Executing [ composer require --dev ] inside [ $(SERVICE_CADDY) ] container service...")
	@$(DOCKER_RUN_AS_USER) composer require --dev
	$(call taskDone)

###
# XDEBUG
###

.PHONY: get-xdebug-client-host
get-xdebug-client-host: get-webserver-ip-address
	$(call showInfo,"Inspecting [ $(SERVICE_CADDY) ] networks settings...")
	@echo $(WEBSERVER_IPADDRESS)
	$(call taskDone)

###
# APP / INSTALLERS
###

.PHONY: install-skeleton
install-skeleton:
	$(call showInfo,"Installing [ PHP Skeleton ]...")
	@$(DOCKER_RUN_AS_USER) composer create-project alcidesrc/php-skeleton .
	$(call createDockerIgnore)
	$(call taskDone)

.PHONY: install-laravel
install-laravel:
	$(call showInfo,"Installing [ LaravelPHP ]...")
	@$(DOCKER_RUN_AS_USER) composer create-project laravel/laravel .
	$(call createDockerIgnore)
	$(call taskDone)

.PHONY: install-lumen
install-lumen:
	$(call showInfo,"Installing [ LumenPHP ]...")
	@$(DOCKER_RUN_AS_USER) composer create-project --prefer-dist laravel/lumen .
	$(call createDockerIgnore)
	$(call taskDone)

.PHONY: install-symfony
install-symfony:
	$(call showInfo,"Installing [ SymfonyPHP ]...")
	@$(DOCKER_RUN_AS_USER) composer create-project symfony/skeleton .
	$(call createDockerIgnore)
	$(call taskDone)

.PHONY: uninstall-app
uninstall-app: require-confirmation
	@if [ "${CONFIRMATION}" = "Y" ] ; then \
    	gum spin --spinner dot --title "Recreating application folder..." -- sleep 1 ; \
    	rm -Rf ./src ; \
		mkdir ./src ; \
	fi;
	@if [ "${CONFIRMATION}" = "N" ] ; then \
    	gum spin --spinner dot --title "Nothing to do..." -- sleep 1 ; \
	fi;
	$(MAKE) help

###
# SHORTCUTS
###

.PHONY: open-website
open-website: ## Application: opens the application URL
	$(call showInfo,"Opening the application URL...")
	@echo ""
	@xdg-open $(WEBSITE_URL)
	@$(call showAlert,"Press Ctrl+C to resume your session")
	$(call taskDone)

###
# APACHE-BENCHMARK
###

.PHONY: test-stress
test-stress: get-webserver-ip-address ## Apache Benchmark stress test
	$(call showInfo,"Apache Benchmark on [ $(WEBSERVER_IPADDRESS) ] - Endpoint [ / ]...")
	@WEBSERVER_IPADDRESS=$(WEBSERVER_IPADDRESS) $(DOCKER_ENV_VARIABLES) $(DOCKER_COMPOSE_AB) run --rm -it --user $(HOST_USER_ID):$(HOST_GROUP_ID) $(SERVICE_AB) sh -c "cd homepage; sh runner.sh"
	@echo "" && gum spin --spinner minidot --title "Taking a breath..." -- sleep 5 && echo ""
	$(call showInfo,"Apache Benchmark on [ $(WEBSERVER_IPADDRESS) ] - Endpoint [ /post ]...")
	@WEBSERVER_IPADDRESS=$(WEBSERVER_IPADDRESS) $(DOCKER_ENV_VARIABLES) $(DOCKER_COMPOSE_AB) run --rm -it --user $(HOST_USER_ID):$(HOST_GROUP_ID) $(SERVICE_AB) sh -c "cd post; sh runner.sh"
	$(call taskDone)
