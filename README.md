# AbAdmin

Simple and real-life tested Rails::Engine admin interface based on slim, bootstrap, inherited_resources, simple_form, device, cancan.

## Getting Started

Add this line to your application's Gemfile:

    gem 'ab_admin'

And then execute:

    $ bundle

Run generator

    $ rails generate ab_admin:install

The installer creates an initializer used for configuring defaults used by AbAdmin.

To generate admin resource for model, run:

    $ rails generate ab_admin:model [MyModelName]

To generate full admin resource (controller, views, helper) for model, run:

    $ rails generate ab_admin:resource [MyModelName]


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
