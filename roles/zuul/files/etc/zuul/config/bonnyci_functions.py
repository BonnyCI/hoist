# No one is proud of this file. Everything here should have a configuration
# option and this should be removable.

def set_log_path(item, job, params):
    # the default log directory doesn't really make sense for github, there's a
    # lot more work to do here but for now using ChangeItem.enqueue_time at
    # least lets us link builds.
    params['BASE_LOG_PATH'] = '%s/%s/%s/%s' % (params['ZUUL_PIPELINE'],
                                               params['ZUUL_PROJECT'],
                                               params['ZUUL_CHANGE'],
                                               item.enqueue_time)

    params['LOG_PATH'] = '%s/%s' % (params['BASE_LOG_PATH'], job.name)


FUNCS = [
    set_log_path,
]


def set_node_options(item, job, params):
    for f in FUNCS:
        f(item, job, params)
