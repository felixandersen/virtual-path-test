# Virtual Path Test

There's a problem with lazy-lookups in views. Take a look at app/views/root/show.html.erb in this repository:

```erb
<h1><%= t(".title") %></h1>
<%= simple_format t(".description") %>

<%= render "common/box" %>

<%= simple_format t(".message") %>

<%= render layout: "common/box" do %>
  <%= simple_format t(".message") %>
<% end %>
```

We'd expect every lazy translation in this file, like `t(".title")`, to be resolved to be scoped by the view path, like `t("root.show.title")`. There is one exception: Inside the `render layout: "..." do ... end` block we have `t(".message")` which actually resolves to `t("common.box.message")`.

Taking a quick look at `common/_box.html.erb`:

```erb
<div class="box">
  <%= simple_format t(".prequel") %>
  <%= yield %>
</div>
```

Combine this with these translations:

```yaml
en:
  root:
    show:
      title: "Virtual Paths Test"
      description: |
        Testing strange translation context behaviour in partial layout rendering.
      message: |
        Message we expect inside the box.
  common:
    box:
      prequel: |
        Box with a silly description.
      message: |
        Message we actually see inside the box.
```

and you get:

![Broken output](https://cloud.githubusercontent.com/assets/14028/3915088/9232148c-2355-11e4-8ae3-15a66eab61ae.png)

I've been looking into the view rendering process to see if this can be fixed, but there are other implications like local variables. Inside that block we can access variables, objects, collections, etc. which have been provided as view context to the partial for rendering. This is mostly a good thing. The only unexpected behaviour is that a lazy translation inside a file which should be scoped to that file is scoped to a different file.

The disparity between expected and actual translations is due to TranslationHelper's implementation of scope_to_partial which uses the `@virtual_path` of the renderer which, when rendering a partial layout, resolves to the layout while inside the block. Maybe the concepts need to be separated? Or maybe the current behaviour is desirable in some way?

I don't know. Let's figure it out!
