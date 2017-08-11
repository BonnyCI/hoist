
import os

from checks import AgentCheck


class AnsibleRunnerCheck(AgentCheck):

    SERVICE_CHECK_NAME = 'ansible_runner.failing_environments'

    def check(self, instance):
        if 'failing_dir' not in instance:
            self.log.info("Skipping instance, no failing_dir found")
            return

        failing_dir = instance['failing_dir']

        if os.path.isdir(failing_dir):
            failing_files = os.listdir(failing_dir)
            if failing_files:
                msg = 'ansible-runner envs failing: %s' % \
                       ', '.join(failing_files)
                self.service_check(self.SERVICE_CHECK_NAME,
                                   AgentCheck.CRITICAL,
                                   message=msg)
        else:
            self.service_check(self.SERVICE_CHECK_NAME,
                               AgentCheck.OK,
                               message="No failing ansible-runner envs found")
