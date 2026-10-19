.PHONY: all test build clean

all: test build

test:
	cd sovereign-cmd && cargo test
	cd codex/runtime && cargo test
	cd codex/supervisor && mix compile

build:
	cd sovereign-cmd && cargo build --release
	cd codex/runtime && cargo build --release

clean:
	cd sovereign-cmd && cargo clean
	cd codex/runtime && cargo clean
	rm -rf codex/supervisor/_build
