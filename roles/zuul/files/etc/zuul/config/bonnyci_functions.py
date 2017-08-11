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


def set_offline_node_after_use(item, job, params):
    # This ensures nodes are taken offline and not re-used after a
    # test has run on them.
    params['OFFLINE_NODE_WHEN_COMPLETE'] = 1


FUNCS = [
    set_log_path,
    set_offline_node_after_use,
]


def set_node_options(item, job, params):
    for f in FUNCS:
        f(item, job, params)
