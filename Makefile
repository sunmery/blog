.PHONY: build
build:
	docker build --progress=plain -t ccr.ccs.tencentyun.com/sumery/blog . --platform linux/amd64 --push
