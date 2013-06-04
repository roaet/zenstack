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

    def __init__(self):
        pass

    def initialize(self):
        zs.log("Initializing target %s" % self.name)

    def install_target(self):
        zs.log("Installing target %s" % self.name)

    def post_install(self):
        zs.log("Cleaning-up target %s" % self.name)


Target = NoopTarget
