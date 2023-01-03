
## I. Introduce

Open source ERP (Enterprise resource planning) and CRM (Customer relationship management) solution, origin at: https://www.odoo.com/

Here're some basic views of this solution:

1. Login page

![image](https://user-images.githubusercontent.com/27953500/210332367-67535f02-1975-4586-b6c3-ab3dba14bc71.png)

You can login with: admin/admin

2. Main dashboard

![image](https://user-images.githubusercontent.com/27953500/210332475-e6c41747-1ce3-4115-97e2-0b6790d61fc8.png)

3. Profile management

![image](https://user-images.githubusercontent.com/27953500/210332527-47308481-42d3-4190-838e-7f9897622801.png)




## II. How to run

To build image:

> docker build -t myodoo:1.0.0 .

**1. Run image locally**

Prerequites: postgres already install on your host machine, with account (username: odoo, password: odoo) and pre existing database: mydb

> docker run --env DB_USERNAME=odoo  --env DB_PASSWORD=odoo --env DB_HOST=host.docker.internal --env DB_NAME=mydb -p 8069:8069 myodoo:1.0.0

Access: http://localhost:8069 to view odoo app

**2. Run with docker-compose**

Create a docker-compose file

```
version: '3.1'
services:
  web:
    image: myodoo:1.0.0
    depends_on:
      - db
    ports:
      - "8069:8069"
    volumes:
      - odoo-web-data:/var/lib/odoo
      - ./config:/etc/odoo
      - ./addons:/mnt/extra-addons
    environment:
      - DB_USERNAME=odoo
      - DB_PASSWORD=odoo
      - DB_HOST=db
      - DB_NAME=postgres
  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_PASSWORD=odoo
      - POSTGRES_USER=odoo
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - odoo-db-data:/var/lib/postgresql/data/pgdata
volumes:
  odoo-web-data:
  odoo-db-data:
```

Run with command

> docker-compose up -d

## III. Config CI/CD with Git Action

We do the following steps on CI/CD pipeline:

- Build docker image and push image to dockerhub
- Checkout another repo (GitOps repo, include manifest files ro run app on Kubernetes), update image tag.

This GitOps repo is a source for ArgoCD server. ArgoCD will automatically sync app on Kubernetes with change we made.

Workflow file:
```
name: ci

on:
  push:
    branches:
      - "16.0"
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      -
        name: Checkout
        uses: actions/checkout@v3
        
      -
        name: Get git hash as version
        run: |
            echo "new_version=$(git rev-parse --short HEAD)" >> $GITHUB_ENV
      -
        name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_HUB_USERNAME }}
          password: ${{ secrets.DOCKER_HUB_ACCESS_TOKEN }}
      -
        name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      -
        name: Build and push
        uses: docker/build-push-action@v3
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: ${{ secrets.DOCKER_HUB_USERNAME }}/odoo-ci:${{ env.new_version }}
      - 
        name: Checkout to gitOps repo
        uses: actions/checkout@v3
        with:
          repository: Bigguy98/odoo-k8s
          token: ${{ secrets.ODOO_K8S_TOKEN}}
      - 
        name: Update version
        run: |
          echo "$new_version"
          current_version=$(cat )
          sed -i "s/$current_version/$new_version/" odoo.yaml
          git config --global user.email "vuthanhtunghayquen98@example.com"
          git config --global user.name "Bugs Maker"
          git add .
          git commit -m "update odoo app version"
          git push
```




