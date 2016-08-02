# Formulator

**Formulator is part of the [thoughtbot Elixir family][elixir-phoenix] of projects.**

## Usage

Formulator is a library for Phoenix to give you:
* A label for your input, based on the attribute name
* An error label
* A class around the input if there is an error for the attribute. This allows
  you to easily style inputs that have errors.

You can replace the following:
```elixir
  <%= label form, :email %>
  <%= text_input form, :email %>
  <%= error_tag form, :email %>
```

with this:
```elixir
  <%= input form, :email %>
```

You also get the added benefit of having a class of `has-error` on the input
when there is an error associated with the attribute.

By default, Formulator assumes that you want a standard text input but if you
prefer, you can also specify the input type:

```elixir
  <%= input form, :description, as: :textarea %>
```

### Installation

Add formulator to your list of dependencies in `mix.exs`:

```elixir
  def deps do
    [
      {:formulator, "~> 0.0.1"},
    ]
  end
```

```bash
  $ mix deps.get
```

Tell formulator where to find your translations
```
  # config/config.exs
  config :formulator, gettext: YourAppName.Gettext
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

## Contributing

See the [CONTRIBUTING] document.
Thank you, [contributors]!

  [CONTRIBUTING]: CONTRIBUTING.md
  [contributors]: https://github.com/thoughtbot/formulator/graphs/contributors

## License

Formulator is Copyright (c) 2015 thoughtbot, inc.
It is free software, and may be redistributed
under the terms specified in the [LICENSE] file.

  [LICENSE]: /LICENSE

## About

![thoughtbot](https://thoughtbot.com/logo.png)

Formulator is maintained and funded by thoughtbot, inc.
The names and logos for thoughtbot are trademarks of thoughtbot, inc.

We love open source software, Elixir, and Phoenix. See [our other Elixir
projects][elixir-phoenix], or [hire our Elixir/Phoenix development team][hire]
to design, develop, and grow your product.

  [elixir-phoenix]: https://thoughtbot.com/services/elixir-phoenix?utm_source=github
  [hire]: https://thoughtbot.com?utm_source=github
