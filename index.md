---
layout: default
title: "Bearkim Techlog"
pagination: 
  enabled: true
---



{% assign pinned = site.posts | where_exp: "item", "item.pin == true"  %}
{% assign default = site.posts | where_exp: "item", "item.pin != true"  %}
{% assign posts = "" | split: "" %}

<!-- Get pinned posts -->

{% assign offset = paginator.page | minus: 1 | times: paginator.per_page %}
{% assign pinned_num = pinned.size | minus: offset %}

{% if pinned_num > 0 %}
  {% for i in (offset..pinned.size) limit: pinned_num %}
    {% assign posts = posts | push: pinned[i] %}
  {% endfor %}
{% else %}
  {% assign pinned_num = 0 %}
{% endif %}


<!-- Get default posts -->

{% assign default_beg = offset | minus: pinned.size %}

{% if default_beg < 0 %}
  {% assign default_beg = 0 %}
{% endif %}

{% assign default_num = paginator.posts | size | minus: pinned_num  %}
{% assign default_end = default_beg | plus: default_num | minus: 1 %}

{% if default_num > 0 %}
  {% for i in (default_beg..default_end) %}
    {% assign posts = posts | push: default[i] %}
  {% endfor %}
{% endif %}



<div id="post-list">
{% for post in site.posts %}

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