build:
	make ENV=$(ENV) build-fe && make move-fe && \
	make build-be

build-fe:
	cd frontend && npm install && REACT_APP_ENV=$(ENV) npm run build && cd -

build-be:
	cd api && npm install && rm -rf node_modules && cd -

move-fe:
	rm -rf api/public && cp -rf frontend/build/ api/public/

deploy:
	make ENV=$(ENV) build && \
	scp -r api $(HOST):deployments/nf-dashboard
