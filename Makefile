#default: build

build: static
        @echo "Building Hugo Builder container..."
        @docker build -t lp/hugo-builder .
        @echo "Hugo Builder container built!"
        @docker images lp/hugo-builder

.PHONY: build

deploy: build
        @docker run -d --rm -i -p 1313:1313 --name hugo lp/hugo-builder
        @docker exec -d -w /src hugo hugo new site OrgDocs
        @docker exec -d -w /src/OrgDocs hugo git init
        @docker exec -d -w /src/OrgDocs hugo git submodule add https://github.com/budparr/gohugo-theme-ananke.git themes/ananke
        @docker exec -d -w /src/OrgDocs hugo /bin/sh -c "echo 'theme = \"ananke\"' >> /src/OrgDocs/config.toml"
        @docker exec -d -w /src/OrgDocs hugo hugo new posts/my-first-post.md
        sleep 5
        @docker exec -d -w /src/OrgDocs hugo hugo server -w --bind=0.0.0.0

static: Dockerfile
        @docker run --rm -i hadolint/hadolint hadolint --ignore=DL3018 - < Dockerfile

healthcheck: deploy
        @docker inspect --format='{{json .State.Health}}' hugo

start: healthcheck
