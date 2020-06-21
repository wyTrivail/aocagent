-include .env

VERSION := $(shell cat VERSION)
BUILD := $(shell git rev-parse --short HEAD)
PROJECTNAME := $(shell basename "$(PWD)")

# Go related variables.
GOBASE := $(shell pwd)
GOPATH := $(GOBASE)/vendor:$(GOBASE)
GOBIN := $(GOBASE)/bin
GOFILES := $(wildcard *.go)

# Use linker flags to provide version/build settings
LDFLAGS=-ldflags "-X=main.Version=$(VERSION) -X=main.Build=$(BUILD)"

# Redirect error output to a file, so we can show it in development mode.
STDERR := /tmp/.$(PROJECTNAME)-stderr.txt

# Make is verbose in Linux. Make it silent.
# MAKEFLAGS += --silent

## install: Install missing dependencies. Runs `go get` internally. e.g; make install get=github.com/foo/bar
install: binaries

aocagent:
	GO111MODULE=on CGO_ENABLED=0 go build $(LDFLAGS) -o ./bin/aocagent_$(GOOS)_$(GOARCH) ./cmd/aocagent

binaries:
	GOOS=darwin GOARCH=amd64 $(MAKE) aocagent
	GOOS=windows GOARCH=amd64 $(MAKE) aocagent
	GOOS=linux GOARCH=amd64 $(MAKE) aocagent
	GOOS=linux GOARCH=arm64 $(MAKE) aocagent

go-build:
	@echo "  >  Building binary..."
	@GOOS=linux  @GOARCH=amd64 @GOPATH=$(GOPATH) GOBIN=$(GOBIN) go build $(LDFLAGS) -o $(GOBIN)/$(PROJECTNAME) $(GOFILES)
	@GOOS=linux  @GOARCH=arm64 @GOPATH=$(GOPATH) GOBIN=$(GOBIN) go build $(LDFLAGS) -o $(GOBIN)/$(PROJECTNAME) $(GOFILES)
	@GOOS=darwin  @GOARCH=amd64 @GOPATH=$(GOPATH) GOBIN=$(GOBIN) go build $(LDFLAGS) -o $(GOBIN)/$(PROJECTNAME) $(GOFILES)
	@GOOS=windows  @GOARCH=amd64 @GOPATH=$(GOPATH) GOBIN=$(GOBIN) go build $(LDFLAGS) -o $(GOBIN)/$(PROJECTNAME) $(GOFILES)

.PHONY: help
all: help
help: Makefile
	@echo
	@echo " Choose a command run in "$(PROJECTNAME)":"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo
