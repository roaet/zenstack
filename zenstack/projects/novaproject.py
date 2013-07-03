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
from noopproject import NoopProject as Base


class NovaProject(Base):

    name = "Nova"
    description = "A basic nova installation"

    def __init__(self, target):
        super(NovaProject, self).__init__(target)

    def initialize(self):
        super(NovaProject, self).initialize()

    def run_project(self):
        super(NovaProject, self).run_project()

    def clean_project(self):
        super(NovaProject, self).clean_project()
