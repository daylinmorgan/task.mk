define USAGE
{a.style('usage','header')}:\n	make <recipe>\n
  Turn your {a.style('`Makefile`','b_magenta')} into
  the {a.italic}{a.underline}task runner{a.end} you always needed.
  See the example output below.\n
endef

EPILOG = \nfor more info: gh.dayl.in/task.mk
PRINT_VARS := VERSION SHELL
PHONIFY = 1

-include .task.mk 
.task.mk: $(TEMPLATES) generate.py
	$(call msg,re-jinjaing the local $(if $(tprint),{a.b_cyan}.task.mk{a.end},.task.mk))
	@./generate.py $(VERSION) > .task.mk || (echo "generator failed!!" && rm .task.mk)
