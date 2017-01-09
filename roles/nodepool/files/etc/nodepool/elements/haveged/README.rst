=======
haveged
=======

Install and enable the haveged service.

In virtual machines we often have a problem with randomness particularly at
early stages. This will start and enable the haveged service which adds
additional entropy to the kernel. This should not be installed on production
systems however is safe for things like a CI system where the results aren't
super valuable.
