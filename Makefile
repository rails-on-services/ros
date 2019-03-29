DOCKER_ORG := railsonservices
DOCKER_TAG := latest
PROJECTS   := ros-iam ros-comm ros-cognito

# build docker image
build_production_%:
	@echo "Building production docker image of $*"
	docker build -t $(DOCKER_ORG)/$*:$(DOCKER_TAG) --build-arg project=$* .

build_production: $(addprefix build_production_,$(PROJECTS))

build_development_%:
	@echo "Building development docker image of $*"
	docker build -t $(DOCKER_ORG)/$*:development-$(DOCKER_TAG) --build-arg project=$* \
			--build-arg bundle_string=--with="development test" \
			--build-arg rails_env=development \
			--build-arg os_packages="libpq5 git sudo vim less tcpdump net-tools iputils-ping" .

build_development: $(addprefix build_development_,$(PROJECTS))

build: build_production build_development

# publish docker image
push_production_%:
	@echo "Pushing $*"
	docker push $(DOCKER_ORG)/$*:$(DOCKER_TAG)

push_production: $(addprefix push_production_,$(PROJECTS))

push_development_%:
	@echo "Pushing $*"
	docker push $(DOCKER_ORG)/$*:development-$(DOCKER_TAG)

push_development: $(addprefix push_development_,$(PROJECTS))

push: push_production push_development
