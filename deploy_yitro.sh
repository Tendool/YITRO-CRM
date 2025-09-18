#!/bin/bash

# -----------------------------
# Variables - Change if needed
# -----------------------------
DOMAIN="crm.yitroglobal.com"
EC2_USER_HOME="/home/ec2-user"
APP_PATH="$EC2_USER_HOME/Uploaded_YITRO-NEW"
BACKEND_FILE="dist/server/node-build.mjs"
BACKEND_PORT=3000

# -----------------------------
# 1️⃣ Install PM2 and Certbot
# -----------------------------
echo "Installing PM2 and Certbot..."
sudo npm install -g pm2
sudo dnf install -y certbot python3-certbot-nginx

# -----------------------------
# 2️⃣ Configure Nginx
# -----------------------------
echo "Configuring Nginx..."
NGINX_CONF="/etc/nginx/nginx.conf"
sudo cp $NGINX_CONF ${NGINX_CONF}.backup

sudo tee $NGINX_CONF > /dev/null <<EOL
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    keepalive_timeout 65;
    types_hash_max_size 4096;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    include /etc/nginx/conf.d/*.conf;

    server {
        listen 80;
        server_name $DOMAIN;

        root $APP_PATH/dist/spa;
        index index.html;

        location / {
            try_files \$uri /index.html;
        }

        location /api/ {
            proxy_pass http://localhost:$BACKEND_PORT;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
            proxy_cache_bypass \$http_upgrade;
        }
    }
}
EOL

# Test and reload Nginx
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

# -----------------------------
# 3️⃣ Start Backend with PM2
# -----------------------------
echo "Starting backend with PM2..."
cd $APP_PATH
pm2 start $BACKEND_FILE --name yitro-backend
pm2 save
pm2 startup -u ec2-user --hp $EC2_USER_HOME

# -----------------------------
# 4️⃣ Setup HTTPS with Certbot
# -----------------------------
echo "Setting up HTTPS with Certbot..."
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN

echo "✅ Deployment complete! Your app is live at https://$DOMAIN"
