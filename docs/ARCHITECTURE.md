# Architecture

🌐 **English** | [日本語](/docs/ARCHITECTURE.ja.md)

## Basic Flow

1. `YSNRunner` loads and executes a `YSNScenario`
2. The `YSNCue`s contained in the `YSNScenario` are executed in order
3. Runtime state is stored in `YSNInstance` and each cue's `State`
4. State can be captured with `YSNRunner.capture()` and restored with `YSNRunner.restore()`

## Main Classes

### `YSNRunner`
<sub>extends `Node`</sub>

A `Node` class that executes scenarios.  
A single `YSNRunner` can execute multiple scenarios at the same time.  

- `act()` starts a scenario.
- `capture()` captures the state of currently running scenarios.
- `restore()` restores a previously captured state.

Addon users are expected to attach `YSNRunner` to in-game nodes such as the world, characters, or doors, and execute a `YSNScenario` from script.  

### `YSNScenario`
<sub>extends `Resource`</sub>

Manages multiple cues and the connections between them.  
A single graph corresponds to one `YSNScenario`.  
Addon users edit `YSNScenario` in the graph editor to define the flow of a single scenario.  

### `YSNCue`
<sub>extends `Resource`</sub>

A single graph node corresponds to one `YSNCue`.  
A variety of derived classes are provided.  
Addon users define each unit of behavior by writing subclasses of `YSNCue`.  
In most cases, however, `YSNCue` does not need to be inherited directly, and the following three base classes are the recommended entry points.  

- `YSNCueStateless`
- `YSNCueAsync`
- `YSNCueReactive`

#### `YSNCueStateless`
<sub>extends `YSNCue`</sub>

A simple cue that does not keep state.  
It is mainly used for behavior that completes immediately.  

#### `YSNCueStateful`
<sub>extends `YSNCue`</sub>

A cue that keeps state.  
It is the shared foundation of `YSNCueAsync` and `YSNCueReactive`, and addon users will rarely need to inherit from `YSNCueStateful` directly.  

#### `YSNCueAsync`
<sub>extends `YSNCueStateful`</sub>

A cue for asynchronous behavior.  
It creates a new state each time it is executed.  

#### `YSNCueReactive`
<sub>extends `YSNCueStateful`</sub>

A cue that can receive multiple flows.  
One state is created per instance.  
Unlike `YSNCueAsync`, it can still be interrupted or otherwise interacted with by another cue after execution has started, such as through re-entry, interruption, or notifications.  

#### `YSNCueStateful.State`
<sub>extends `RefCounted`</sub>

The concrete representation of state.  
It is held by `YSNInstance`, and encoding / decoding logic for `YSNRunner.capture()` and `YSNRunner.restore()` is also implemented in `State`.  
When defining a cue that inherits from `YSNCueAsync` or `YSNCueReactive`, a corresponding `State` type also needs to be defined by inheritance.  

#### `YSNInstance`
<sub>extends `RefCounted`</sub>

Created each time `YSNRunner.act()` is called.  
It is associated with a `YSNScenario` and processes the behavior of a single scenario.  

#### `YSNContext`
<sub>extends `RefCounted`</sub>

A context object passed whenever processing such as `YSNCue` execution is invoked.  
`YSNContext` can be used to access the runner and other runtime objects.
