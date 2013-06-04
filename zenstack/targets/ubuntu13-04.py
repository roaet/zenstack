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

from nooptarget import NoopTarget as Base


class Ubuntu1304(Base):

    name = "Ubuntu 13.04"
    description = "Server installation"

    def __init__(self):
        super(Ubuntu1304, self).__init__()

    def initialize(self):
        super(Ubuntu1304, self).initialize()

    def install_target(self):
        super(Ubuntu1304, self).install_target()
        zs.log("Fixing ubuntu 13.04 python issue")

    def post_install(self):
        super(Ubuntu1304, self).post_install()


Target = Ubuntu1304
