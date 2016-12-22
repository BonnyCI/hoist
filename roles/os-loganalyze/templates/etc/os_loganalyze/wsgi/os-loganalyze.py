#!{{ os_loganalyze_venv_dir }}/bin/python

# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

activate_this_file = "{{ os_loganalyze_venv_dir }}/bin/activate_this.py"
execfile(activate_this_file, dict(__file__=activate_this_file))

import threading

from os_loganalyze import wsgi

ROOT_PATH = '{{ os_loganalyze_root_dir }}'
WSGI_CONFIG = '/etc/os_loganalyze/wsgi.conf'


def create_application():

    def application(environ, start_response):
        return wsgi.application(environ,
                                start_response,
                                root_path=ROOT_PATH,
                                wsgi_config=WSGI_CONFIG)

    return application


application = create_application()
