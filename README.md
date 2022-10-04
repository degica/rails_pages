# RailsPages
This gem introduces a quick and easy way to write frontends for your Rails app in VueJS.

With RailsPages, each web**page** has a back-end and front-end that exist side-by-side.

## Usage

This gem introduces a new top-level directory called `pages`.

### The basics

Each folder inside `pages` can contain a single page.

```
.
└── app
   ├── models
   ├── views
   ├── controllers
   └── pages
      └── my_page
         ├── page.rb
         └── page.vue
```

Each page is expected to have a `page.rb` and a `page.vue`, representing the back-end portion and front-end portion respectively.

The page's definition exists inside of `page_name/page.rb`.

```ruby
# app/pages/my_page/page.rb
Page.define '/actual/url/path/here' do
  authorize { true } # <- an "authorize" block must always be provided but the authorization itself can be done on the pages/page controller

  data do
    { value: 'hello!' } # <- can use in page.vue
  end
end
```

As you can see, the above definition includes the actual URL path. This means the URL of each page of apparent when looking at the source code, and so developers don't need to dig into routes.rb quite as often.

The frontend portion is just a regular VueJS component.

```vue
<!-- pages/my_page/page.vue -->
<template>
  <h1>{{ value }}</h1>
</template>

<script>
export default {
  data() { return { value: '' } } // <- comes directly from page.rb!
}
</script>
```

When the page is loaded, the `data` block from `page.rb` is sent to `page.vue` automatically.

### Page actions

TODO: cover `import { get, post } from 'rails-pages'` and also the page.rb part

### Advanced page usage

TODO: cover using `RailsPages::Page` as a proper Model, metadata, etc.

## Installation
Add this line to your application's Gemfile:
```ruby
gem 'rails_pages'
```

And then execute:
```bash
$ bundle install
```

### Controller setup

Pages are executed in the context of a regular Rails controller. When you install RailsPages, you will need to make that controller yourself. This allows you the flexibility to handle things like user authentication freely.

You can call your pages controller anything you like. Here's the simplest possible implementation:

```ruby
class PagesController < ApplicationController
  include RailsPages::ControllerActions
end
```

### Routes setup

Each page has its own route, and so each page must be "mounted" individually.

In the simplest case, you can mount every page, all in one go.

```ruby
# config/routes.rb

# This require is necessary to add the `mount_pages` and `mount_page` helpers.
require 'rails_pages/routes'

Rails.application.routes.draw do
  mount_pages RailsPages::Page.all, to: 'pages'
end
```

### Webpack setup

TODO: make this real and then explain it

## Contributing

Have any ideas or fixes? Feel free to fork and make a PR! We'll do our best to review your code and get it merged.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
