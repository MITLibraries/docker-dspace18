
Containerized DSpace 1.8
========================

This will provide a DSpace 1.8 instance for local development that is connected to a Postgres container. To get this up and running, first create the Postgres container:

.. code-block:: bash

    $ docker run --name db -d postgres

The first time you run the DSpace container you will need to initialize the Postgres database and create a DSpace admin account. Pass the admin information as environment variables. Make sure you link this to the Postgres container you created:

.. code-block:: bash

    $ docker run -P --link db:pg -e ADMIN_EMAIL='admin@example.com' -e ADMIN_FIRST_NAME=John \
        -e ADMIN_LAST_NAME=Smith -e ADMIN_PASSWORD=password -d mitlibraries/dspace initialize

The previous step will leave you with a DSpace instance running on container port 8080. Use ``docker ps`` to see what port this is mapped to on your host machine. If you wish to later create another container connecting to the same Postgres instance you just need to run:

.. code-block:: bash

    $ docker run -P --link db:pg -d mitlibraries/dspace
