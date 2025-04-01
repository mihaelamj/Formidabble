# Formidabble

Formidabble is a Swift-based app for rendering and managing complex, hierarchical forms with ease. Designed with clarity, performance, and offline support in mind, it offers a delightful experience for collecting structured data across platforms. Build forms that are not just fillable — but formidabble.

## 🧠 Architecture Philosophy

Formidabble follows a **modular, scalable architecture** inspired by [merowing’s posts](https://www.merowing.info/), with a clear separation of concerns from day one:

- **Workspace-driven structure**  
  Manual creation of `.xcworkspace` avoids entangling logic and UI with IDE-generated clutter.

- **Packages first, App last**  
  Code lives in Swift Packages inside the `Packages/` directory — the app target in `Apps/` is just a thin entry point, importing features from packages.

- **Clean boundaries**  
  Each package (e.g. `AppFeature`, `SharedModels`) has a single responsibility, tests, and no unnecessary dependencies.

- **Extreme Packaging**  
  Everything is wrapped tightly — even utility logic lives in separate targets when needed. This lets you swap, test, or isolate functionality effortlessly.

### 🧱 Example Layering

```
Apps/
└── iOSApp/
	└── AppDelegate.swift → imports AppFeature

Packages/
├── AppFeature/
│   └── AppView.swift → imports HomeFeature
├── HomeFeature/
│   └── HomeView.swift → uses SharedModels
├── SharedModels/
│   └── QItem.swift, Enums.swift
```

> ✅ This approach makes the architecture future-proof, testable, and platform-agnostic from the start.
