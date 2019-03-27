DOCKER_ORG := railsonservices
DOCKER_TAG := latest
PROJECTS   := ros-iam ros-comm ros-cognito

# build docker image
build_%:
	@echo "Building $*"
	docker build --console=false -t $(DOCKER_ORG)/$*:$(DOCKER_TAG) --build-arg project=$* .

build: $(addprefix build_,$(PROJECTS))

# publish docker image
push_%:
	@echo "Pushing $*"
	docker push $(DOCKER_ORG)/$*:$(DOCKER_TAG)

push: $(addprefix push_,$(PROJECTS))
