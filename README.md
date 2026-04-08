# SwiftLogger

[![CI](https://github.com/sweetloser/SwiftLogger/actions/workflows/ci.yml/badge.svg)](https://github.com/sweetloser/SwiftLogger/actions)
[![Version](https://img.shields.io/github/v/tag/sweetloser/SwiftLogger)](https://github.com/sweetloser/SwiftLogger/tags)
![Swift](https://img.shields.io/badge/Swift-6.1-orange.svg)
![Platform](https://img.shields.io/badge/platform-iOS-lightgrey)
[![License](https://img.shields.io/github/license/sweetloser/SwiftLogger)](https://github.com/sweetloser/SwiftLogger/blob/main/LICENSE)

一个轻量、高性能、线程安全（Swift Concurrency 友好）的日志库，包含：

- `SwiftLogger`：控制台/标准输出日志能力
- `FileLogger`：高吞吐文件日志与滚动（rotation）能力

---

## 目录

- [特性概览](#特性概览)
- [安装](#安装)
- [快速开始](#快速开始)
- [日志级别](#日志级别)
- [Metadata 使用方式](#metadata-使用方式)
- [自定义 LoggingSystem（全局 Bootstrap）](#自定义-loggingsystem全局-bootstrap)
- [FileLogger（文件日志）](#filelogger文件日志)
  - [按大小滚动](#按大小滚动)
  - [按时间滚动](#按时间滚动)
  - [使用工厂创建 Handler](#使用工厂创建-handler)
- [输出格式说明](#输出格式说明)
- [性能与并发设计](#性能与并发设计)
- [测试](#测试)
- [常见问题（FAQ）](#常见问题faq)
- [版本与兼容性](#版本与兼容性)
- [贡献](#贡献)
- [License](#license)

---

## 特性概览

- 🚀 轻量快速：核心 API 简洁、无额外重量级依赖。
- 🧵 并发友好：`LogHandler` 协议为 `Sendable` 体系，适配 Swift 6 并发模型。
- 🧩 可扩展：可通过自定义 `LogHandler` 输出到任意目标（网络、数据库、系统日志等）。
- 🧾 丰富元数据：支持 logger 级 metadata、调用级 metadata、全局 metadata provider。
- 📁 文件落盘：`FileLogger` 提供高吞吐写入与轮转策略（按大小/按时间）。
- 🔁 可组合：提供 `RotatingFileLogHandlerFactory` 便于统一配置并批量创建 handler。

---

## 安装

### Swift Package Manager

在你的 `Package.swift` 中添加依赖：

```swift
dependencies: [
    .package(url: "https://github.com/sweetloser/SwiftLogger.git", from: "1.0.0")
]
```

按需引入产品：

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "SwiftLogger", package: "SwiftLogger"),
        .product(name: "FileLogger", package: "SwiftLogger") // 如需文件日志
    ]
)
```

或在 Xcode 中：

`File -> Add Packages...` 后粘贴仓库地址。

---

## 快速开始

### 1) 默认日志（stderr）

```swift
import SwiftLogger

var logger = Logger(label: "com.example.app")
logger.info("应用启动")
logger.error("发生错误")
```

### 2) 设置日志级别

```swift
logger.logLevel = .debug
logger.debug("仅 debug 及以上级别会输出")
```

### 3) 使用便捷 API

```swift
logger.trace("trace")
logger.debug("debug")
logger.info("info")
logger.notice("notice")
logger.warning("warning")
logger.error("error")
logger.critical("critical")
```

---

## 日志级别

支持级别（从低到高）：

`trace < debug < info < notice < warning < error < critical`

`Logger` 会根据 `logLevel` 过滤：仅输出 **大于等于当前级别** 的日志。

> 例如：`logLevel = .info` 时，会输出 `info / notice / warning / error / critical`。

---

## Metadata 使用方式

`SwiftLogger` 支持 3 层 metadata 合并：

1. Logger 自身 metadata（常驻）
2. MetadataProvider（全局/上下文动态注入）
3. 调用点传入 metadata（本次日志）

后写入会覆盖前面同名 key（优先级：调用点 > provider > logger）。

```swift
import SwiftLogger

var logger = Logger(label: "com.example.api")
logger[metadataKey: "service"] = "user"
logger[metadataKey: "env"] = "prod"

logger.info("request received", metadata: [
    "request_id": "abc-123",
    "path": "/v1/profile"
])
```

还支持数组与字典等复合 metadata 值：

```swift
logger.info("payload", metadata: [
    "tags": ["ios", "beta"],
    "user": ["id": "1001", "role": "admin"]
])
```

---

## 自定义 LoggingSystem（全局 Bootstrap）

你可以在应用启动时调用 `LoggingSystem.bootstrap` 注入全局 handler 工厂。

> ⚠️ 注意：`bootstrap` 设计为“进程生命周期只初始化一次”。重复初始化会触发 precondition。

### 示例：改为输出到 stdout

```swift
import SwiftLogger

LoggingSystem.bootstrap { label in
    StreamLogHandler.standardOutput(label: label)
}

var logger = Logger(label: "com.example.main")
logger.info("hello stdout")
```

### 示例：同时注入全局 MetadataProvider

```swift
import SwiftLogger

let provider = Logger.MetadataProvider {
    ["app_version": "1.2.0", "region": "us"]
}

LoggingSystem.bootstrap({ label, metadataProvider in
    StreamLogHandler.standardError(label: label, metadataProvider: metadataProvider)
}, metadataProvider: provider)
```

---

## FileLogger（文件日志）

`FileLogger` 在并发写入场景下使用线程本地缓存（TLS）+ 批量 flush + 排序写入，兼顾吞吐与顺序稳定性。

### 按大小滚动

使用 `SizeRotatingFileLogHandler`，当即将写入的数据导致文件大小超过阈值时自动切换到下一个文件。

```swift
import SwiftLogger
import FileLogger

let path = "/tmp/app.log"

LoggingSystem.bootstrap { label in
    SizeRotatingFileLogHandler(
        label: label,
        path: path,
        encoding: .utf8,
        options: 10 * 1024 * 1024, // 10 MB
        max: 7                       // 最多保留 7 个轮转片段（按实现策略使用）
    )
}

var logger = Logger(label: "com.example.file")
logger.info("write to file")
```

输出文件类似：

- `/tmp/app.log.0`
- `/tmp/app.log.1`
- `/tmp/app.log.2`

### 按时间滚动

`DateRotateOption` 支持：

- `.seconds(n)` / `.minutes(n)` / `.hours(n)`
- `.days(n)` / `.weeks(n)` / `.months(n)` / `.years(n)`
- 便捷值：`.hourly`、`.daily`、`.weekly`、`.monthly`、`.yearly`

也支持语法糖：

- `1.hours`
- `3.days`
- `2.weeks`

> 可与基于时间滚动的 handler（如 `RotatingFileLogHandler` 的时间实现）组合使用。

### 使用工厂创建 Handler

当你需要在多个模块用统一规则创建 rotating handler 时，可使用工厂：

```swift
import FileLogger

let factory = RotatingFileLogHandlerFactory<SizeRotatingFileLogHandler>(
    path: "/tmp/app.log",
    options: 5 * 1024 * 1024,
    encoding: .utf8,
    max: 10
)

let handler = factory.makeRotatingFileLogHandler(label: "com.example.worker")
```

---

## 输出格式说明

### StreamLogHandler（控制台）

典型格式：

```text
2026-04-08 10:30:45UTC info com.example.api: key=value [MyModule] message
```

包含：

- 时间戳
- 日志级别
- label
- metadata
- source（通常来自 `#fileID` 所属模块）
- message

### FileLogger（文件）

典型格式：

```text
2026-04-08T10:30:45.123Z [info] com.example.api: key=value message
```

当 `logLevel <= .debug` 时，格式中还会附带 `(file:line function)` 便于排查。

---

## 性能与并发设计

`FileLogger` 的关键策略：

1. **Thread Local Buffer**：每线程写入本地缓存，减少锁竞争。
2. **批量 drain**：缓存达到容量时，异步集中收集所有线程缓存写盘。
3. **全局排序**：写盘前按 `timestamp + seq` 排序，尽量保证全局时间顺序。
4. **析构兜底**：线程退出时会回收残留缓存，减少日志丢失风险。
5. **周期 flush（adaptive）**：空闲时增大间隔，活跃时保持积极刷盘。

> 这套设计适合日志量较高、并发来源较多的业务场景。

---

## 测试

```bash
swift test
```

项目包含 `SwiftLogger` 核心行为测试（级别、metadata、handler、locking 等）。

---

## 常见问题（FAQ）

### Q1：为什么我调用 `LoggingSystem.bootstrap` 第二次会崩溃？

A：这是预期行为。`bootstrap` 设计为“只允许初始化一次”，请在应用入口统一配置。

### Q2：我想在不同模块用不同 handler 怎么办？

A：可以直接使用 `Logger(label:factory:)` 或 `Logger(label:factory(with provider):)` 创建局部 logger，不依赖全局 bootstrap。

### Q3：metadata 重名时哪个生效？

A：调用点 metadata 优先级最高，其次 provider，最后 logger 自身 metadata。

### Q4：是否只支持 iOS？

A：README 徽章标注了 iOS，源码层面基于 Foundation 与 SwiftPM，具体平台以你的构建环境和部署目标为准。

---

## 版本与兼容性

- Swift tools: `6.1`
- README 当前建议：Swift `6.2+`
- 目标平台：以 `Package.swift` 与你的工程配置为准

---

## 贡献

欢迎 PR 与 Issue：

1. Fork 本仓库
2. 创建特性分支
3. 提交变更与测试
4. 发起 Pull Request

---

## License

MIT。详见 [LICENSE](./LICENSE)。
