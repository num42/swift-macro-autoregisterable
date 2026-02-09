# AutoRegisterable

Synthesizes a `register(in:scope:as:...)` helper for types that declare a nested `Dependencies` struct.

## Usage

```swift
@AutoRegisterable
struct MyService {
  struct Dependencies {
    let api: API
  }
}

// Generated:
// MyService.register(in: container, scope: .shared, as: MyService.self, api: ...)
```

## Notes

Requires a `struct` or `class` with a nested `Dependencies` struct.
