========
nodepool
========

Basic filesystem and preperation for running a node as a nodepool worker.


Environment Variables
---------------------

DIB_NODEPOOL_SCRIPT_DIR:
   :Required: No
   :Default: None
   :Description: The local directory that contains nodepool ready scripts.
                 These scripts will be copied into the image and may be
                 executed from nodepool as part of the initialization process.
                 If not provided no scripts will be copied.
   :Example: ``DIB\_NODEPOOL\_SCRIPT\_DIR=/etc/nodepool/scripts``

DIB_NODEPOOL_SCRIPTS:
   :Required: No
   :Default: *
   :Description: The scripts that will be copied from the local directory into
                 the image folder. By default everything is copied. Filenames
                 and patterns can not contain spaces.
   :Example: ``DIB\_NODEPOOL\_SCRIPTS=\"*.sh setup-image.py\"``
