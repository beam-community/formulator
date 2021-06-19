# Formulator

**Formulator is part of the [thoughtbot Elixir family][elixir-phoenix] of projects.**

This README follows master, which may not be the currently published version.
Here are the [docs for the latest published version of Formulator](https://hexdocs.pm/formulator)

## Usage

Formulator is a library for Phoenix to give you:
* A label for your input, based on the attribute name
* An error label
* A class around the input if there is an error for the attribute. This allows
  you to easily style inputs that have errors.

You can replace the following:

```elixir
  <%= label form, :name %>
  <%= text_input form, :name %>
  <%= error_tag form, :name %>
```

with this:

```elixir
  <%= input form, :name %>
```

You also get the added benefit of having a class of `has-error` on the input
when there is an error associated with the attribute.

By default, Formulator assumes that you want a standard text input but if you
prefer, you can also specify the input type:

```elixir
  <%= input form, :description, as: :textarea %>
  <%= input form, :count, as: :number %>
  <%= input form, :email_address, as: :email %>
```

See [Formulator.input/3](https://hexdocs.pm/formulator/Formulator.html#input/3) for more examples.

### Installation

Add formulator to your list of dependencies in `mix.exs`:

```elixir
  def deps do
    [
      {:formulator, "~> 0.2.0"},
    ]
  end
```

```bash
  $ mix deps.get
```

Formulator needs to know what module to use for the `translate_error/1`
function. This is commonly defined by Phoenix either in
`web/views/error_helpers.ex` or `web/gettext.ex`. Formulator can also
be set to not validate by default; individual input options override
the application config.

```elixir
  # config/config.exs
  config :formulator,
    translate_error_module: YourAppName.ErrorHelpers,
    validate: false, # defaults to true
    validate_regex: false,  # defaults to true
    wrapper_class: "input-set"  # defaults to nil
```

You can import the package into all your views or individually as it makes
sense:
```elixir
  # web/web.ex
  def view do
    quote do
      ...
      import Formulator
      ...
    end
  end
```

## Releases

To create a new release, use the `bin/release` script. You must provide the
current version number and the new version number: `bin/release 0.2 0.3`.

If you need hex permissions, please ask someone in the thoughtbot #elixir slack
channel.

This will create a new commit with the updated fields and publish to hex.

Please be sure to follow [Semver] when creating a new release

[Semver]: https://semver.org/

## Contributing

See the [CONTRIBUTING] document.
Thank you, [contributors]!

  [CONTRIBUTING]: https://github.com/thoughtbot/formulator/blob/master/CONTRIBUTING.md
  [contributors]: https://github.com/thoughtbot/formulator/graphs/contributors

## License

Formulator is Copyright (c) 2017 thoughtbot, inc.
It is free software, and may be redistributed
under the terms specified in the [LICENSE] file.

  [LICENSE]: https://github.com/thoughtbot/formulator/blob/master/LICENSE

## About

[![thoughtbot][thoughtbot-logo]][thoughtbot]

Formulator is maintained and funded by thoughtbot, inc.
The names and logos for thoughtbot are trademarks of thoughtbot, inc.

We love open source software, Elixir, and Phoenix. See [our other Elixir
projects][elixir-phoenix], or [hire our Elixir/Phoenix development team][hire]
to design, develop, and grow your product.

  [thoughtbot]: https://thoughtbot.com?utm_source=github
  [thoughtbot-logo]: http://presskit.thoughtbot.com/images/thoughtbot-logo-for-readmes.svg
  [elixir-phoenix]: https://thoughtbot.com/services/elixir-phoenix?utm_source=github
  [hire]: https://thoughtbot.com?utm_source=github
