#!/bin/bash
# App de prueba: Apache con una página que muestra qué instancia respondió. Posteriormente se reemplazará por la acción de la app real.

dnf install -y httpd

ID=$(ec2-metadata -i | cut -d' ' -f2)
AZ=$(ec2-metadata -z | cut -d' ' -f2)

echo "<h1>Obligatorio ISC</h1><p>Instancia: $ID</p><p>AZ: $AZ</p>" > /var/www/html/index.html

systemctl enable --now httpd