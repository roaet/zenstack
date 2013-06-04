#!/usr/bin/python
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
"""
Created June 3, 2013

@author: Justin Hammond, Rackspace Hosting

Zenstack performs its duties in steps:
1. Gather configuration information
2. Perform tasks of all projects
    - The failure of a project should not cancel the deployment
    - The success of a project should be stored
    - Rerunning a project that has succeeded should noted
3. Integrate projects

Zenstack has a hierachy of constructs that organize a complete
deployment of zenstack.
- A target is the OS host that will have zenstack put on it.
    Ex: Ubuntu 13.04
- A deployment is a type of zenstack that will be put on the target.
    Ex: Compute or XCP Hypervisor
- A configuration is the particular way a deployment will be set up.
    Ex: With Quantum/Melange or with Quark
- A project is a single service that will be deployed with said config.
    Ex: Quantum, Nova, or Keystone
- A task is a step that will be taken during the deployment of a project.
    Ex: Installing dependancies, installing plugins (for quantum)

A project should not be dependant on any other project so they may be
installed simultaneously. If a project has dependancies it should be
set a task of a project.

After running each project the integration steps will discover which
projects were configured to be run and will then attempt to configure
them so that they may communicate with each other, if necessary.
"""
import zenstack.common as zs


def main():
    zs.message("Starting zenstack")
    zs.error("This is an error")
    zs.log("This is a random log")


if __name__ == "__main__":
    main()
