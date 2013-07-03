#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
import sys
import pkgutil

from clint.textui import puts, indent, colored


def select_package_list(package, selection_type):
    current_module = sys.modules[package]
    target_pkgs = import_all_from_package(current_module)
    valid_selection = False
    while not valid_selection:
        i = 1
        log("Select %s:" % selection_type.capitalize())
        for target in target_pkgs:
            module = __import__(target, fromlist="dummy")
            log("%d: %s - %s" % (i, module.Target.name,
                                 module.Target.description))
            i += 1
        try:
            selection = int(get_input("(1-%d): " % (i-1))) - 1
            if 0 <= selection < i:
                module = __import__(target_pkgs[selection], fromlist="dummy")
                message("Selected %s %s." % (module.Target.name,
                                             selection_type))
                return module.Target
        except ValueError:
            pass
        error("Invalid selection.")


def get_input(prompt):
    return raw_input(prompt)


def import_all_from_package(package):
    prefix = package.__name__ + "."
    packages = list()
    for importer, modname, ispkg in pkgutil.iter_modules(
            package.__path__, prefix):
        packages.append(modname)
    return packages


def message(message):
    with indent(4, quote=colored.green('>')):
        puts(colored.green("%s" % message))


def error(message):
    with indent(4, quote=colored.red('!')):
        puts(colored.red("Error: %s" % message))


def log(message):
    with indent(4, quote=colored.white('.')):
        puts(colored.white("%s" % message))


def task(message):
    with indent(4, quote=colored.blue('#')):
        puts(colored.blue("%s" % message))


def perform(command):
    with indent(4, quote=colored.yellow('@')):
        puts(colored.yellow("%s" % command))
