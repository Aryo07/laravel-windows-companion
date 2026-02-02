FROM docker.io/library/mysql:8.0

# Copy config file
COPY my.cnf /etc/mysql/conf.d/custom.cnf

# FIX PERMISSIONS for Windows-mounted files
# 644 = Read/Write for Owner, Read Only for others (Safe)
RUN chmod 644 /etc/mysql/conf.d/custom.cnf
