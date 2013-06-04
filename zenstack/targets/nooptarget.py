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
import zenstack.common as zs


class NoopTarget(object):

    name = "Noop"
    description = "A no-operation target. Will do nothing"

    def __init__(self):
        pass

    def initialize(self):
        zs.task("Initializing target %s" % self.name)

    def install_target(self):
        zs.task("Installing target %s" % self.name)

    def post_install(self):
        zs.task("Clean-up target %s" % self.name)


Target = NoopTarget
