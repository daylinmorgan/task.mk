# task.mk

GNU make is the task runner we love to hate, but can't escape. So let's improve the UX for users.

So I give you `task.mk`, a standalone makefile you can deploy alongside your own
`Makefile`'s to add some QOL improvements for your users and fellow maintainers.

Current Features:
  - ANSI Color Support
  - Formatted Help Screen
  - Custom print function

Depends on `GNU Make`, obviously and `Python >=3.7`.

Wait python?!, I'm not `pip` installing some package just to parse my makefile.
I agree, so I've hacked together a file containing the bits of python we need with some tricks to run it.

## Usage

You can include this as an optional dependency on your project by adding the below lines the end of your make file.
When your users first your `make help` it will download `task.mk`.
If you intend to use any of the other features like `tprint` (see below),
I'd recommend committing `.task.mk` into version control so behavior is consistent.

```make
-include .task.mk
$(if $(filter help,$(MAKECMDGOALS)),.task.mk: ; curl -fsSL https://raw.githubusercontent.com/daylinmorgan/task.mk/22.9.5/task.mk -o .task.mk)
```
