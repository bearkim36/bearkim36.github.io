---
layout: post
title:  "Github을 활용한 WebProject devops 구성 1"
date:   2021-03-08 05:08:45 +0900
categories: bearkim
---

![WebProject 논리 구조도](/files/posts/2021-03-08/image1.png)

앞서 글에 이어  Frontend 서버를 신규 구축한다면, 해야할 작업은 다음과 같다.


1. 소스를 배보할 서버를 구한다 (nginx를 쓸 것이므로 리눅스 서버)
2. nginx를 설치한다.
3. nginx config를 설정한다. (도메인이나 서버정보, web root 뭐 기타등등)
4. 개발컴퓨터에서 Frontend 소스를 빌드한다.
5. 빌드한 소스를 scp등으로 배포 서버의 web root에 복사해 넣는다.
6. nginx를 구동한다.
7. nginx가 정상적으로 구동되는지 확인한다.
8. 서버를 재시작해본다. (서비스가 정상적으로 동작하는지 확인하기 위함)

```sh

```


```sh

```


# &nbsp;
