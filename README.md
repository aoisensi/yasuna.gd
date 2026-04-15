# yasuna

Graph-based stateful scenario addon for Godot 4.

**English** | [日本語](/docs/README.ja.md)

**yasuna** is an addon for building scenario flows by combining cues.  
It is designed to preserve the state of asynchronous actions during execution, allowing save and load at any point during gameplay.  
Rather than providing built-in features for specific games, it is intended to let developers flexibly implement and extend game-specific logic.

> [!WARNING]
> **yasuna** is in an early stage of development.  
> At this time, it is not recommended for production use or even experimental use in real projects.  
> The API, architecture, UI, and other aspects may change significantly in the future.

## Features

- Support for asynchronous cues
- Easy addition of custom cues that implement game-specific logic
- Scenario / flow management through a graph editor similar to `VisualShader`
- A stateful design that allows saving and loading state at any point during execution
- Written in pure GDScript

## License

This addon is released under the MIT License.

## Third-Party Assets

- **[Editor icons](assets/yasuna/editor/resource/icon/)** by _Paweł Kuna_ (MIT License)
