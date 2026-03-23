# SwiftLogger

[![CI](https://github.com/sweetloser/SwiftLogger/actions/workflows/ci.yml/badge.svg)](https://github.com/sweetloser/SwiftLogger/actions) [![Version](https://img.shields.io/github/v/tag/sweetloser/SwiftLogger)](https://github.com/sweetloser/SwiftLogger/tags) ![Swift](https://img.shields.io/badge/Swift-6.1-orange.svg) ![Platform](https://img.shields.io/badge/platform-iOS-lightgrey) [![License](https://img.shields.io/github/license/sweetloser/SwiftLogger)](https://github.com/sweetloser/SwiftLogger/blob/main/LICENSE)

A lightweight, high-performance logging library written in Swift.

---

## ✨ Features

* 🚀 Lightweight & fast
* 🧵 Concurrency-safe (Swift 6)
* 📦 Swift Package Manager support
* 🔧 Customizable log handlers
* 📱 iOS support

---

## 📦 Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sweetloser/SwiftLogger.git", from: "1.0.0")
]
```

Or in Xcode:

```
File → Add Packages → paste repo URL
```

---

## 🚀 Usage

### Basic Example

```swift
import SwiftLogger

var logger = Logger(label: "com.example.app")

logger.info("Hello, world!")
logger.debug("Debug message")
logger.error("Something went wrong")
```

---

### Custom Log Level

```swift
logger.logLevel = .debug
```

---

### Custom Handler

```swift
struct CustomHandler: LogHandler {
    var logLevel: Logger.Level = .info

    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { nil }
        set {}
    }

    var metadata: Logger.Metadata = [:]

    func log(level: Logger.Level, message: Logger.Message,
             metadata: Logger.Metadata?, source: String,
             file: String, function: String, line: UInt) {
        print("[\(level)] \(message)")
    }
}
```

---

## 🧪 Running Tests

```bash
swift test
```

---

## 🛠 CI

This project uses GitHub Actions for continuous integration:

* Build
* Test
* Swift version validation

---

## 📌 Requirements

* Swift 6.2+
* iOS 13+
* macOS 10.15+

---

## 📄 License

This project is licensed under the MIT License.
See the [LICENSE](https://github.com/xxx/SwiftLogger/blob/main/LICENSE) file for details.

---

## 🙌 Contributing

Contributions are welcome!

1. Fork the repo
2. Create a feature branch
3. Submit a PR

---

## ⭐️ Support

If you find this project useful, consider giving it a star ⭐️
