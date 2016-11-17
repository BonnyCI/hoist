import requests
import time

from checks import AgentCheck


class ZuulServerCheck(AgentCheck):

    SERVICE_CHECK_NAME = 'zuul_server.got_status'

    def check(self, instance):
        if 'status_url' not in instance:
            self.log.info("Skipping instance, no url found")
            return

        status_url = instance['status_url']
        default_timeout = self.init_config.get('default_timeout', 5)
        timeout = float(instance.get('timeout', default_timeout))
        service_check_tags = ['url:%s' % status_url]

        try:
            self.get_zuul_metrics(status_url, timeout, service_check_tags)
        except Exception as e:
            self.service_check(self.SERVICE_CHECK_NAME,
                               AgentCheck.CRITICAL,
                               message=str(e),
                               tags=service_check_tags)

    def get_zuul_metrics(self, status_url, timeout, service_check_tags):
        r = requests.get(status_url, timeout=timeout)

        if r.status_code != 200:
            self.service_check(
                self.SERVICE_CHECK_NAME,
                AgentCheck.UNKNOWN,
                message='Unexpected status code: %d' % r.status_code,
                tags=service_check_tags)

            return

        data = r.json()

        self.gauge('zuul_server.pipelines', len(data.get('pipelines', [])))

        self.gauge('zuul_server.trigger_event_queue_length',
                   data.get('trigger_event_queue', {}).get('length', 0))

        self.gauge('zuul_server.result_event_queue_length',
                   data.get('result_event_queue', {}).get('length', 0))

        self.service_check(self.SERVICE_CHECK_NAME,
                           AgentCheck.OK,
                           message='Received status from %s' % status_url,
                           tags=service_check_tags)
