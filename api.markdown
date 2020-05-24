---
layout: null
permalink: /api
pagination:
  permalink: 'feed-:num.json'
  enabled: true
  extension: json
  
---

{
  "pages": [{% for post in paginator.posts %}
    {% if forloop.first != true %},{% endif %}
    {
      "title": "{{ post.title }}",
      "date": "{{ post.date }}",
      "content": "{{ post.content | markdownify | strip_html | strip | truncatewords: 30 }}",
      "link": "{{ post.url }}"
    }{% endfor %}
  ]
  {% if paginator.next_page %}
  ,"next": "{{ paginator.next_page_path }}"
  {% endif %}
  {% if paginator.previous_page %}
  ,"prev": "{{ paginator.previous_page_path }}"
  {% endif %}
}