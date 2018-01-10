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

The docs can be found at [https://hexdocs.pm/flaggy](https://hexdocs.pm/flaggy).

## Definition sources

Following definition sources are available:

- *memory* - starts empty and can be filled using `Flaggy.put_definition/2`, useful for testing
- *yaml* - loads definition from YAML file, useful for development
- *protein* - loads, caches and periodically updates definition from RPC server via `Protein`

## Rules

### `is`

Checks equality of specific meta attribute with given value.

#### Example

```yaml
attribute: country_code
is: PL
```

### `in`

Checks inclusion of specific meta attribute in a set of given values.

#### Example

```yaml
attribute: country_code
in:
  - PL
  - AE
  - US
```

### `all`

Checks if all sub-rules are met.

#### Example

```yaml
all:
  -
    attribute: country_code
    in: ["PL", "AE", "US"]
  -
    attribute: user_id
    in: [1, 2, 3, 4, 5]

```

### `any`

Checks if any of sub-rules is met.

#### Example

```yaml
any:
  -
    attribute: country_code
    in: ["PL", "AE", "US"]
  -
    attribute: user_id
    in: [1, 2, 3, 4, 5]

```

### `not`

Checks if sub-rule is not met.

#### Example

```yaml
not:
  attribute: country_code
  in: ["PL", "AE", "US"]
```

## Fault tolerance

The `Flaggy.active?/2` function is guaranteed to return `false` instead of raising in following
circumstances:

- feature doesn't exist or was removed
- rule uses non-sent attribute
- source is unavailable (but raises if YAML file doesn't exist)
- feature/rule definition is malformed
