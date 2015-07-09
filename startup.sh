#!/bin/bash
set -e

sed -i "s,^db.url.*,db.url = jdbc:postgresql://${PG_PORT_5432_TCP_ADDR}:${PG_PORT_5432_TCP_PORT}/dspace," \
    ${BUILD_DIR}/config/dspace.cfg
sed -i "s,^dspace.baseUrl.*,dspace.baseUrl = ${BASE_URL:-http://localhost:8080}," \
    ${BUILD_DIR}/config/dspace.cfg
cd ${BUILD_DIR} && ant update_configs

if [ "$1" = 'initialize' ]; then
    # Prep Postgres
    PG_ARGS=(-h ${PG_PORT_5432_TCP_ADDR} -p ${PG_PORT_5432_TCP_PORT} -U postgres)
    psql ${PG_ARGS[@]} -c "CREATE USER dspace WITH LOGIN PASSWORD 'dspace';"
    psql ${PG_ARGS[@]} -c "CREATE DATABASE dspace;"
    psql ${PG_ARGS[@]} -c "GRANT ALL PRIVILEGES ON DATABASE dspace TO dspace;"

    cd ${BUILD_DIR} && ant test_database && ant setup_database && ant load_registries
    ${INSTALL_DIR}/bin/dspace create-administrator -e ${ADMIN_EMAIL} \
        -f ${ADMIN_FIRST_NAME} -l ${ADMIN_LAST_NAME} -p ${ADMIN_PASSWORD} \
        -c ${ADMIN_LANG:-en}

    exec catalina.sh run
fi

exec "$@"
