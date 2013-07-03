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
import os

import zenstack.common as zs
from zenstack.basetarget import BaseTarget as Base


class Ubuntu1304(Base):

    name = "Ubuntu 13.04"
    description = "Server installation"
    sane_package_requirements = ["git-core", "git", "build-essential",
                                 "python", "wget", "curl", "parted",
                                 "python-pip", "unzip", "swig", "sudo",
                                 "python-dev", "libxml2", "libxml2-dev",
                                 "libxslt1.1", "libxslt-dev", "python-mysqldb",
                                 "libmysqlclient-dev", "build-dep",
                                 "python-psycopg2"]

    def initialize(self):
        super(Ubuntu1304, self).initialize()
        self.repo_add_package(" ".join(self.sane_package_requirements))

    def check_can_run(self):
        if super(Ubuntu1304, self).check_can_run():
            return False
        if os.getuid() == 0:
            return True
        return False


    def make_environment_sane(self):
        super(Ubuntu1304, self).make_environment_sane()
        for pkg in self.package_list():
            self.repo_install(pkg)
        self._fix_import_error()
        self.pip_install("virtualenv")

    def repo_install(self, package):
        super(Ubuntu1304, self).repo_install(package)
        zs.perform("apt-get install -y %s" % package)

    def pip_install(self, package):
        super(Ubuntu1304, self).pip_install(package)
        zs.perform("pip install %s" % package)

    def _fix_import_error(self):
        zs.log("FIX:ImportError: No module named _sysconfigdata_nd")
        python_path = "/usr/lib/python2.7/"
        plat = "plat-x86_64-linux-gnu/"
        py = "_sysconfigdata_nd.py"
        orig = "%s%s%s" % (python_path, plat, py)
        link = "%s%s" % (python_path, py)
        zs.perform("ln -s %s %s" % (orig, link)) 


Target = Ubuntu1304
