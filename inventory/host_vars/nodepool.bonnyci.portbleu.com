gearman_bind_address: 0.0.0.0

nodepool_mysql_host: zuul.bonncyi.portbleu.com
nodepool_gearman_servers:
  - host: zuul.bonnyci.portbleu.com
    port: 4730
