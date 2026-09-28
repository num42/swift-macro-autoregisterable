# AutoRegisterable

Synthesizes a `register(in:scope:as:...)` helper for types that declare a nested `Dependencies` struct.

## Requirements

- Swift 6.3 toolchain or later (tested with Xcode 27)
- Platforms: macOS 14, iOS 13, tvOS 13, watchOS 6, macCatalyst 13

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
