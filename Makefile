# ------------------------------------------------------------------------------
#                                ALIASES
# ------------------------------------------------------------------------------

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR := $(dir $(MKFILE_PATH))
ROOT_DIR := $(MKFILE_DIR)

# ------------------------------------------------------------------------------

DOCKER_COMPOSE_FILES := \
	-f $(ROOT_DIR)/docker/docker-compose.yaml

# ------------------------------------------------------------------------------

DATA_DIR?=/media/data
USER_ID=1000#$(UID)
GROUP_ID=1000#$(GID)
DOCKERFILE := Dockerfile

BASE_PARAMETERS := \
	ROOT_DIR=$(ROOT_DIR) \
	DATA_DIR=$(DATA_DIR)

# ------------------------------------------------------------------------------

BUILD_COMMAND := DOCKERFILE=$(ROOT_DIR)/docker/$(DOCKERFILE) ROOT_DIR=$(ROOT_DIR) docker compose $(DOCKER_COMPOSE_FILES) build --build-arg USER_ID=$(USER_ID) --build-arg GROUP_ID=$(GROUP_ID)
RUN_COMMAND := ROOT_DIR=$(ROOT_DIR) docker compose $(DOCKER_COMPOSE_FILES) run --rm

# ------------------------------------------------------------------------------
#                             GENERAL INTERFACE
# ------------------------------------------------------------------------------

build: build

# ------------------------------------------------------------------------------

eval_replica:
	@echo "Running L3GS"
	cd $(ROOT_DIR) && \
	export $(BASE_PARAMETERS) && \
	$(RUN_COMMAND) l3gs

# ------------------------------------------------------------------------------
#                              BUILDING COMMANDS
# ------------------------------------------------------------------------------


build:
	@echo "Building L3GS"
	cd $(ROOT_DIR) && $(BUILD_COMMAND) l3gs

# ------------------------------------------------------------------------------
#                              RUNNING COMMANDS
# ------------------------------------------------------------------------------

run:
	@echo "Running L3GS"
	cd $(ROOT_DIR) && \
	export $(BASE_PARAMETERS) && \
	$(RUN_COMMAND) l3gs

# ------------------------------------------------------------------------------
#                             AUXILIARY COMMANDS
# ------------------------------------------------------------------------------

prepare-terminal-for-visualization:
	xhost +local:
	DISPLAY=$(DISPLAY) xhost +
	RCUTILS_COLORIZED_OUTPUT=1
