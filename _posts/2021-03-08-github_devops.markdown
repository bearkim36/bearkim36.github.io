---
layout: post
title:  "Github을 활용한 WebProject devops 구성 1"
date:   2021-03-08 05:08:45 +0900
categories: bearkim
---

MS가 github을 인수하고 나서 모든 개발환경에 중심에 Github이 있는 것 같다. 형상관리에서 CI/CD까지 아우르는 github생태계는 개발자들에게 새로운 영감을 준다. 하지만 역시나 한글로된 국내자료는 단편적인 부분만 있고 전반적인 devops구성에는 제대로 된 자료를 찾기가 어렵다. 애초에 devops의 자료 자체가 강호에 전설로만 내려오는 무공비급마냥 찾기 힘든게 사실이다. 이번 포스트는 나름에 시리즈로 실무에서 흔히 접할 수 있는 WebProject를 상정해 이를 구성하는 devops를 github과 github actions을 통하여 구성해보는 예제를 만들고자 한다.

##### Overview
- Github Actions 을 이용한 자동 배포
- <span style="color:#777777">개발과 배포에 proxy 활용하기</span>
- <span style="color:#777777">docker hub를 이용한 패키지 형상 관리</span>
- <span style="color:#777777">Github Actions과 docker hub를 이용한 자동 배포</span>
  
# &nbsp;
#### 1. devops가 무엇인가

사전적인 의미보다는 실무에서 devops는 말그대로 개발환경이다. 로컬에 개발툴을 설치하는 것도 개발환경 설정이지만 여기서 개발환경 이라고 하는 것은 CI(지속적인 소스통합), CD(지속적인 소스배포) 작업을 단순화 하기 위함이다. 다음의 작업으로 예를 들어보자.

![WebProject 논리 구조도](/files/posts/2021-03-08/image1.png)

위와 같은 구조를 가진 WebProject를 개발한다고 해보자. 이 프로젝트에서는 mongodb도 초기 구축시에 기초데이터가 필요할테니 각각 3개의 소스를 개발하고 관리해야 한다.

이 환경에서 만약 퍼블리셔가 퍼블리싱을 수정할 일이 생겨 Frontend에 소스를 변경하고 이를 수정한 후 개발자가 이를 배포한다고 가정하면 어떻게 해야할까? 다행히 형상관리로 github은 쓰고는 상황이라면 작업은 대충 아래와 같을 것이다.

1. 퍼블리셔가 소스를 수정하고 github에 push한다.
2. 퍼블리셔가 개발자에게 소스가 수정됐다고 알린다.
3. 개발자 (혹은 관리자)가 이 소스를 github에서 pull한다.
4. react (혹은 vue)를 빌드한다.
5. 빌드된 소스를 scp를 써서 배포서버의 배포서버에 web root에 복사해 넣는다.
6. 반복

이와같은 상황을 가정하고 이번 포스트에서는 react로 개발된 frontend의 devops를 구성하는 방법에 대해 설명한다.

# &nbsp;
#### 2. 그럼 어떻게 개선할 것인가

무엇을 만들던 간에 목표가 제일 중요하다. 프로젝트 마다 처한 상황과 환경이 다르기 때문에 무엇이 최적이라고 할 수는 없지만 그걸 합리적으로 설계하는 것이 devops설계의 핵심이다. 이번에 예제로 할 WebProject는 다음의 상황을 가정한다.

1. ssh로 접근할 수 있는 리눅스 배포 서버가 있다.
2. 소스는 github으로 형상관리 중이다.
3. 같은소스를 다른 서버에 포팅 할 일은 없다.
4. 코드 업데이트가 꽤 빈번히 일어난다.
5. 개발 조직이 소규모이다.
6. 보안상의 문제로 ssh는 pem키 파일을 써서 접속한다.

위와 같은 프로젝트 상황이라고 가정한 후 devops를 설계해 보는 예제를 설명해 보겠다.


# &nbsp;
#### 3. 반복해서 하는 일은 github actions이 한다.

앞서 설명한 예제에서 코드 수정과 배포는 꽤 잦은 일이지만 위에 상황에서는 사람이 매번 그 작업을 하고있다. 이번에 설계하는 devops는 그 작업을 github actions에게 맡기는 것이다. 그럼 위 예제에서 반복되는 작업은 __소스 업데이트 시 빌드하고 배포서버에 복사하는 작업__ 이 될것이다. 그럼 실제 Frontend 소스의 배포작업에서 쓰는 쉘 스크립트는 다음과 같다.


```sh
# 소스 가져오기
$ git pull
remote: Enumerating objects: *, done.
remote: Counting objects: 100% (*/*), done.
... 중략
# 누가 모듈을 추가했을지도 모르니 의존성 설치
$ npm install
# 빌드
$ npm run build
# 배포서버로 포팅
# scp -i pem키파일 -r build/. ssh 접속가능 계정@배포서버 IP나 DNS:nginx html 루트
$ scp -i sshkey.pem -r build/. sshaccount@deploy.server.com:/usr/share/nginx/html/
```


그럼 이 작업들을 github actions에게 떠넘겨보자.

일단은 각각의 프로젝트 내부에 .github/workflows 라는 디렉토리를 만든다. 그리고 이 안에 yml파일을 만든다. 파일명은 크게 상관없다.

![yml 디렉토리 구조](/files/posts/2021-03-08/image2.png)

이 파일을 에디터로 열어서 수정한다.

```yml
#frontend yml
name: Front-end CI

on:
  push:
    branches: [main]

jobs:
  build:    
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [ 14.x]

    steps:
      # source checkout
      - uses: actions/checkout@v2

      # nodejs 설치
      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v1
        with:
          node-version: ${{ matrix.node-version }}
      
      # module 설치
      - name: npm install
        run: npm install

      # 소스 빌드
      - name: Npm run build
        run: npm run build

      # scp 파일 복사
      # secret.키 이름 은 github repository 시크릿 키이다. 
      # 구글링 해도 쉽게 나오지만 간단하게 설명하면 
      # github repository 상단메뉴 > settings > secrets 에 new respositry secret 버튼으로 
      # 노출하기 싫은 환경변수를 저장할 수 있다.

      # 아래 스크립트는 build에 있는 파일을 배포서버의 웹서버 루트에 복사해 넣는 액션이다.
      - name: scp action
        uses: appleboy/scp-action@master
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.KEY }}
          port: ${{ secrets.PORT }}
          source: "build"
          target: "devops_test"

```


![액션 실행 완료](/files/posts/2021-03-08/image03.png)


![파일 업로드 완료](/files/posts/2021-03-08/image04.png)

이 과정에서 테스트를 한다거나 파일배치를 옮긴다거나 디테일을 추가 할 수는 있지만 이 것은 나중에 추가로 포스트를 작성할 계획이다. 일단 여기까지. 

참고 예제
https://github.com/bearkim36/devops-frontend-example


# &nbsp;
