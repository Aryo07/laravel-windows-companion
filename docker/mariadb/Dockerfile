FROM docker.io/library/mariadb:10.11

# Copy config file
COPY my.cnf /etc/mysql/conf.d/custom.cnf

# FIX PERMISSIONS for Windows-mounted files
RUN chmod 644 /etc/mysql/conf.d/custom.cnf
