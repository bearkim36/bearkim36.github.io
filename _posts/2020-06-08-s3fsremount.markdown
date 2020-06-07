---
layout: post
title:  "s3fs로 mount한 S3의 AccessKey를 변경하는 방법"
date:   2020-06-08 23:33:45 +0900
categories: aws
---

AWS S3를 s3fs로 마운트하여 사용하는 중에, IAM정책을 바꿔서 AccessKey를 변경 할일이 생겼다. 이 경우에는 두개의 파일에서 IAM AccessKey를 변경해야 한다. 단순한 작업이지만 google에 검색해도 한글자료는 안나와서 포스팅한다.

#
####1. IAM계정을 추가하고 다음의 정책을 설정해준다

IAM계정을 설정하는 내용은 다른 포스팅이 많으므로 생략한다. 생성한 계정에 아래의 정책을 추가한다.

![CiecleCI Setup project Page](/files/posts/2020-06-08/image1.png)
#
####2. 아래에 파일들을 수정해준다
AWS CLI의 AccessKey와 기존에 설정된 s3fs의 AccessKey의 수정이 필요하다.
```sh
#~/.aws/credentials       // AWS CLI 설정파일
[default]
aws_access_key_id = ABCD12345612378               #변경할 IAM access key
aws_secret_access_key = qwerasdf1234567891723     #변경할 IAM secret access key


#/etc/passwd-s3fs       // s3fs 비밀번호
ABCD12345612378:qwerasdf1234567891723         #변경할 IAM access key:변경할 IAM secret access key
```
#
####3. s3fs마운트를 해제했다가 다시 마운트한다

마운트를 재설정하지 않은 상태에서는 기존에 마운트된 디렉토리에서 파일을 사용하려 하면 다음과 같은 오류가 발생한다.

```sh
$ ls -la
ls: reading directory .: Operation not permitted
total 0
```

이 경우, s3fs마운트를 다시 설정하면 해결된다.
```sh
$ sudo fusermount -u 마운트경로
$ sudo s3fs [버킷명] [마운트 경로] -o use_cache=/tmp -o allow_other -o uid=[사용자ID] -o gid=[사용자 그룹ID] -o multireq_max=20 -o use_path_request_style -o url=https://s3-[리전id].amazonaws.com
```


