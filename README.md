# workshop

### requirements
1. python version 3.6+
2. pip [link](https://github.com/pypa/get-pip)
3. node version 18.x
4. github account

### generate github token
1. goto `Setting -> Developer setting` profile GitHub account
2. generate new Personal access token(classic) by select read and write package scope
3. setup workfow environment secret by use value from previsionly step
4. goto `Repository Setting -> Actions -> General`
5. on workflow permission choose Read and write permissions

### install nestjs
1. install nestjs cli `npm install -g @nestjs/cli`
2. initial nestjs project `npx nest new sample-app --package-manager=npm --skip-git --directory=.`
3. add git repository `git remote add origin git@github.com:warapong-pj/test.git`
4. change git default branch `git branch -M main`
5. push source code to git repository `git push -u origin main`

### pre-commit
1. install pre-commit `pip install pre-commit`
2. install git hook script `pre-commit install`
3. generate sample pre-commit `pre-commit sample-config > .pre-commit-config.yaml`

### sample pipeline
1. create nestjs new project `nest new test --package-manager=npm`
2. create Dockerfile to build container image
```
FROM node:20-bullseye AS build
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN npm ci && npm run build

FROM node:20-alpine AS pack
WORKDIR /home/node
COPY --chown=node:node --from=build /usr/src/app/node_modules /home/node/node_modules
COPY --chown=node:node --from=build /usr/src/app/dist  /home/node/dist
USER node
CMD [ "node", "dist/main.js" ]
```
3. create file to .github/workflows/pipeline.yml
4. copy github actions pipeline to file previsionly step
```
name: build pipeline

on: [ push ]

jobs:
  build-pipeline:
    runs-on: ubuntu-latest
    steps:
      - name: checkout source code
        uses: actions/checkout@v4
      - name: login to github packages
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - name: build and push container image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.actor }}/sample-app:${{ github.sha }}
```
5. push pipeline to repository

### add sast scan to repository
1. login to sonarcloud
2. create manual new project
3. create github repository variable and secret by use sonarcloud url and project token
4. create `sonar-project.properties` for sonarqube config
```
sonar.organization=warapong-pj
sonar.projectKey=warapong-pj_sample-app
sonar.sources=./src
sonar.javascript.lcov.reportPaths=coverage/lcov.info
```
5. add pipeline to github actions
```
name: sast pipeline

on: [ push ]

jobs:
  build-pipeline:
    runs-on: ubuntu-latest
    steps:
      - name: checkout source code
        uses: actions/checkout@v4
      - name: install dependencies
        run: |
          npm install --save-dev
          npm run test:cov
      - name: sonarqube scan
        uses: sonarsource/sonarqube-scan-action@v2.1.0
        env:
          SONAR_HOST_URL: ${{ vars.SONAR_HOST_URL }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```
6. push pipeline to repository

### scan vulnerability assessment
1. replace code to existing pipeline
```
name: sca/sbom pipeline

on: [ push ]

jobs:
  build-pipeline:
    runs-on: ubuntu-latest
    steps:
      - name: checkout source code
        uses: actions/checkout@v4
      - name: snyk scan sca/sbom
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
    - name: snyk scan container image
      uses: snyk/actions/docker@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        image: ghcr.io/${{ github.actor }}/sample-app:${{ github.sha }}
```
2. push pipeline to repository
