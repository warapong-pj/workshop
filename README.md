### Workshop

### Requirements
1. python version 3.6+
2. pip [link](https://github.com/pypa/get-pip)
3. node version 18.x
4. github account

### pre step to before pipeline(GitHub Token)
1. goto `Setting -> Developer setting` profile GitHub account
2. generate new Personal access token(classic) by select read and write package scope
3. setup workfow environment secret by use value from previsionly step
4. goto `Repository Setting -> Actions -> General`
5. on workflow permission choose Read and write permissions

### sample pipeline
1. create nestjs new project `nest new test --package-manager=npm`
2. create Dockerfile to build container image
```
FROM node:18-bullseye AS build
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN npm ci && npm run build
USER node

FROM node:18-alpine AS pack
WORKDIR /home/node
COPY --chown=node:node --from=build /usr/src/app/node_modules /home/node/node_modules
COPY --chown=node:node --from=build /usr/src/app/dist  /home/node/dist
USER node
CMD [ "node", "dist/main.js" ]
```
3. create file to .github/workflows/pipeline.yml
4. copy github actions pipeline to file previsionly step
```
name: Build pipeline

on: [ push ]

jobs:
  build-pipeline:
    runs-on: ubuntu-latest
    steps:
      - name: checkout source code
        uses: actions/checkout@v3
      - name: install dependencies
        run: |
          npm install
      - name: login to github packages
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - name: build and push container image
        uses: docker/build-push-action@v3
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.actor }}/app:${{ github.sha }}
```
5. push pipeline to repository

### pre-commit
1. install pre-commit `pip install pre-commit`
2. install git hook script `pre-commit install`
3. generate sample pre-commit `pre-commit sample-config > .pre-commit-config.yaml`
