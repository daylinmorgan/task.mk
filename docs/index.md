<div align="center">
  <h1 align="center"> task.mk </h1>
  <img src="https://raw.githubusercontent.com/daylinmorgan/task.mk/main/assets/help.svg" alt="help" width=400 >
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

- ANSI escape code support (including NO\_COLOR)
- formatted help output
- custom print function
- confirmation prompt

Depends on `GNU Make`, obviously and `Python >=3.7`.

Wait python?!?!, I'm not `pip` installing some package just to parse my makefile.
I agree, all you need is one file [`.task.mk`](./task.mk).
You can automagically include it with just two additional lines to your `Makefile` (and probably one to your `.gitignore`) and your good to go.

## Setup

You can include this as an optional dependency on your project by adding the below lines to the end of your `Makefile`.
If someone tries to invoke `make help` it will download `.task.mk` for them.

```make
-include .task.mk
$(if $(filter help,$(MAKECMDGOALS)),$(if $(wildcard .task.mk),,.task.mk: ; curl -fsSL https://raw.githubusercontent.com/daylinmorgan/task.mk/v22.9.14/task.mk -o .task.mk))
```

You might also consider making it a consistently downloaded dependency if you plan to use any of it's advanced feature set, by dropping the `$(MAKECMDGOALS)` check.

```make
-include .task.mk
$(if $(wildcard .task.mk),,.task.mk: ; curl -fsSL https://raw.githubusercontent.com/daylinmorgan/task.mk/v22.9.14/task.mk -o .task.mk)
```

Alternatively, you can use the builtin rule `_update-task.mk` to update to the latest development version.

See [Usage](./usage) to get started running all your tasks.
See [Examples](./examples) for more use cases.

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
