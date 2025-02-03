systemctl stop ytbdl
systemctl disable ytbdl
rm -f /lib/systemd/system/ytbdl.service
systemctl daemon-reload
rm -rf /root/ytbdl
rm -f /etc/nginx/conf.d/ytbdl.conf
nginx -s reload
