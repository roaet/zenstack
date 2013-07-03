#!/usr/bin/env python
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
import zenstack.targets as targets
import zenstack.deployments as deploys

class Zenstack(object):
    target = None
    deploy = None

    def __init__(self):
        pass

    def run(self):
        self.target.install()
        self.target.post_install()

    def configure(self):
        zs.message("Starting zenstack")
        Target = targets.select_target()
        self.target = Target()
        if not self.target.check_can_run():
            print "Shouldn't run"

        Deploy = deploys.select_deploy()
        self.deploy = Deploy(self.target)
        self.deploy.configure()


if __name__ == "__main__":
    zen = Zenstack()
    zen.configure()
    zen.run()
