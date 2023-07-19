### Workshop

### Requirements
1. python version 3.6+
2. pip [link](https://github.com/pypa/get-pip)
3. node version 18.x
4. github account

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
