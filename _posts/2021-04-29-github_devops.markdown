---
layout: post
title:  "Github을 활용한 WebProject devops 구성 2"
date:   2021-04-29 05:00:00 +0900
categories: bearkim
---

이전 글에 이어서 devops를 설정하는 팁을 소개해보고자 한다. 실무에서 자주 겪을 수 있는 문제 중에 restful api를 사용할 때 url설정이 꼬이는 경우가 

##### Overview
- <span style="color:#777777">Github Actions 을 이용한 자동 배포</span>
- 개발과 배포에 proxy 활용하기
- <span style="color:#777777">docker hub를 이용한 패키지 형상 관리</span>
- <span style="color:#777777">Github Actions과 docker hub를 이용한 자동 배포</span>
  
# &nbsp;
#### 2. proxy를 사용해보자

아래는 proxy의 개념도이다.

![proxy다이어그램]](/files/posts/2021-04-29/image1.png)

vue라던가 react와 같은 꽤 진보단 spa는 개발환경에서 webpack dev server를 통하여 proxy기능을 지원한다.

# &nbsp;
