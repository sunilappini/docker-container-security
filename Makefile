
build: static
	@echo "Building Hugo Builder container..."
	@docker build -t lp/hugo-builder .
	@echo "Hugo Builder container built!"
	@docker images lp/hugo-builder

.PHONY: build

deploy: build
	@docker run -d --rm -i -p 1313:1313 --user $(id -u):$(id -g) --build-arg CREATED=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ') --name hugo lp/hugo-builder
	@docker exec -d -w /src hugo hugo new site OrgDocs
	@docker exec -d -w /src/OrgDocs hugo git init
	@docker exec -d -w /src/OrgDocs hugo git submodule add https://github.com/budparr/gohugo-theme-ananke.git themes/ananke
	@docker exec -d -w /src/OrgDocs hugo /bin/sh -c "echo 'theme = \"ananke\"' >> /src/OrgDocs/config.toml"
	@docker exec -d -w /src/OrgDocs hugo hugo new posts/my-first-post.md
	sleep 5
	@docker exec -d -w /src/OrgDocs hugo hugo server -w --bind=0.0.0.0

static: Dockerfile
	@docker run --rm -i hadolint/hadolint hadolint --build-arg CREATED=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')  --ignore=DL3018 - < Dockerfile
	@docker run -it --rm -v $(PWD):/root/ projectatomic/dockerfile-lint dockerfile_lint --build-arg CREATED=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ') -r policies/security_rules.yml

healthcheck: deploy
	@docker inspect --format='{{json .State.Health}}' hugo

start: healthcheck

security_lint:
	@docker run -it --rm -v $(PWD):/root/ projectatomic/dockerfile-lint dockerfile_lint --build-arg CREATED=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ') -r policies/rules.yml

vulscan:
	@docker run --rm -p 5432:5432 -d --name db arminc/clair-db:latest --build-arg CREATED=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
	@docker run --rm -p 6060:6060 --link db:postgres -d --name clair arminc/clair-local-scan:latest --build-arg CREATED=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
	@./clair-scanner --ip 172.17.0.1 lp/hugo-builder
	@docker stop clair
	@docker stop db

bom:
	@docker run --privileged --rm -it --device /dev/fuse -v /var/run/docker.sock:/var/run/docker.sock ternd report -f spdxtagvalue -i lp/hugo-builder:latest > bom.txt

inspect:
	@docker inspect lp/hugo-builder:latest
