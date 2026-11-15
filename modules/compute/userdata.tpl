#!/bin/bash
# Instala Apache + PHP + Git y despliega la Tienda de la nube desde el repositorio de GitHub.
# Es una plantilla: Terraform reemplaza los valores con llaves antes de enviarla a la instancia.

dnf install -y httpd php php-mysqlnd git

# Datos de esta instancia (la tienda los muestra y los guarda en cada pedido)
ID=$(ec2-metadata -i | cut -d' ' -f2)
AZ=$(ec2-metadata -z | cut -d' ' -f2)

# Configuración de la app. Va fuera de /var/www/html para que no se pueda descargar desde el navegador
cat > /var/www/config.php <<EOF
<?php
define('DB_HOST', '${db_endpoint}');
define('DB_NAME', '${db_nombre}');
define('DB_USER', '${db_usuario}');
define('DB_PASS', '${db_password}');
define('INSTANCIA', '$ID');
define('AZ', '$AZ');
EOF
chown root:apache /var/www/config.php
chmod 640 /var/www/config.php

# Descarga la app del repositorio (rama indicada). Reintenta por si la red todavía no responde
for intento in 1 2 3 4 5; do
  rm -rf /opt/tienda
  git clone --depth 1 --branch ${app_branch} ${app_repo_url} /opt/tienda && break
  sleep 10
done

# Copia la app (index.php + img/) a la carpeta web y crea la página del health check.
# Si la descarga falló, no se crea health.html: el load balancer marca la instancia como
# unhealthy y el ASG la reemplaza por otra (que vuelve a intentar)
cp -r /opt/tienda/app/. /var/www/html/ && echo "OK" > /var/www/html/health.html

# PHP en Amazon Linux 2023 corre como servicio aparte (php-fpm) que Apache usa
systemctl enable --now php-fpm
systemctl enable --now httpd