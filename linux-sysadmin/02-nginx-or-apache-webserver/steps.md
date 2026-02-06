# Lab 02: NGINX or Apache Web Server - Step-by-Step Guide

## Choose Your Path

This lab provides instructions for both NGINX and Apache. Choose one to complete the lab.

---

# Option A: NGINX Setup

## Step 1: Install NGINX

### 1.1 Update System

```bash
sudo apt update
```

### 1.2 Install NGINX

```bash
sudo apt install nginx -y
```

### 1.3 Start and Enable NGINX

```bash
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx
```

### 1.4 Configure Firewall

```bash
sudo ufw allow 'Nginx Full'
sudo ufw status
```

## Step 2: Verify Installation

### 2.1 Check NGINX Version

```bash
nginx -v
```

### 2.2 Test Default Page

```bash
curl localhost
# Or open browser to http://your-server-ip
```

## Step 3: Create Virtual Hosts

### 3.1 Create Directory Structure

```bash
sudo mkdir -p /var/www/site1.example.com/html
sudo mkdir -p /var/www/site2.example.com/html
```

### 3.2 Set Permissions

```bash
sudo chown -R $USER:$USER /var/www/site1.example.com/html
sudo chown -R $USER:$USER /var/www/site2.example.com/html
sudo chmod -R 755 /var/www
```

### 3.3 Create Sample Pages

```bash
cat > /var/www/site1.example.com/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Site 1</title>
</head>
<body>
    <h1>Welcome to Site 1!</h1>
    <p>This is the first virtual host.</p>
</body>
</html>
EOF

cat > /var/www/site2.example.com/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Site 2</title>
</head>
<body>
    <h1>Welcome to Site 2!</h1>
    <p>This is the second virtual host.</p>
</body>
</html>
EOF
```

### 3.4 Create Server Blocks

```bash
sudo nano /etc/nginx/sites-available/site1.example.com
```

Add:

```nginx
server {
    listen 80;
    listen [::]:80;

    root /var/www/site1.example.com/html;
    index index.html index.htm;

    server_name site1.example.com www.site1.example.com;

    location / {
        try_files $uri $uri/ =404;
    }

    access_log /var/log/nginx/site1.access.log;
    error_log /var/log/nginx/site1.error.log;
}
```

```bash
sudo nano /etc/nginx/sites-available/site2.example.com
```

Add:

```nginx
server {
    listen 80;
    listen [::]:80;

    root /var/www/site2.example.com/html;
    index index.html index.htm;

    server_name site2.example.com www.site2.example.com;

    location / {
        try_files $uri $uri/ =404;
    }

    access_log /var/log/nginx/site2.access.log;
    error_log /var/log/nginx/site2.error.log;
}
```

### 3.5 Enable Sites

```bash
sudo ln -s /etc/nginx/sites-available/site1.example.com /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/site2.example.com /etc/nginx/sites-enabled/
```

### 3.6 Test Configuration

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## Step 4: Configure SSL/TLS

### 4.1 Install Certbot

```bash
sudo apt install certbot python3-certbot-nginx -y
```

### 4.2 Obtain SSL Certificate (if you have a domain)

```bash
sudo certbot --nginx -d site1.example.com -d www.site1.example.com
sudo certbot --nginx -d site2.example.com -d www.site2.example.com
```

### 4.3 Create Self-Signed Certificate (for testing)

```bash
sudo mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx-selfsigned.key \
    -out /etc/nginx/ssl/nginx-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
```

### 4.4 Configure SSL in Server Block

```bash
sudo nano /etc/nginx/sites-available/site1.example.com
```

Add SSL configuration:

```nginx
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    root /var/www/site1.example.com/html;
    index index.html;

    server_name site1.example.com www.site1.example.com;

    location / {
        try_files $uri $uri/ =404;
    }
}

server {
    listen 80;
    listen [::]:80;
    server_name site1.example.com www.site1.example.com;
    return 301 https://$server_name$request_uri;
}
```

### 4.5 Test and Reload

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## Step 5: Security Hardening

### 5.1 Add Security 

```bash
sudo nano /etc/nginx/conf.d/security-headers.conf
```

Add:

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
```

### 5.2 Hide NGINX Version

```bash
sudo nano /etc/nginx/nginx.conf
```

Add in http block:

```nginx
server_tokens off;
```

### 5.3 Configure Rate Limiting

```bash
sudo nano /etc/nginx/nginx.conf
```

Add in http block:

```nginx
limit_req_zone $binary_remote_addr zone=one:10m rate=10r/s;
limit_req_status 429;
```

In server block:

```nginx
limit_req zone=one burst=20 nodelay;
```

## Step 6: Performance Optimization

### 6.1 Enable Gzip Compression

```bash
sudo nano /etc/nginx/nginx.conf
```

Ensure these are enabled:

```nginx
gzip on;
gzip_vary on;
gzip_proxied any;
gzip_comp_level 6;
gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss application/rss+xml font/truetype font/opentype application/vnd.ms-fontobject image/svg+xml;
```

### 6.2 Configure Caching

```bash
sudo nano /etc/nginx/sites-available/site1.example.com
```

Add in location block:

```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### 6.3 Adjust Worker Processes

```bash
sudo nano /etc/nginx/nginx.conf
```

Set:

```nginx
worker_processes auto;
worker_connections 1024;
```

## Step 7: Monitoring and Logging

### 7.1 Enable Access Logs

```bash
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

### 7.2 Configure Log Format

```bash
sudo nano /etc/nginx/nginx.conf
```

Add custom log format:

```nginx
log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                '$status $body_bytes_sent "$http_referer" '
                '"$http_user_agent" "$http_x_forwarded_for"';
```

### 7.3 Configure Logrotate

```bash
sudo nano /etc/logrotate.d/nginx
```

Verify configuration includes:

```/var/log/nginx/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    sharedscripts
    postrotate
        [ -f /var/run/nginx.pid ] && kill -USR1 `cat /var/run/nginx.pid`
    endscript
}
```

---

# Option B: Apache Setup

## Step 1: Install Apache

### 1.1 Update System

```bash
sudo apt update
```

### 1.2 Install Apache

```bash
sudo apt install apache2 -y
```

### 1.3 Start and Enable Apache

```bash
sudo systemctl start apache2
sudo systemctl enable apache2
sudo systemctl status apache2
```

### 1.4 Configure Firewall

```bash
sudo ufw allow 'Apache Full'
sudo ufw status
```

## Step 2: Verify Installation

### 2.1 Check Apache Version

```bash
apache2 -v
```

### 2.2 Test Default Page

```bash
curl localhost
```

## Step 3: Create Virtual Hosts

### 3.1 Create Directory Structure

```bash
sudo mkdir -p /var/www/site1.example.com/html
sudo mkdir -p /var/www/site2.example.com/html
```

### 3.2 Set Permissions

```bash
sudo chown -R $USER:$USER /var/www/site1.example.com/html
sudo chown -R $USER:$USER /var/www/site2.example.com/html
sudo chmod -R 755 /var/www
```

### 3.3 Create Sample Pages

```bash
cat > /var/www/site1.example.com/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Site 1 - Apache</title>
</head>
<body>
    <h1>Welcome to Site 1 on Apache!</h1>
</body>
</html>
EOF
```

### 3.4 Create Virtual Host Configuration

```bash
sudo nano /etc/apache2/sites-available/site1.example.com.conf
```

Add:

```apache
<VirtualHost *:80>
    ServerAdmin admin@site1.example.com
    ServerName site1.example.com
    ServerAlias www.site1.example.com
    DocumentRoot /var/www/site1.example.com/html
    
    ErrorLog ${APACHE_LOG_DIR}/site1-error.log
    CustomLog ${APACHE_LOG_DIR}/site1-access.log combined
    
    <Directory /var/www/site1.example.com/html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

### 3.5 Enable Site and Modules

```bash
sudo a2ensite site1.example.com.conf
sudo a2enmod rewrite
sudo a2enmod ssl
sudo apache2ctl configtest
sudo systemctl reload apache2
```

## Step 4: Configure SSL/TLS

### 4.1 Install Certbot

```bash
sudo apt install certbot python3-certbot-apache -y
```

### 4.2 Create Self-Signed Certificate

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/apache-selfsigned.key \
    -out /etc/ssl/certs/apache-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
```

### 4.3 Configure SSL Virtual Host

```bash
sudo nano /etc/apache2/sites-available/site1.example.com-ssl.conf
```

Add:

```apache
<VirtualHost *:443>
    ServerAdmin admin@site1.example.com
    ServerName site1.example.com
    DocumentRoot /var/www/site1.example.com/html
    
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    
    ErrorLog ${APACHE_LOG_DIR}/site1-ssl-error.log
    CustomLog ${APACHE_LOG_DIR}/site1-ssl-access.log combined
</VirtualHost>
```

### 4.4 Enable SSL Site

```bash
sudo a2ensite site1.example.com-ssl.conf
sudo systemctl reload apache2
```

## Step 5: Security Hardening

### 5.1 Enable Security Modules

```bash
sudo a2enmod headers
sudo a2enmod security2
```

### 5.2 Configure Security Headers

```bash
sudo nano /etc/apache2/conf-available/security.conf
```

Add:

```apache
Header always set X-Frame-Options "SAMEORIGIN"
Header always set X-Content-Type-Options "nosniff"
Header always set X-XSS-Protection "1; mode=block"
ServerTokens Prod
ServerSignature Off
```

### 5.3 Enable Configuration

```bash
sudo a2enconf security
sudo systemctl reload apache2
```

## Validation

### Test HTTP and HTTPS Access

```bash
curl -I http://localhost
curl -Ik https://localhost
```

### Check Logs

```bash
sudo tail -f /var/log/nginx/access.log  # NGINX
sudo tail -f /var/log/apache2/access.log  # Apache
```

## Troubleshooting

### Port Already in Use

```bash
sudo lsof -i :80
sudo lsof -i :443
```

### Configuration Test Failed

```bash
sudo nginx -t  # NGINX
sudo apache2ctl configtest  # Apache
```

## Validation Checklist

- [ ] Web server installed and running
- [ ] Multiple virtual hosts configured
- [ ] SSL/TLS certificates configured
- [ ] Security headers implemented
- [ ] Performance optimization applied
- [ ] Logging configured
- [ ] Firewall rules applied
- [ ] Documentation and screenshots captured

## Next Steps

Proceed to `cleanup.md` to remove lab resources when complete.
