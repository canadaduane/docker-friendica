docker-friendica
================

Try Friendica in Docker

Quickstart
----------

    $ docker build -t friendica github.com/canadaduane/docker-friendica.git
    $ docker run -p 80:80 -e ADMIN_EMAIL=test@example.com friendica

Change `test@example.com` as you want.

Open `http://localhost/register` and register using same email as `ADMIN_EMAIL`.

