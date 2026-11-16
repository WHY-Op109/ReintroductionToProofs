import Lake
open Lake DSL

-- Using this assumes that each dependency has a tag of the form `v4.X.0`.
def leanVersion : String := s!"v{Lean.versionString}"

/--
Use the GameServer from a `leangame` folder lying next to the game on your local computer.
Activated with `lake update -R -Kleangame.local --keep-toolchain`.
-/
def LocalGameServer : Dependency := {
  name := `GameServer
  scope := "hhu-adam"
  src? := DependencySrc.path "../leangame/server/lean"
  version := .none
  opts := ∅
}

/--
Use the GameServer version from github.
The `main` branch is used because GameServer has no tag for Lean release candidates.
Deactivate local version with `lake update -R`.
-/
def RemoteGameServer : Dependency := {
  name := `GameServer
  scope := "hhu-adam"
  src? := DependencySrc.git "https://github.com/hhu-adam/GameServer.git" "main" .none
  version := .git "main"
  opts := ∅
}

/-
Choose GameServer dependency depending on whether `-Kleangame.local` has been passed to `lake`.
-/
open Lean in
#eval (do
  let gameServerName := if get_config? leangame.local |>.isSome then
    ``LocalGameServer else ``RemoteGameServer
  modifyEnv (fun env => Lake.packageDepAttr.ext.addEntry env gameServerName)
  : Elab.Command.CommandElabM Unit)

/-!
# USER DEPENDENCIES

Add any further dependencies of your game below.

Note: If your package (like `mathlib` or `Std`) has tags of the form `v4.X.0` then
you can use

```
require "leanprover-community" / mathlib @ git leanVersion
```
 -/

-- require "leanprover-community" / mathlib @ git leanVersion

/-!
# PACKAGE CONFIGURATION

Here you can set options used in your game. The player will use the same options as you'll
have set here.

NOTE: The `leanOptions` and `moreServerOptions` influence how the player preceives the game.
For example, it is important to have `linter.all` set to `false` to prevent any linter
warnings from showing up during playing.

NOTE: We abuse the `trace.debug` option to toggle messages in VSCode on and
off when calling `lake build`. Ideally there would be a better way using `logInfo` and
an option like `leangame.verbose`.
-/
package Game where
  /- Used in all cases. -/
  leanOptions := #[
    /- linter warnings might block the player. (IMPORTANT) -/
    ⟨`linter.all, false⟩,
    /- to display the values of let declarations, like `:= 42` (IMPORTANT)  -/
    ⟨`pp.showLetValues, true⟩,
    /- make all assumptions always accessible. -/
    ⟨`tactic.hygienic, false⟩]
  /- Used when calling `lake build`. -/
  moreLeanArgs := #[
    -- TODO: replace with `leangame.verbose`
    "-Dtrace.debug=false"]
  /- Used when opening a file in VSCode or when playing the game. -/
  moreServerOptions := #[
    -- TODO: replace with `leangame.verbose`
    ⟨`trace.debug, true⟩]

@[default_target]
lean_lib Game

-- `master` is used to follow the newest mathlib, which may be on a Lean release candidate.
require "leanprover-community" / mathlib @ git "master"
