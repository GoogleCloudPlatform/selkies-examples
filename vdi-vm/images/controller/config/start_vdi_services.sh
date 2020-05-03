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

SCRIPT_DIR=$(dirname $(readlink -f $0 2>/dev/null) 2>/dev/null || echo "${PWD}/$(dirname $0)")

export TERM=xterm

echo "INFO: starting gotty"
${SCRIPT_DIR}/gotty -p 9000 -w bash >${HOME}/.gotty.log 2>&1 &

echo "INFO: starting X session"
[[ -f /usr/local/vdi/startx.sh ]] && bash /usr/local/vdi/startx.sh

echo "INFO: starting WebRTC"
[[ -f /usr/local/vdi/start_webrtc.sh ]] && bash /usr/local/vdi/start_webrtc.sh
