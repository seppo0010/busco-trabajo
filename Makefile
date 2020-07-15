.PHONY: all clean publish test-dirty

BASE_PATH := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
CURRENT_BRANCH="$(shell cd $(BASE_PATH) && git rev-parse --abbrev-ref HEAD)"

all: target/skeleton.css target/normalize.css target/index.html target/screenshot.png target/cv_sebastian_waisbrot.pdf
	
clean:
	rm -rf "${BASE_PATH}/target"

test-dirty:
	cd "${BASE_PATH}"
	! (git status --porcelain | grep -q .) || (echo 'dirty working copy' && exit 1)

publish: all test-dirty
	cd "${BASE_PATH}"
	git branch -D gh-pages || true
	git checkout --orphan=gh-pages
	git rm -rf .
	mv target/* .
	rmdir target
	git add .
	git commit -m 'Update web'
	git push origin gh-pages -f
	git checkout "${CURRENT_BRANCH}"

target:
	mkdir -p target

target/skeleton.css: target
	docker run arunvelsriram/utils wget https://raw.githubusercontent.com/dhg/Skeleton/v2.0.2/css/skeleton.css -O - > target/skeleton.css

target/normalize.css: target
	docker run arunvelsriram/utils wget https://raw.githubusercontent.com/dhg/Skeleton/v2.0.2/css/skeleton.css -O - > target/normalize.css

target/index.html: target
	cat "${BASE_PATH}/html/pre.html" > "${BASE_PATH}/target/index.html"
	docker run -i datafolklabs/markdown < "${BASE_PATH}/README.md" >> "${BASE_PATH}/target/index.html"
	cat "${BASE_PATH}/html/post.html" >> "${BASE_PATH}/target/index.html"

target/screenshot.png: target
	docker run --mount type=bind,source="${BASE_PATH}"/target,target=/target jeanphix/ghost.py:2.0.0-dev python3 -c "from ghost import Ghost;ghost = Ghost();session=ghost.start();session.open('file:///target/index.html');session.wait_for_page_loaded();session.capture_to('target/screenshot.png', region=(240, -40, 1460, 650))"

target/cv_sebastian_waisbrot.pdf: target
	cp cv_sebastian_waisbrot.pdf target/
