#!/bin/bash

# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[[ -n "$(pgrep -f $(command -v startx))" ]] && echo "INFO: startx is already running" && exit 0

sudo touch /var/lock/console.lock
sudo mkdir -p /var/run/console
sudo touch /var/run/console/${USER}
nohup startx >${HOME}/.startx.log 2>&1 &