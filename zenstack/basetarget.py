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


class BaseTarget(object):

    name = "Base"
    description = "The base target that defines the target interface"
    _package_list = None
    
    def initialize(self):
        zs.task("Initializing target %s" % self.name)

    def install(self):
        zs.task("Installing target %s" % self.name)
        self.make_environment_sane()

    def post_install(self):
        zs.task("Clean-up target %s" % self.name)

    def make_environment_sane(self):
        zs.task("Making the environment sane")

    def __init__(self):
        self.initialize()

    def package_list(self):
        if not self._package_list:
            self._package_list = list()
        return self._package_list

    def check_can_run(self):
        return False

    def repo_install(self, package):
        zs.task("Installing package %s" % package)

    def pip_install(self, package):
        zs.task("Installing with pip %s" % package)

    def repo_add_package(self, packages):
        """packages is expected to be a space separated list of packages"""
        pkg_list = packages.split()
        zs.log("Adding packages %s " % pkg_list)
        append = self.package_list().append
        [append(pkg) for pkg in pkg_list]
