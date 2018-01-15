# Flaggy

**Multi-source Elixir client for managing feature flags.**

## Installation

The package can be installed by adding `flaggy` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:flaggy, "~> x.y.z"}
  ]
end
```

If you want to use the `protein` source, you'll also have to add its package:

```elixir
def deps do
  [
    {:flaggy, "~> x.y.z"},
    {:protein, "~> x.y.z"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/flaggy](https://hexdocs.pm/flaggy).

## Definition sources

Following definition sources are available:

### `memory`

Starts empty and can be filled using `Flaggy.put_definition/2`. It's most useful for testing.
This is the default source in case no configuration was provided.

#### Configuration

```elixir
config :flaggy, :source,
  type: :memory
```

### `json`

Loads definition from JSON file. It's most useful for development.

#### Configuration

```elixir
config :flaggy, :source,
  type: :json,
  eager_load: false,
  file: "path/to/definition.json"
```

### `protein`

Loads, caches and periodically updates definition from RPC server via `Protein`.

#### Configuration

```elixir
config :flaggy, :source,
  type: :protein,
  app: :my_app,
  transport: [adapter: :amqp, url: "amqp://rabbitmqhost", queue: "my_queue"]
```

## Rules

### `is`

Checks equality of specific meta attribute with given value.

#### Example

JSON snippet:

```json
{
  "attribute": "country_code",
  "is": "PL"
}
```

Code snippet:

```elixir
iex> Flaggy.put_feature(:my_feature, %{"rules" => %{"attribute" => "x", "is" => "y"}})
iex> Flaggy.active?(:my_feature, %{"x" => "y"})
true
iex> Flaggy.active?(:my_feature, %{"x" => "z"})
false
```

### `in`

Checks inclusion of specific meta attribute in a set of given values.

#### Example

JSON snippet:

```json
{
  "attribute": "country_code",
  "in": ["PL", "AE", "US"]
}
```

Code snippet:

```elixir
iex> Flaggy.put_feature(:my_feature, %{"rules" => %{"attribute" => "x", "in" => ["y", "z"]}})
iex> Flaggy.active?(:my_feature, %{"x" => "y"})
true
iex> Flaggy.active?(:my_feature, %{"x" => "z"})
true
iex> Flaggy.active?(:my_feature, %{"x" => "x"})
false
```

### `all`

Checks if all sub-rules are met.

#### Example

JSON snippet:

```json
{
  "all": [
    {
      "attribute": "country_code",
      "in": ["PL", "AE", "US"]
    },
    {
      "attribute": "user_id",
      "in": [1, 2, 3, 4, 5]
    }
  ]
}
```

Code snippet:

```elixir
iex> Flaggy.put_feature(:my_feature, %{"rules" => %{"all" => [
        %{
          "attribute" => "x",
          "is" => "y"
        },
        %{
          "attribute" => "a",
          "is" => "b"
        }
      ]}})
iex> Flaggy.active?(:my_feature, %{"x" => "y", "a" => "b"})
true
iex> Flaggy.active?(:my_feature, %{"x" => "y"})
false
iex> Flaggy.active?(:my_feature, %{"a" => "b"})
false
iex> Flaggy.active?(:my_feature, %{"x" => "z", "a" => "b"})
false
```

### `any`

Checks if any of sub-rules is met.

#### Example

JSON snippet:

```json
{
  "any": [
    {
      "attribute": "country_code",
      "in": ["PL", "AE", "US"]
    },
    {
      "attribute": "user_id",
      "in": [1, 2, 3, 4, 5]
    }
  ]
}
```

Code snippet:

```elixir
iex> Flaggy.put_feature(:my_feature, %{"rules" => %{"any" => [
        %{
          "attribute" => "x",
          "is" => "y"
        },
        %{
          "attribute" => "a",
          "is" => "b"
        }
      ]}})
iex> Flaggy.active?(:my_feature, %{"x" => "y", "a" => "b"})
true
iex> Flaggy.active?(:my_feature, %{"x" => "y"})
true
iex> Flaggy.active?(:my_feature, %{"a" => "b"})
true
iex> Flaggy.active?(:my_feature, %{"x" => "z", "a" => "c"})
false
```

### `not`

Checks if sub-rule is not met.

#### Example

JSON snippet:

```json
{
  "not": {
    "attribute": "country_code",
    "in": ["PL", "AE", "US"]
  }
}
```

Code snippet:

```elixir
iex> Flaggy.put_feature(:my_feature, %{"rules" => %{"not" => %{
        "attribute" => "x",
        "is" => "y"
      }}})
iex> Flaggy.active?(:my_feature, %{"x" => "y"})
false
iex> Flaggy.active?(:my_feature, %{"x" => "z"})
true
iex> Flaggy.active?(:my_feature, %{"a" => "b"})
true
iex> Flaggy.active?(:my_feature, %{})
true
```

## Fault tolerance

The `Flaggy.active?/2` function is guaranteed to return `false` instead of raising in following
circumstances:

- feature doesn't exist or was removed
- rule uses non-sent attribute
- source is unavailable (but raises if JSON file doesn't exist)
- feature/rule definition is malformed
