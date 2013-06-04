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
from clint.textui import puts, indent, colored


def message(message):
    with indent(4, quote=colored.green('>')):
        puts(colored.green("%s" % message))


def error(message):
    with indent(4, quote=colored.red('!')):
        puts(colored.red("Error: %s" % message))


def log(message):
    with indent(4, quote=colored.white('.')):
        puts(colored.white("%s" % message))
