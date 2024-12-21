FROM mysql:latest AS cloned-moodle

FROM cloned-moodle AS restored-moodle

COPY ./moodle_dump.sql /docker-entrypoint-initdb.d/moodle_dump.sql