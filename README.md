<div align="center">
  <h1 align="center"> task.mk </h1>
  <img src="./assets/help.svg" alt="help" width=400 >
  <p align="center">
  the task runner for GNU Make you've been missing
  </p>
</div>
</br>

GNU make is an excellent build tool and the task runner we love to hate, but can't escape.
So let's improve the UX to make it the best task runner it can be.

`Task.mk`, is a standalone `Makefile` you can deploy alongside your own
to add some QOL improvements for your users and fellow maintainers.

Current Features:
  - ANSI escape code support (including NO_COLOR)
  - formatted help output
  - custom print function

Depends on `GNU Make`, obviously and `Python >=3.7`.

Wait python?!?!, I'm not `pip` installing some package just to parse my makefile.
I agree, so I've hacked together a file containing the bits of python we need with some tricks to run it.

## Setup

You can include this as an optional dependency on your project by adding the below lines to the end of your `Makefile`.
If someone tries to invoke `make help` it will download `.task.mk` for them.

```make
-include .task.mk
$(if $(filter help,$(MAKECMDGOALS)),$(if $(wildcard .task.mk),,.task.mk: ; curl -fsSL https://raw.githubusercontent.com/daylinmorgan/task.mk/v22.9.7/task.mk -o .task.mk))
```

You might also consider making it a consistently downloaded dependency if you plan to use any of it's advanced feature set, by dropping the `$(MAKECMDGOALS)` check.

```make
-include .task.mk
$(if $(wildcard .task.mk),,.task.mk: ; curl -fsSL https://raw.githubusercontent.com/daylinmorgan/task.mk/v22.9.7/task.mk -o .task.mk)
```

## Usage

`Task.mk` will add access to a recipe `help` (also aliased to `h`).
In order to use `make help` to you will need to add some custom comments to your `Makefile`.

Deliberately, I don't get names from recipes themselves.
This not only greatly simplifies the parsing but add's some opportunity to customize the output.
Such as to document wildcard or redundant recipes.

You can place these anywhere, but I recommend adding these notes directly above their relevant recipes.
The format is `## <recipe> | <msg>`

```make
## build | build the project
.PHONY: build
build:
  ...
```

Now when you invoke `make help` it will parse these and generate your help output.

In addition to a generic help output you can expose some configuration settings with `make vars`.
To do so define the variables you'd like to print with `PRINT_VARS := VAR1 VAR2 VAR3`.

In addition to the `help` and `vars` recipes you can use a custom make function to format your text for fancier output.
For this there are two options depending on your needs `tprint` or `tprint-sh`. (`tprint-sh` is for use within a multiline sub-shell that has already been silenced, see the version-check rule of this project's `Makefile` for an example.)


To use `tprint` you call it with the builtin `make` call function.
It accepts only one argument: an unquoted f-string literal.
All strings passed to `tprint` have access to an object `ansi` or `a` for simplicity.
This stores ANSI escape codes which can be used to style your text.

```make
## build | compile the source
.PHONY: build
build:
  $(call tprint,{a.cyan}Build Starting{a.end})
  ...
  $(call tprint,{a.green}Build Finished{a.end})
```
See this projects `make info` for more examples of `tprint`.

To see the available colors and formatting(bold,italic,etc.) use the hidden recipe `make _print-ansi`.

**Note**: Any help commands starting with an underscore will be ignored.
To view hidden `tasks` (or recipes in GNU Make land) you can use `make _help`.

In addition, you can use custom colors using the builtin `ansi.custom` or (`a.custom`) method.
It has two optional arguments `fg` and `bg`. Which can be used to specify either an 8-bit color from the [256 colors](https://en.wikipedia.org/wiki/8-bit_color).
Or a tuple/list to define an RBG 24-bit color, for instance `a.custom(fg=(5,10,255))`.
See this project's `make info` for an example.

## Configuration

You can quickly customize some of the default behavior of `task.mk` by overriding the below variables prior to the `-include .task.mk`.

```make
# ---- CONFIG ---- #
HEADER_COLOR ?= b_cyan
PARAMS_COLOR ?= b_magenta
ACCENT_COLOR ?= b_yellow
GOAL_COLOR ?= $(ACCENT_COLOR)
MSG_COLOR ?= faint
HELP_SEP ?= |
HELP_SORT ?= # sort goals alphabetically

# python f-string literals
EPILOG ?=
define USAGE ?=
{ansi.$(HEADER_COLOR)}usage{ansi.end}:
  make <recipe>

endef
```

To use a custom color for one of the predefined configuration variables specify only the custom method.

```make
HEADER_COLOR = custom(fg=171,bg=227)
```

**NOTE**: `HELP_SEP` does not change the argument definitions syntax only the format of `make help`.

## Advanced Usage: Embedded Python Scripts

You can take advantage of the builtin python script runner and write multi-line python scripts of your own.
This is a simple example but a few lines of python in your `Makefile`
may be easier than balancing sub-shells and strung together awk commands.

When `make` expands the function it will take the parameters passed to `py` and expand them.
`$(1)` is the variable name and `$(2)` in this case is the implicit pattern from the rule. Pay attention to quotes.
If you need to debug your python script, use `DEBUG=1` when you run `make` and it will first print the script that will be piped to `python`.

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
echo "This is from bash"
cat /etc/hostname
printf "%s\n" "$(2)"
endef
.PHONY: test-bash
test-bash:
	$(call tbash,bash_script,test bash multiline)
```



## Zsh Completions for GNU Make

If you use `GNU Make` with zsh you may want to add the following
line to your rc file to allow `make` to handle the autocomplete.

```zsh
zstyle ':completion::complete:make:*:targets' call-command true
```

## Why Make?

There are lot of `GNU Make` alternatives but none have near the same level of ubiquity.
This project attaches to `make` some of the native features of [`just`](https://github.com/casey/just), a command runner.

Just is a great task runner, but it suffers two problems, users probably don't have it installed already, and there is no way to define file specific recipes.
Most of my `Makefile`'s are comprised primarily of handy `.PHONY` recipes, but I always end up with a few file specific recipes.

Another interesting project I've evaluated for these purposes is [`go-task/task`](https://github.com/go-task/task).
`Task` has many of the features of `GNU Make` and some novel features of it's own.
But like `just` it's a tool people don't usually already have and it's configured using a `yaml` file.
`Yaml` files can be finicky to work with and and it uses a golang based shell runtime, not your native shell, which might lead to unexpected behavior.


## Simpler Alternative

But I just want a basic help output, surely I don't need python for this... you would be right.
`Task.mk` replaces my old `make help` recipe boilerplate which may better serve you (so long as you have `sed`/`awk`).


```make
## h, help | show this help
.PHONY: help h
help h: Makefile
	@awk -v fill=$(shell sed -n 's/^## \(.*\) | .*/\1/p' $< | wc -L)\
		'match($$0,/^## (.*) \|/,name) && match($$0,/\| (.*)$$/,help)\
		{printf "\033[1;93m%*s\033[0m | \033[30m%s\033[0m\n",\
		fill,name[1],help[1];} match($$0,/^### (.*)/,str) \
		{printf "%*s   \033[30m%s\033[0m\n",fill," ",str[1];}' $<
```
