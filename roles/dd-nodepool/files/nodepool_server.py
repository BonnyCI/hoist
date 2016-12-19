#!/usr/bin/env python

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import time
import requests

from checks import AgentCheck

class NodepoolCheck(AgentCheck):

    def check(self, instance):
        if 'status_url' not in instance:
            self.log.info("Skipping instance, no url found.")
            return

        status_url = instance['status_url']
        default_timeout = self.init_config.get('default_timeout', 5)
        timeout = float(instance.get('timeout', default_timeout))
        start_time = time.time()
        try:
            r = requests.get(ststus_url, timeout=timeout)
            end_time = time.time()
        except requests.exceptions.Timeout as e:
            self.timeout_event(status_url, timeout, aggregation_key)
            return

        if r.status_code != 200:
            self.status_code_event(ststus_url, r, aggregation_key)

        timing = end_time - start_time
        self.gauge('nodepool_server.status_url.reponse_time', timing, tags=['http_check'])

    def timeout_event(self, status_url, timeout, aggregation_key):
        self.event({
            'timestamp': int(time.time()),
            'event_type': 'http_check',
            'msg_title': 'URL timeout',
            'msg_text': '%s timed out after %s seconds.' % (status_url, timeout),
            'aggregation_key': aggregation_key
        })

    def status_code_event(self, status_url, r, aggregation_key):
        self.event({
            'timestamp': int(time.time()),
            'event_type': 'http_check',
            'msg_title': 'Invalid reponse code for %s' % url,
            'msg_text': '%s returned a status of %s' % (status_url, r.status_code),
            'aggregation_key': aggregation_key
        })
