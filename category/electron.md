---
layout: default
permalink: /category/electron
category: electron
---


 
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
        <!-- posted date -->
        <i class="far fa-calendar fa-fw"></i>
        {{ post.date | date: "%b %d, %Y" }}
      </div>
    </div> <!-- .post-meta -->
  
  </div> <!-- .post-review -->

{% endfor %}

</div> <!-- #post-list -->

{% if paginator.total_pages > 0 %}
  {% include post-paginator.html %}
{% endif %}


