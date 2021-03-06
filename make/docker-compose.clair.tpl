version: '2'
services:
  ui:
    networks:
      harbor-clair:
        aliases:
          - harbor-ui
  jobservice:
    networks:
      - harbor-clair
  registry:
    networks:
      - harbor-clair
  postgres:
    networks:
      harbor-clair:
        aliases:
          - postgres
    container_name: clair-db
    image: vmware/postgresql-photon:__postgresql_version__
    restart: always
    depends_on:
      - log
    env_file:
      ./common/config/clair/postgres_env
    volumes:
      - ./common/config/clair/postgresql-init.d/:/docker-entrypoint-initdb.d:z
      - /data/clair-db:/var/lib/postgresql/data:z
    logging:
      driver: "syslog"
      options:  
        syslog-address: "tcp://127.0.0.1:1514"
        tag: "clair-db"
  clair:
    networks:
      - harbor-clair
    container_name: clair
    image: vmware/clair-photon:__clair_version__
    restart: always
    cpu_quota: 150000
    depends_on:
      - postgres
    volumes:
      - ./common/config/clair/config.yaml:/etc/clair/config.yaml:z
    logging:
      driver: "syslog"
      options:  
        syslog-address: "tcp://127.0.0.1:1514"
        tag: "clair"
    env_file:
      ./common/config/clair/clair_env
networks:
  harbor-clair:
    external: false
