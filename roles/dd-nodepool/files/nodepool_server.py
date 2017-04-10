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

    SERVICE_CHECK_NAME = 'nodepool_server.got_status'
    IMAGES_CHECK_NAME = 'nodepool_server.got_images'

    def check(self, instance):
        default_timeout = self.init_config.get('default_timeout', 5)
        timeout = float(instance.get('timeout', default_timeout))

        status_url = instance.get('status_url')
        images_url = instance.get('image_url')

        service_check_tags = ['url:%s' % status_url]
        images_check_tags = ['url:%s' % images_url]

        if status_url:
            try:
                self.get_nodepool_status(status_url, timeout,
                                         service_check_tags)
            except Exception as e:
                self.service_check(self.SERVICE_CHECK_NAME,
                                   AgentCheck.CRITICAL,
                                   message=str(e),
                                   tags=service_check_tags)
        else:
            self.log.info("Skipping instance, no status url found.")

        if images_url:
            try:
                self.get_nodepool_images(images_url, timeout,
                                         images_check_tags)
            except Exception as e:
                self.service_check(self.IMAGES_CHECK_NAME,
                                   AgentCheck.CRITICAL,
                                   message=str(e),
                                   tags=images_check_tags)
        else:
            self.log.info("Skipping instance, no images url found.")

    def get_nodepool_status(self, status_url, timeout, service_check_tags):
        r = requests.get(status_url, timeout=timeout)

        if r.status_code != 200:
            self.service_check(
                self.SERVICE_CHECK_NAME,
                AgentCheck.UNKNOWN,
                message='Unexpected status code: %d' % r.status_code,
                tags=service_check_tags)

            return

        self.service_check(self.SERVICE_CHECK_NAME,
                           AgentCheck.OK,
                           message='Received status from %s' % status_url,
                           tags=service_check_tags)

    def get_nodepool_images(self, images_url, timeout, images_check_tags):
        r = requests.get(images_url, timeout=timeout)
        currentTime = int(time.time())

        for image in r.json():
            self.gauge('nodepool.image.%s.age' % image['name'], currentTime - image['age'])
