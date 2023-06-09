fmfcc := target/release/fmfcc
fmfcc_deps := $(wildcard fmf/Cargo.toml fmf/src/* fmf/src/*/* fmfcc/Cargo.toml fmfcc/src/* fmfcc/src/*/* Cargo.toml)
fmfflags := ${FMFFLAGS} --template out/template.html

sources := $(wildcard src/*.fmf src/*/*.fmf) src/posts.fmf
files := $(patsubst src/%.fmf,out/%.html,${sources})

.PHONY: all static serve
all: dev clean-template
dev: out/template.html ${files} static

${fmfcc}: ${fmfcc_deps}
	@printf "\e[1;32m%12s\e[0m %s\n" "build" "fmfcc (cargo)"
	@cargo b -r

out/posts.html: ${fmfcc} out/template.html
	@printf "\e[1;32m%12s\e[0m %s\n" "generate" "$(patsubst out/%.html,%.fmf,$@)"
	@mkdir -p out/
	@${fmfcc} cc -o $@ $(patsubst out/%.html,src/%.fmf,$@) ${fmfflags}

out/%.html: src/%.fmf ${fmfcc} out/template.html
	@printf "\e[1;32m%12s\e[0m %s\n" "generate" "$(patsubst out/%.html,%.fmf,$@)"
	@mkdir -p out/
	@${fmfcc} cc -o $@ $(patsubst out/%.html,src/%.fmf,$@) ${fmfflags}

static:
	@printf "\e[1;32m%12s\e[0m %s\n" "copy" "static files"
	@mkdir -p out
	@cp -r static/* out/.

out/template.html: ${fmfcc} build-posts.py template.html
	@printf "\e[1;32m%12s\e[0m %s\n" "generate" "[template]"
	@mkdir -p out/
	@python3 ./build-posts.py

serve: dev
	@printf "\e[1;32m%12s\e[0m %s\n" "serve" "http://localhost:8080"
	@./serve.sh

clean-template: dev
	@printf "\e[1;34m%12s\e[0m %s\n" "clean" "out/template.html"
	@rm out/template.html
clean:
	@printf "\e[1;34m%12s\e[0m %s\n" "clean" "out/ src/posts.fmf"
	@rm -rf out/
	@rm -f src/posts.fmf

