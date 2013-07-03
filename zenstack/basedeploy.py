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


class BaseDeploy(object):

    name = "Base"
    description = "The base deploy that defines the deploy interface"
    target = None

    def __init__(self, target):
        self.target = target
        self.initialize()

    def configure(self):
        zs.task("Configuring deployment %s" % self.name)

    def initialize(self):
        zs.task("Initializing deployment %s" % self.name)

    def install_deploy(self):
        zs.task("Installing deployment %s" % self.name)

    def post_deploy(self):
        zs.task("Cleaning-up deployment %s" % self.name)
