---
layout: post
title:  "Jekyll Category 메뉴바와 페이지 적용하기"
date:   2021-07-17 05:08:45 +0900
categories: [jekyll]
tags: jekyll
---

Jekyll 은 확실히 좀 쓰기 더럽다. 이 블로그도 Jekyll로 되어있지만, 불편한부분이 은근 많다. 그 중, 현재 블로그 좌측 메뉴를 장식하고 있는 **Tech Post** 섹션이 그러하다. 
난 이 부분을 이 블로그에서 작성한 포스트의 카테고리를 추가하면 메뉴가 자동 구성되도록 하고 싶었는데, 인터넷 게시글 중에 어떻게 하라는건 많지만 제대로 동작하는건 아쉽게도 없는 것 같다. 그래서 현재 적용된 Jekyll 카테고리 개발 방법을 설명하고자 한다.

  
## &nbsp;
#### 1. Jekyll 폴더 구조 설정

인터넷에 써있는 글처럼 _config.yml을 수정한다고 알아서 쫜 하고 되지는 않는다.
아마 내가 설정을 제대로 못한거 같기도 하지만 어쨋든 야매로라도 구현은 했으니, 내가 구현한 방식을 이 포스트에서는 언급한다.

일단은 다음과 같은 폴더 구조를 만든다.

![category 폴더 구조](/assets/posts/2021-07-17/01.png)

/category 폴더를 만들고 그 하위에 카테고리 페이지가 될 MD파일을 작성해 넣는다.

# &nbsp;
#### 2. 카테고리 페이지 MD 파일 작성

아래에 코드를 입력한다.
```
---
layout: default
permalink: /category/aws
category: aws
---
{% raw %}
<div id="post-list">
  {% assign category = page.category | default: page.title %}
  {% for post in site.categories[category] %}
  <div class="post-preview">
    <a href="{{ post.url | relative_url }}">
      <h3>
        {{ post.title }}
      </h3>
      <div class="post-content">
        <p>
          {% include no-linenos.html content=post.content %}
          {{ content | markdownify | strip_html | truncate: 200 }}
        </p> 
      </div>
    </a>
    <div class="post-meta text-muted d-flex justify-content-between">
      <div>
        {% for tag in post.tags %}
          <button type="button" class="btn btn-sm btn-outline-secondary">{{ tag }}</button>
        {% endfor %}
      </div>
      <div class="post-date">
        <i class="far fa-calendar fa-fw"></i>
        {{ post.date | date: "%b %d, %Y" }}
      </div>
    </div>
  </div> 
{% endfor %}
</div>
{% endraw %}
```

위 코드는 블로그에서 직접 긁은 것인데, 부트스트랩으로 장식하느라고 이런저런 클래스가 들어가있다. 중요한 것은, 전체 사이트의 카테고리 목록에서 현재 페이지에 지정한 카테고리 **aws**에 해당되는 내용으로 등록된 포스트를 검색해준다는 것이다.

# &nbsp;
#### 3. 포스트에 카테고리 입력
Jekyll로 작성하는 포스트의 상단 부분에 다음과같이 카테고리를 명시한다.
![post 상단 카테고리 입력](/assets/posts/2021-07-17/02.png)
리얼리티를 살리기 위해 직접 작성한 포스트를 캡쳐했다.


# &nbsp;
#### 4. 자동으로 카테고리 먹여주는 메뉴바 작성

UI구성에 따라 다르겠지만, 이 블로그에서는 사이드 메뉴바에 다음과 같이 적용하였다.
```
  {% raw %}
  {% capture site_categories %}{% for category in site.categories %}{{ category | first }}{% unless forloop.last %},{% endunless %}{% endfor %}{% endcapture %}
  {% assign categories_list = site_categories | split:',' | sort %}
  <ul>
  {% for item in (0..site.categories.size) %}{% unless forloop.last %}
      {% capture this_word %}{{ categories_list[item] | strip_newlines }}{% endcapture %}
          <li><a href="/category/{{ this_word }}" class="d-inline-flex align-items-center rounded">{{ this_word }}<span class="count">({{ site.categories[this_word].size }})</span></a></li>
  {% endunless %}{% endfor %}
  </ul>
  {% endraw %}
```


이 코드를 적용하면 다음과 같이 해당되는 포스트 개수가 포함된 메뉴가 생성된다.
![category 폴더 구조](/assets/posts/2021-07-17/03.png)
여기에 링크를 선택하면 해당 페이지로 진입하여 해당 카테고리를 적용한 포스트 목록을 보여준다.

![category 폴더 구조](/assets/posts/2021-07-17/04.png)

여기까지 하면 완료다. 카테고리가 늘어날 때마다 카테고리명.md 파일은 계속 복붙해서 추가해줘야 하는 귀찮음이 있지만 어쨋든 정상 동작은 한다. 각자의 블로그생활에 도움이 되시길.

