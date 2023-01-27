# Usage

`Task.mk` can be included in any standard `GNUMakefile`.
If it's been properly sourced you will have access to the below features/recipes.

See [examples](/task.mk/examples) for more info.

## Builtin Recipes

### Help

Invoked with either `make help` or `make h`.

Adding goals to the builtin help recipe just requires documenting your `Makefile` with comments.
The format is `## <recipe> |> <msg>` or `<recipe>: ## <msg>`

```make
## build |> build the project
build:
  ...

build: ## build the project
```

Now when you invoke `make help` it will parse these and generate your help output.
In addition you can add raw text to the help output using the format `### <rawmsg>`.

Both recipe documentation and raw messages can be modified with additional arguments delimited by `|>`.

For example:

```make
### build related recipes |> --align center --divider
build: ## build the project |> --msg-style bold
  ...
package: ## package the project |> -gs b_cyan
```

`Task.mk` can also generate recipe specific help regardless of whether a goal is documented.
This can be invoked by appending the name of a recipe to help call: `make help build`.

All recipes prefixed with and underscore will be hidden even if documented.
However, they can be viewed by invoking `make _help`.

### Vars

In addition to a generic help output you can expose some configuration settings with `make vars` or `make v`.
To do so define the variables you'd like to print with `PRINT_VARS := VAR1 VAR2 VAR3`.

## Builtin Functions

### Phonify

Phonify is a new experimental feature of `task.mk` that solves one of the biggest gotchas of using `make` as a task runner!
It stands to reason the tasks you document are likely to all be phony recipes
Rather than write `.PHONY: <goal>` repeatedly, simply enable `task.mk`'s phonifier.

`Task.mk` will then parse your `Makefile` for documented tasks and 
generate the necessary `.PHONY: <recipes>` line to ensure they are always executed.
To use this feature set the `PHONIFY` environment variable before including `.task.mk`.
To avoid adding a documented task/recipe to `.PHONY`, use `|> --not-phony` after the recipe message.

### Tprint

Besides the `help` and `vars` recipes you can use a custom make function to format your text for fancier output.
For this there are two options depending on your needs `tprint` or `tprint-verbose`
(`tprint-verbose` is for use within a multiline sub-shell that has already been silenced,
see the version-check rule of this project's `Makefile` for an example).

To use `tprint` you call it with the builtin `make` call function.
It accepts only one argument: an unquoted f-string literal.
All strings passed to `tprint` have access to an object `ansi` or `a` for simplicity.
This stores ANSI escape codes which can be used to style your text.

```make
.PHONY: build
build: ## compile the source
  $(call tprint,{a.cyan}Build Starting{a.end})
  ...
  $(call tprint,{a.green}Build Finished{a.end})
```

See this projects `make info` for more examples of `tprint`.

To see the available colors and formatting(bold,italic,etc.) use the hidden recipe `make _print-ansi`.

In addition, you can use custom colors using the builtin `ansi.custom` or (`a.custom`) method.
It has two optional arguments `fg` and `bg`. Which can be used to specify either an 8-bit color from the [256 colors](https://en.wikipedia.org/wiki/8-bit_color).
Or a tuple/list to define an RBG 24-bit color, for instance `a.custom(fg=(5,10,255))`.
See this project's `make info` for an example.

## Configuration

You can quickly customize some of the default behavior of `task.mk` by overriding the below variables prior to the `-include .task.mk`.
These can also for instance included in a seperate file `.task.cfg.mk`.

```make
# ---- [config] ---- #
HEADER_STYLE ?= b_cyan
ACCENT_STYLE ?= b_yellow
PARAMS_STYLE ?= $(ACCENT_STYLE)
GOAL_STYLE ?= $(ACCENT_STYLE)
MSG_STYLE ?= faint
DIVIDER_STYLE ?= default
DIVIDER ?= ─
HELP_SEP ?= │
# python f-string literals
EPILOG ?=
USAGE ?={ansi.$(HEADER_STYLE)}usage{ansi.end}:\n  make <recipe>\n
TASKMK_SHELL ?=
PHONIFY ?=
```

To use a custom color for one of the predefined configuration variables specify only the custom method.

```make
HEADER_STYLE = custom(fg=171,bg=227)
```

**NOTE**: `HELP_SEP` does not change the argument definitions syntax only the format of `make help`.

## Advanced Usage: Embedded Scripts

You can take advantage of the builtin python script runner and write multi-line python scripts of your own.
This is a simple example but a few lines of python in your `Makefile`
may be easier than balancing sub-shells and strung together awk commands.

When `make` expands the function it will take the parameters passed to `py` and expand them.
`$(1)` is the variable name and `$(2)` in this case is the implicit pattern from the rule. Pay attention to quotes.
If you need to debug your python script, use `TASKMK_DEBUG=1` when you run `make` and it will first print the script that will be piped to `python`.

```make
define list_files_py
from pathlib import Path
print("files in $(2)")
print([f.name for f in (Path("$(2)").iterdir())])
endef

## list-% | use pathlib.Path to list files
list-%:
	$(call py,list_files_py,$*)
```

For what it's worth there is also a predefined function for `bash` (named `tbash`) as well should you need to accomplish something similar of more easily embedding your bash script rather than having to escape every line with a backslash.

```make
define bash_script
figlet task.mk 2>/dev/null || echo 'no figlet :('
echo "This is from bash"
cat /etc/hostname
printf "%s\n" "$(2)"
endef
.PHONY: test-bash
test-bash:
	$(call tbash,bash_script,test bash multiline)
```
