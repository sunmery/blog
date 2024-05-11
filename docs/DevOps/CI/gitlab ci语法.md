https://blog.csdn.net/redrose2100/article/details/124224732
```yml
before_script:
  - echo "script in global before script..."

after_script:
  - echo "script in global after script..."

variables:
  USERNAME: redrose2100
  PASSWORD: admin123

workflow:
  rules:
    - if: '$USERNAME == "redrose2100"'
      when: always
    - when: never


stages:
  - build
  - test
  - release
  - deploy
  - verify

setup:
  stage: .pre
  script:
    - echo "script in pre..."
  tags:
    - docker_in_docker_demo

teardown:
  stage: .post
  script:
    - echo "script in post..."
  tags:
    - docker_in_docker_demo

build:
  stage: build
  before_script:
    - echo "before script in build..."
    - echo $USERNAME
    - echo $PASSWORD
  script:
    - echo "script in build..."
  after_script:
    - echo "after script in build..."
  tags:
    - docker_in_docker_demo
  rules:
    - if: '$USERNAME == "redrose2100"'
      when: manual
    - if: '$USERNAME == "redrose2200"'
      when: delayed
      start_in: "5"
    - when: on_success

test:
  stage: test
  before_script:
    - echo "before script in test..."
  script:
    - echo "script in test..."
  tags:
    - docker_in_docker_demo
  rules:
    - changes:
        - Dockerfile
      when: manual
  allow_failure: true
  parallel: 5


release:
  stage: release
  script:
    - echo "script in release..."
  after_script:
    - echo "after in release..."
  only:
    - tags
  tags:
    - docker_in_docker_demo
  when: delayed
  start_in: "10"

deploy:
  stage: deploy
  script:
    - echo "script in deploy..."
  tags:
    - docker_in_docker_demo
  when: manual

verify:
  stage: verify
  script: echo "in verify"
  retry: 2
  tags:
    - docker_in_docker_demo

verify-2:
  stage: verify
  script: echo "in verify-2"
  retry:
    max: 2
    when:
      - script_failure
  tags:
    - docker_in_docker_demo
  timeout: 3s
  only:
    - /^dev.*$/
  except:
    - branches

```