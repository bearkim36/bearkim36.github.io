---
layout: post
title:  "Vue.js와 Electron, sqlite3와 knex 개발환경 구성"
date:   2021-05-18 23:00:00 +0900
categories: bearkim
---

최근에는 간단한 GUI가 있는 프로그램을 빠르게 만들 때는 electron을 자주 사용하는 편이다. OS를 가리지 않는 크로스 플랫폼의 장점은 말할것도 없고 backend가 nodejs다 보니 웹이랑 호환성도 좋으며 DB붙이기도 편하다.

얼마 전 친한동생이 요청해서 간단한 electron기반의 프로그램을 만들어 줬는데, 별도에 DB를 사용하는 환경이 아니다보니 sqlite3으로 작업하였다. 해당 내용을 포스트로 정리해보고자 한다.


구글링을 하면 찾을 수 있는 예제는 electron-vue 모듈이 있긴 하지만, 이 모듈은 electron버전이 너무 오래된 것이라 추천하지 않는다. 

##### 작업 순서
 1. vue cli 설치
 2. electron-builder 설치
 3. sqlite3 설치
 4. 디렉토리 구조
 5. db파일 생성
 6. vue.config.js 설정
 7. sqlite3 & knex 설치
 8. 예제 코드 작성 


# &nbsp;
#### 1. vue cli 설치 & vue 프로젝트 생성

일단 vue cli가 설치되어 있어야 한다.

```sh
$ npm install -g @vue/cli
```

혹시라도 뻘건글씨와 permission denied 문제가 나면 sudo로 설치해야 한다.

```sh
$ sudo npm install -g @vue/cli
```

vue cli설치가 완료되면 아래의 명령어를 입력하여 앱을 생성한다.
```sh
# vue create 프로젝트 명
$ vue create vue-electron-sqlite3
```

![vue 프로젝트 생성1](/files/posts/2021-05-18/01.png)
Manually select features를 선택한다.

![vue 프로젝트 생성2](/files/posts/2021-05-18/02.png)
적당히 자주 사용하는 feature를 선택한다.

![vue 프로젝트 생성3](/files/posts/2021-05-18/03.png)
일단은 이렇게 설정했다. (좀 달라도 electron설정과는 차이 없음)


# &nbsp;
#### 2. electron-builder 설치

생성한 프로젝트 디렉토리로 이동해서 vue cli로 electron-builder를 설치한다. 

```sh
$ cd vue-electron-sqlite3
$ vue add electron-builder
```

캡처를 못찍었는데 electron은 12버전을 선택했다. 설치를 완료하고 package.json을 편집기로 열면 다음과 같은 running 스크립트가 생겨있다.

![package.json확인](/files/posts/2021-05-18/04.png)

여기에서 electron을 구동하는 명령어는 다음과 같다.
- electron:serve 로컬에서 개발용으로 앱을 실행할 때 쓰인다.
- electron:build 배포를 위해 인스톨 패키지를 만든다. 이 때, 만들어지는 인스톨 패키지는 구동되는 OS환경에 맞게 만들어진다.
- postinstall, postuninstall 자주 쓸일은 없는데, 가끔 모듈 의존성이 꼬이면 실행할 일이 있다.

# &nbsp;
#### 3. sqlite3 설치

테스트 환경이 우분투라 우분투 설치법만 설명한다. 그 외는 아래의 링크 참조
```sh
$ sudo apt-get install sqlite3
```
[sqlite3 OS별 설치법](https://www.servermania.com/kb/articles/install-sqlite)

# &nbsp;
#### 4. 디렉토리 구조
디렉토리 구조는 다음과 같다.

![package.json확인](/files/posts/2021-05-18/05.png)
주요 파일을 설명하자면 다음과 같다.

- vue.config.js vue 환경 설정 파일, 설치한 직후엔 없으므로 생성한다.
- /extraResources 외부 리소스를 저장할 경로. sqlite3 db파일도 여기에 저장한다.
- /src/main.js vue 메인 파일
- /src/App.vue vue 초기 템플릿 vue 파일
- /src/background.js electron 백엔드 파일

여기에 다음 작업을 진행하며 파일을 추가한다.

# &nbsp;
#### 5. db파일 생성
sqlite3를 통해 데이터를 저장할 extraResources 디렉토리 안에 local database 파일을 작성한다.
```sh
$ cd extraResources
$ sqlite3 database.db
SQLite version 3.31.1 2020-01-27 19:55:54
Enter ".help" for usage hints.
sqlite>

```
파일이 정상적으로 생성되면 다음과 같은 sqlite> 쉘로 진입된다. 여기에서 예제로 사용할 테이블을 SQL로 입력하면 된다.

```sql
sqlite> CREATE TABLE USER(NAME TEXT PRIMARY KEY, PHONE TEXT, EMAIL TEXT, BIRTHDAY INT );
sqlite> .schema USER
CREATE TABLE USER(NAME TEXT PRIMARY KEY, PHONE TEXT, EMAIL TEXT, BIRTHDAY INT );
```
# &nbsp;
#### 6. vue.config.js 설정
vue.config.js파일을 생성하고 아래의 내용을 입력한다. 
vue.config.js에는 extra resource에 대한 정의와 외부 모듈 사용에 대한 정의를 해야 한다.

```javascript
module.exports = {
  publicPath: process.env.NODE_ENV === "production" ? "./" : "/",
  runtimeCompiler: true,
  productionSourceMap: false,
  pluginOptions: {
    electronBuilder: {
      // vue에서 ipc를 사용하기 위해 preload가 정의되어 있어야 한다.
      preload: "src/preload.js",
      // electron backend에서 knex와 sqlite3 사용을위해 정의한다.
      externals: ["knex", "sqlite3"],
      productName: "vue_electron_sqlite",
      builderOptions: {
        asar: false,
        // extra resources 사용을 위해 정의한다.
        extraResources: [
          {
            from: "./extraResources/",
            to: "extraResources",
            filter: ["**/*"]
          }
        ]
      }
    }
  }
};
```

# &nbsp;
#### 7. sqlite3 & knex 설치
knex와 sqlite3 모듈을 설치한다.
```sh
$ npm install --save knex sqlite3
```
아래의 명령어를 입력하여 electron-builder에 의존성을 설정해 준다.
```sh
$ npm run postinstall
```

# &nbsp;
#### 8. 예제 코드 작성
vue에서 ipc를 사용하기 위해서는 브라우저의 window객체에 preload를 설정해서 ipc모듈을 전역으로 선언해줘야 한다.
```sh
$ cd src
$ pwd
****/vue-electron-sqlite3/src
$ nano preload.js
```

```javascript
// src/preload.js
import { ipcRenderer } from "electron";
window.ipcRenderer = ipcRenderer;
```

그리고 src/background.js 안에서 electron main window를 생성하는 BrowserWindow parameter에 아래의 옵션을 추가한다.
```javascript
// src/background.js
// path 모듈 추가
import path from 'path'

const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {

      // Use pluginOptions.nodeIntegration, leave this alone
      // See nklayman.github.io/vue-cli-plugin-electron-builder/guide/security.html#nod>      
      nodeIntegration: process.env.ELECTRON_NODE_INTEGRATION,
      contextIsolation: !process.env.ELECTRON_NODE_INTEGRATION,
      // 아래 preload 옵션 추가 
      preload: path.join(__dirname, "preload.js")
    }
  })
```

테스트를 위해 다음의 데이터를 db에 입력한다.
```sh
$ cd extraResources
$ sqlite3 database.db
sqlite> INSERT INTO USER(NAME, PHONE, EMAIL, BIRTHDAY) VALUES('KIM', '010-1234-5678', 'bearkim36@gmail.com', 1024);
sqlite> INSERT INTO USER(NAME, PHONE, EMAIL, BIRTHDAY) VALUES('Bear', '010-1234-5678', 'bearkim36@gmail.com', 1025);
sqlite> INSERT INTO USER(NAME, PHONE, EMAIL, BIRTHDAY) VALUES('BearKim', '010-1234-5678'
, 'bearkim36@gmail.com', 1026);
sqlite> SELECT * FROM USER;
KIM|010-1234-5678|bearkim36@gmail.com|1024
Bear|010-1234-5678|bearkim36@gmail.com|1025
BearKim|010-1234-5678|bearkim36@gmail.com|1026
```

예제 코드는 내용이 길어져서 github에 게시했다.

[예제소스 github repository](https://github.com/bearkim36/vue-electron-sqlite3)

실행결과 
![package.json확인](/files/posts/2021-05-18/06.png)