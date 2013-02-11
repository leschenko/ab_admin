# AbAdmin

Simple and real-life tested Rails::Engine admin interface based on slim, bootstrap, inherited_resources, simple_form, device, cancan.

## Installation

To build a new Rails application with AbAdmin, run:

```bash
$ rails new [MyAppName] -m https://raw.github.com/leschenko/ab_admin/master/lib/generators/template.rb
```

Or add [list of gems](https://gist.github.com/leschenko/752aaa0f03323aa8c6b3) to an existing application

Run generators

```bash
rails generate devise:install
rails generate simple_form:install --bootstrap
rails generate ab_admin:install
```

## Usage

To generate admin resource for model, run:

```bash
rails generate ab_admin:model [MyModelName]
```

It generate class in `app/models/ab_admin` directory like this:

```ruby
class AbAdminProduct < AbAdmin::AbstractResource
  preview_path :product_path

  settings :comments => true

  table do
    field :sku
    field(:picture) { |item| item_image_link(item) }
    field :name, :sortable => {:column => :id, :default_order => 'desc'}
    field :is_visible
    field :collection
    field :created_at
  end

  search do
    field :sku
    field :name
    field :is_visible
    field :collection
    field :created_at
  end

  export do
    field :sku
    field :name
    field(:price) { |item| "$#{item.price}" }
    field :is_visible
    field :collection
    field :created_at
  end

  form do
    group :base do
      field :sku
      field :price
    end
    field :is_visible
    field :collection, :as => :association
    locale_tabs do
      field :name
      field :description
    end
    field :picture, :as => :uploader
    field :map, :as => :map
  end
end
```

To generate full rails resource (controller, views, helper) for model, run:

```bash
rails generate ab_admin:resource [MyModelName]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
