---
name: emacs-introspection
description: "Use for finding information in Emacs including the help system (C-h), describe-function, describe-variable, describe-key, describe-mode, describe-symbol, apropos, Info manuals, source code navigation (find-function, xref, M-.), shortdoc function groups, Elisp introspection functions, emacs --batch --eval for programmatic queries, emacsclient --eval, or when the user asks how to look up, discover, or query Emacs functionality interactively or from scripts."
user-invocable: false
---

# Finding Information in Emacs

How to use Emacs' built-in help system, Info reader, introspection tools, and programmatic access via `emacs --batch`.

## The Help Prefix (`C-h`)

`C-h` is the gateway. Press `C-h C-h` to see all help commands. Press `C-h C-q` for a quick cheat sheet.

### The Essential Eight

These cover 90% of lookup needs:

| Key | Command | What it does |
|-----|---------|-------------|
| `C-h f` | `describe-function` | Function docstring, arglist, source file |
| `C-h v` | `describe-variable` | Variable value, docstring, buffer-local status |
| `C-h k` | `describe-key` | What command a key sequence runs, with full docs |
| `C-h o` | `describe-symbol` | Everything about a symbol (function + variable + face) |
| `C-h m` | `describe-mode` | Current major mode and all active minor modes |
| `C-h b` | `describe-bindings` | Every active keybinding in the current buffer |
| `C-h x` | `describe-command` | Like `C-h f` but restricted to interactive commands |
| `C-h w` | `where-is` | Which key(s) run a given command |

### More Help Commands

| Key | Command | What it does |
|-----|---------|-------------|
| `C-h c` | `describe-key-briefly` | Command name for a key (echo area, no popup) |
| `C-h a` | `apropos-command` | Find commands matching a pattern |
| `C-h d` | `apropos-documentation` | Search documentation strings |
| `C-h i` | `info` | Open the Info manual browser |
| `C-h r` | `info-emacs-manual` | Jump to the Emacs manual |
| `C-h R` | `info-display-manual` | Choose a manual by name |
| `C-h S` | `info-lookup-symbol` | Look up a symbol in the language-appropriate manual |
| `C-h F` | `Info-goto-emacs-command-node` | Find a command in the Emacs manual |
| `C-h K` | `Info-goto-emacs-key-command-node` | Find a key in the Emacs manual |
| `C-h p` | `finder-by-keyword` | Browse packages by category |
| `C-h P` | `describe-package` | Documentation for a specific package |
| `C-h l` | `view-lossage` | Last 300 keystrokes (replay what just happened) |
| `C-h e` | `view-echo-area-messages` | Message history |
| `C-h .` | `display-local-help` | Help-echo text at point |
| `C-h n` | `view-emacs-news` | Release notes |

### Built-in Documents

`C-h t` is the interactive tutorial. `C-h C-f` is the FAQ. `C-h C-p` covers known issues. `C-h C-d` explains how to debug Emacs with GDB. `C-h C-a` shows version, license, and credits.

### Navigating Help Buffers

In a `*Help*` buffer:

| Key | Action |
|-----|--------|
| `TAB` / `S-TAB` | Jump between hyperlinks |
| `RET` | Follow hyperlink at point |
| `s` | Jump to source code of the described item |
| `i` | Look up in Info manual |
| `I` | Look up in Elisp Reference Manual |
| `c` | Open customization for a variable or face |
| `l` / `r` | History back / forward |
| `q` | Quit help window |

The `s` key is the fastest path from "what does it do?" to "how does it work?" — after `C-h f some-function`, press `s` to jump to the source definition.

## The Describe Family

Emacs has 39 `describe-*` commands. Beyond the essential eight, here are the rest grouped by domain.

### Keys and Bindings

`describe-keymap` shows all bindings in a specific named keymap. `describe-prefix-bindings` shows what follows a prefix key — `C-x C-h` shows everything after `C-x`, works with any prefix. `describe-personal-keybindings` shows `bind-key` and `use-package :bind` overrides.

### Modes

`describe-minor-mode` documents a specific minor mode. `describe-minor-mode-from-indicator` identifies a minor mode from its mode-line lighter.

### Text and Display

`describe-char` tells everything about the character at point: unicode, properties, overlays, face, font. `describe-text-properties` shows all text properties at point. `describe-face` gives face attributes. `describe-font` shows low-level font metrics. `describe-syntax` shows the syntax table. `describe-current-display-table` shows how characters render.

### International

`describe-coding-system` gives encoding details. `describe-current-coding-system` shows active encoding for the buffer. `describe-input-method` shows keystroke-to-character mapping. `describe-language-environment` covers charset, encoding, and input method support.

### Packages, Themes, Widgets

`describe-package` shows metadata, dependencies, status. `describe-theme` gives color theme docs and face assignments. `describe-widget` shows widget properties at point.

## Apropos: Finding What You Don't Know the Name Of

When you don't know the exact name, search by pattern.

| Command | Searches |
|---------|----------|
| `apropos-command` (`C-h a`) | Interactive command names |
| `apropos-documentation` (`C-h d`) | Documentation strings of all symbols |
| `apropos` | Names of functions, variables, and faces |
| `apropos-function` | Function names (including non-interactive) |
| `apropos-variable` | All variable names |
| `apropos-value` | Values of variables and function definitions |
| `apropos-user-option` | `defcustom` variable names |
| `apropos-library` | Symbols defined in a specific library file |
| `apropos-local-variable` | Buffer-local variables |

### Pattern Syntax

A single word like `"buffer"` matches anything containing "buffer". Multiple words like `"buffer read only"` match symbols containing at least two of those words. If the pattern contains `^$*+?.\[`, it's treated as a regular expression. There is also a synonym system (`apropos-synonyms`) so "find" also matches "open" and "edit".

### Reading Apropos Output

Each result shows the symbol name (clickable), type indicators (`c` command, `f` function, `m` macro, `v` variable, `u` user option, `a` face), key bindings if any, and the first line of the docstring.

## The Info Reader

Info is the primary documentation format for GNU software. Emacs ships with the complete Emacs Manual, Elisp Reference Manual, and 30+ subsystem manuals.

### Opening Info

| Key | What it opens |
|-----|---------------|
| `C-h i` | Top-level directory with all manuals |
| `C-h r` | GNU Emacs Manual |
| `C-h R` | Choose a manual by name (TAB for completion) |
| `C-h F` | Find a command's section in the manual |
| `C-h K` | Find a key's section in the manual |
| `C-h S` | Look up a symbol in the language-appropriate manual |

### Navigation

`n`/`p` move to next/previous node at same level. `u` goes up to the parent node. `]`/`[` move in reading order (into children). `m` selects a menu item by name. `f` follows a cross-reference. `l`/`r` for history back/forward. `d` goes to the top-level directory. `q` quits.

### Searching

`i` searches the manual's index — the best approach for finding specific items. `,` jumps to the next index match. `I` is a virtual index (regexp search of all index entries). `s` does full-text search. `M-x info-apropos` searches indices across all installed manuals.

Index search (`i`) is better than text search (`s`) because the index is curated and points to the most relevant section.

### `info-lookup-symbol` (`C-h S`)

Language-aware: in an Elisp buffer it searches the Elisp Reference Manual index, in a C buffer it searches the C library manual, in a Python buffer it searches the Python manual (if installed). With cursor on `mapcar` in an Elisp buffer: `C-h S mapcar RET` opens the manual at the mapcar definition.

## Source Code Navigation

### find-function Family

| Command | What it finds |
|---------|--------------|
| `find-function` | Source definition of a function |
| `find-variable` | Source definition of a variable |
| `find-face-definition` | Source of a face definition |
| `find-library` | Library file by name |
| `find-function-on-key` | Source of the command bound to a key |
| `find-function-at-point` | Source of symbol at point |
| `find-variable-at-point` | Source of variable at point |

Shortcut from Help: in any `*Help*` buffer, press `s` to jump to source.

### xref (Cross-reference Framework)

| Key | Command | Action |
|-----|---------|--------|
| `M-.` | `xref-find-definitions` | Jump to definition of symbol at point |
| `M-?` | `xref-find-references` | Find all references to symbol at point |
| `M-,` | `xref-go-back` | Go back after jumping |
| `C-M-,` | `xref-go-forward` | Go forward |

xref works across languages — it uses etags, Eglot/LSP, or grep depending on what's available.

## Shortdoc: Function Groups by Topic

`M-x shortdoc` shows common functions organized by topic with live examples and expected output.

Available groups: `string`, `list`, `alist`, `sequence`, `number`, `vector`, `regexp`, `buffer`, `process`, `file-name`, `file`, `hash-table`, `keymaps`, `text-properties`, `overlay`, `symbol`, `comparison`, `map`.

Each entry shows the function signature, description, and a live example.

## Automatic and Contextual Help

### ElDoc

Displays function signatures and variable types in the echo area as you type. Enabled globally by default via `global-eldoc-mode`. While typing `(mapcar |)`, the echo area shows `mapcar: (FUNCTION SEQUENCE)`.

Key settings: `eldoc-idle-delay` (default 0.5), `eldoc-echo-area-use-multiline-p`, and `M-x eldoc-doc-buffer` for full docs in a dedicated buffer.

### Completion Annotations

When using `M-x`, `C-h f`, or `C-h v`, each completion candidate shows a type indicator and first line of its docstring. This turns completion into a discovery tool.

## Elisp Introspection Functions

Building blocks for programmatic queries. Use in `M-:`, `*scratch*`, or batch mode.

### Documentation

```elisp
;; Function docstring
(documentation 'mapcar t)

;; Variable docstring
(documentation-property 'tab-width 'variable-documentation)

;; Function arglist
(help-function-arglist 'mapcar)
;; => (FUNCTION SEQUENCE)
```

### Finding Where Things Come From

```elisp
;; Which file defines a function?
(symbol-file 'python-mode 'defun)

;; Which file defines a variable?
(symbol-file 'tab-width 'defvar)

;; Is this a C primitive or Elisp?
(subrp (symbol-function 'forward-char))  ;; => t (C)
(subrp (symbol-function 'forward-word))  ;; => nil (Elisp)

;; Is it native-compiled?
(subr-native-elisp-p (symbol-function 'forward-word))

;; Where is a library file?
(locate-library "org")
```

### Discovering API Surfaces

```elisp
;; All functions with a prefix
(apropos-internal "^font-lock-" #'functionp)

;; All commands with a prefix
(apropos-internal "^describe-" #'commandp)

;; All user options with a prefix
(apropos-internal "^org-" #'custom-variable-p)
```

### Key Binding Introspection

```elisp
;; What command is on a key?
(key-binding (kbd "C-x C-f"))
;; => find-file

;; What keys run a command?
(where-is-internal 'find-file)

;; Human-readable:
(mapconcat #'key-description (where-is-internal 'find-file) ", ")
```

### Symbol Properties

```elisp
;; Property list reveals metadata the docs don't mention
(symbol-plist 'font-lock-mode)

;; Is a variable safe as a file-local variable?
(get 'tab-width 'safe-local-variable)

;; Get the customize type (valid values)
(require 'cus-edit)
(custom-variable-type 'font-lock-maximum-decoration)
```

### Feature and Capability Testing

```elisp
(featurep 'native-compile)   ;; native compilation?
(featurep 'treesit)           ;; tree-sitter?
features                      ;; all loaded features
emacs-version                 ;; version string
system-type                   ;; OS type
system-configuration-options  ;; build flags
```

### Simulating a File Open

```elisp
;; What mode + minor modes activate for a .py file?
(with-temp-buffer
  (setq buffer-file-name "/tmp/test.py")
  (set-auto-mode)
  (cons major-mode
        (seq-filter (lambda (m) (and (boundp m) (symbol-value m)))
                    minor-mode-list)))
```

## Programmatic Access from Outside Emacs

For scripts, CI, and AI agents. Two approaches: batch mode (standalone) and emacsclient (persistent).

### `emacs --batch --eval`

Starts a fresh Emacs, evaluates code, and exits. No GUI, no user config.

```bash
# Function documentation
emacs --batch --eval '(princ (documentation '\''mapcar t))' 2>/dev/null

# What command a key runs
emacs --batch --eval '(princ (key-binding (kbd "C-x C-f")))' 2>/dev/null

# What keys run a command
emacs --batch --eval '(princ (mapconcat #'\''key-description (where-is-internal '\''find-file) ", "))' 2>/dev/null

# List functions matching a prefix
emacs --batch --eval '(princ (mapconcat #'\''symbol-name (apropos-internal "^font-lock-" #'\''functionp) "\n"))' 2>/dev/null

# Function arglist
emacs --batch --eval '(princ (help-function-arglist '\''make-overlay))' 2>/dev/null

# Where a function is defined
emacs --batch --eval '(princ (symbol-file '\''python-mode '\''defun))' 2>/dev/null

# Check if a feature exists
emacs --batch --eval '(princ (featurep '\''native-compile))' 2>/dev/null

# Load a library first, then query
emacs --batch --eval '(progn
  (require '\''auth-source)
  (princ (documentation '\''auth-source-search t)))' 2>/dev/null
```

### Temp File Pattern for Large Output

```bash
emacs --batch --eval '(with-temp-file "/tmp/emacs-result.txt"
  (dolist (fn (apropos-internal "^overlay-" #'\''functionp))
    (insert (format "%s: %s\n\n" fn (documentation fn)))))' 2>/dev/null
cat /tmp/emacs-result.txt
```

### `emacsclient --eval`

Connects to a running Emacs server. Faster (no cold start), has access to user config and loaded state.

```bash
# Requires: M-x server-start or emacs --daemon first
emacsclient --eval '(documentation '\''mapcar t)'
emacsclient --eval '(buffer-list)'
```

### Comparison

| | `emacs --batch --eval` | `emacsclient --eval` |
|-|----------------------|---------------------|
| Startup | ~0.5-1.0s (cold) | ~0.1s (warm) |
| Requires server | No | Yes |
| State persistence | None (fresh each call) | Shared with running Emacs |
| User config | Not loaded | Loaded |
| Best for | Scripts, CI, standalone queries | Interactive workflows |

### Batch Mode Limitations

No state between calls — each invocation is a fresh process. Use `(progn ...)` to chain operations. No GUI — functions requiring interactive input silently fail. Libraries aren't loaded by default — use `(require 'library)` or `--load file.el`. Output goes to stdout/stderr — use `princ` for stdout and `2>/dev/null` to suppress startup messages.

## Quick Reference

| I want to know... | Do this |
|---|---|
| What a function does | `C-h f function-name` |
| What a variable controls | `C-h v variable-name` |
| What a key does | `C-h k` then press the key |
| What key runs a command | `C-h w command-name` |
| What this mode provides | `C-h m` |
| All keybindings right now | `C-h b` |
| Everything about a symbol | `C-h o symbol-name` |
| Functions I can't name | `C-h a partial-name` or `C-h d keyword` |
| Read the manual on a topic | `C-h i` then `i topic` |
| Find a command in the manual | `C-h F command-name` |
| How a function is implemented | `C-h f fn` then `s` to jump to source |
| What functions exist for X | `M-x shortdoc` or `(apropos-internal "^prefix-" #'functionp)` |
| What options exist for X | `M-x customize-group` or `M-x customize-apropos` |
| What packages do X | `C-h p` or `M-x list-packages` |
| What changed in this version | `C-h n` |
| A Unix command's manual | `M-x man` or `M-x woman` |
| What just happened | `C-h l` (keystrokes) or `C-h e` (messages) |
| From a script / AI agent | `emacs --batch --eval '(princ (documentation '\''fn t))' 2>/dev/null` |
