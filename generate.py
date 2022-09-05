#!/usr/bin/env python3

import sys
from pathlib import Path

import jinja2

py_script_names = ["help", "ansi", "info", "print-ansi", "vars"]


def get_jinja_env():
    templateLoader = jinja2.FileSystemLoader(searchpath=Path(__file__).parent / "src")
    return jinja2.Environment(
        loader=templateLoader,
        block_start_string="#%",
        block_end_string="%#",
        variable_start_string="##-",
        variable_end_string="-##",
    )


def render(env, template, **kwargs):
    template = env.get_template(template)
    return template.render(**kwargs)


def main():
    if len(sys.argv) == 2:
        version = sys.argv[1]
    else:
        version = "dev"

    env = get_jinja_env()

    py_scripts = [render(env, f"{name}.py") for name in py_script_names]

    print(render(env, "task.mk", py_scripts=py_scripts, version=version))


if __name__ == "__main__":
    main()
