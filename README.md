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

### scan sensitive data before push to repository
1. copy this code to .pre-commit-config.yaml
```
- repo: https://github.com/Yelp/detect-secrets
  rev: v1.4.0
  hooks:
  - id: detect-secrets
```

### scan vulnerability assessment and scan dast
1. replace code to existing pipeline
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
      - name: run scan dependencies vulnerability assessment
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
      - name: login to github packages
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - name: build temporary container image
        uses: docker/build-push-action@v3
        with:
          context: .
          push: false
          tags: ghcr.io/${{ github.actor }}/app:${{ github.sha }}
      - name: run scan image vulnerability assessment
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ghcr.io/${{ github.actor }}/app:${{ github.sha }}
      - name: push container image to container registry
        uses: docker/build-push-action@v3
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.actor }}/app:${{ github.sha }}
```
2. add step to scan dast
```
      - name: scan dast
        run: |
          #!/bin/sh

          set -xe

          docker network create dast
          docker run -i -t -d -p 3000:3000 --network dast --name app ghcr.io/${{ github.actor }}/app:${{ github.sha }}
          docker run -t --net dast owasp/zap2docker-stable zap-full-scan.py -I -j -m 10 -T 60 -t http://app:3000
```

### enforce deploy policy to kubernetes cluster
1. create kubernetes cluster
```
kind create cluster
```
2. add helm repo and install opa gatekeeper to cluster
```
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm install gatekeeper gatekeeper/gatekeeper --values values-gatekeeper.yaml --version 3.12.0 --namespace gatekeeper-system --create-namespace
```
3. declare require resources
```
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper-library/master/library/general/containerresources/template.yaml
```
4. enforce require resources
```
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper-library/master/library/general/containerresources/samples/container-must-have-limits-and-requests/constraint.yaml
```
5. deploy disallow policy pod
```
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper-library/master/library/general/containerresources/samples/container-must-have-limits-and-requests/only-memory-limits-defined-disallowed.yaml
```
6. deploy allow policy pod
```
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper-library/master/library/general/containerresources/samples/container-must-have-limits-and-requests/limits-and-requests-defined-allowed.yaml
```
