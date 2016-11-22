nodepool_mysql_host: zuul.bonnyci.portbleu.com
nodepool_gearman_servers:
  - host: zuul.bonnyci.portbleu.com
    port: 4730
