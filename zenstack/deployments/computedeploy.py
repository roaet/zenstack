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
from zenstack.basedeploy import BaseDeploy as Base


class ComputeDeploy(Base):

    name = "Compute"
    description = "An openstack compute node deployment."
    deploy_projects = []

    def __init__(self, target):
        super(ComputeDeploy, self).__init__(target)

    def configure(self):
        super(ComputeDeploy, self).configure()
        self.target.repo_add_package("rabbitmq-server screen " +
                                     "vim tmux euca2ools " +
                                     "ipython htop bash-completion")


Target = ComputeDeploy
