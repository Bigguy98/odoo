To build image:

> docker build -t myodoo:1.0.0 .

Run image locally: (with postgres already install on your machine)

> docker run --env DB_USERNAME=odoo  --env DB_PASSWORD=odoo --env DB_HOST=host.docker.internal --env DB_NAME=mydb -p 8069:8069 myodoo:1.0.0

Access: http://localhost:8069 to view odoo app