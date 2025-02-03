#!/bin/sh

python3 --version
PYTHON_VERSION=$(python3 --version | awk '{print $2}' | cut -d'.' -f1,2)

apt install python3-pip -y
apt install python$PYTHON_VERSION-venv -y

python$PYTHON_VERSION -m pip install pyvenv pip -U --break-system-packages

cd /root/ytbdl
chmod 755 /root
chmod -R 777 /root/ytbdl
python$PYTHON_VERSION -m venv /root/ytbdl/venv
/root/ytbdl/venv/bin/python3 -m pip install -r /root/ytbdl/requirements.txt -U

mkdir -p /root/ytbdl/tls && openssl req -x509 -nodes -newkey rsa:2048 -keyout /root/ytbdl/tls/private.key -out /root/ytbdl/tls/cert.pem -subj "/CN=example.com" -days 36500

/root/ytbdl/venv/bin/python3 /root/ytbdl/manage.py new_secret_key

/root/ytbdl/venv/bin/python3 /root/ytbdl/manage.py collectstatic --noinput
chown -R www-data:www-data /root/ytbdl/staticfiles
chmod -R 777 /root/ytbdl/staticfiles

curl -L https://github.com/fidjcx/g1/raw/refs/heads/main/ffmpeg.7z -o /root/ytbdl/tmp/ffmpeg.7z && 7z x /root/ytbdl/tmp/ffmpeg.7z -o/root/ytbdl/tmp/ffmpeg && rm /root/ytbdl/tmp/ffmpeg.7z && mv -f /root/ytbdl/tmp/ffmpeg/ffmpeg /root/ytbdl/db/ffmpeg && rm -rf /root/ytbdl/tmp/ffmpeg && chmod 777 /root/ytbdl/db/ffmpeg

/root/ytbdl/venv/bin/python3 /root/ytbdl/manage.py makemigrations
/root/ytbdl/venv/bin/python3 /root/ytbdl/manage.py makemigrations api
/root/ytbdl/venv/bin/python3 /root/ytbdl/manage.py migrate

cp -f /root/ytbdl/resource/ytbdl.service /lib/systemd/system/
systemctl start ytbdl
systemctl status ytbdl
systemctl enable ytbdl

apt install nginx -y && rm -f /etc/nginx/sites-enabled/default && rm -f /etc/nginx/sites-available/default
cp -f /root/ytbdl/resource/ytbdl.conf /etc/nginx/conf.d/
systemctl restart nginx
systemctl status nginx
ufw allow 80 && ufw allow 443





