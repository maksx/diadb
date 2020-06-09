PROJECT_NAME ?= diadb
VERSION = $(shell python3.8 setup.py --version | tr '+' '-')
PROJECT_NAMESPACE ?= maksx
REGISTRY_IMAGE ?= $(PROJECT_NAMESPACE)/$(PROJECT_NAME)
POSTGRES_USER ?= user
POSTGRES_PASSWORD ?= password
POSTGRES_DB ?= diadb
SUBDIRS = diadb
DIRS = . $(shell find $(SUBDIRS) -maxdepth 1 -type d)
GARBAGE_PATTERNS = *.egg-info __pycache__
GARBAGE = $(foreach DIR,$(DIRS),$(addprefix $(DIR)/,$(GARBAGE_PATTERNS)))

all:
	@echo "make devenv	- Create & setup development virtual environment"
	@echo "make lint	- Check code with pylama"
	@echo "make postgres	- Start postgres container"
	@echo "make clean	- Remove files created by distutils"
	@echo "make test	- Run tests"
	@echo "make docker	- Build a docker image"
	@echo "make upload	- Upload docker image to the registry"
	@exit 0

clean:
	rm -rf $(GARBAGE)

devenv: clean
	rm -rf venv
	python3.8 -m venv venv
	venv/bin/pip install -Ue '.[dev]'

lint:
	venv/bin/pylama

postgres:
	docker stop diadb-postgres || true
	docker run --rm --detach --name=diadb-postgres \
		--env POSTGRES_USER=$(POSTGRES_USER) \
		--env POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
		--env POSTGRES_DB=$(POSTGRES_DB) \
		--publish 5432:5432 postgres:12.3

test: lint postgres
	venv/bin/pytest -vv --cov=diadb --cov-report=term-missing tests

docker:
	docker build --target=api -t $(PROJECT_NAME):$(VERSION) .

upload: docker
	docker tag $(PROJECT_NAME):$(VERSION) $(REGISTRY_IMAGE):$(VERSION)
	docker tag $(PROJECT_NAME):$(VERSION) $(REGISTRY_IMAGE):latest
	docker push $(REGISTRY_IMAGE):$(VERSION)
	docker push $(REGISTRY_IMAGE):latest