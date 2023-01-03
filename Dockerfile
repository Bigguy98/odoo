FROM ubuntu:22.04

# env
ENV GIT_BRANCH=16.0

# install python3-pip, postgres-client
RUN apt update \
    && apt install git nodejs npm python3-pip postgresql-client  -y
    
# clone project
RUN git clone https://github.com/Bigguy98/odoo.git -b $GIT_BRANCH \
  && rm -rf odoo/.git

WORKDIR odoo/
RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends tzdata
RUN sed -n -e '/^Depends:/,/^Pre/ s/ python3-\(.*\),/python3-\1/p' debian/control | xargs apt-get install -y
RUN npm install -g rtlcss

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
CMD [ "sh", "entrypoint.sh"]
