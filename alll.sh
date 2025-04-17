#!/bin/bash

echo_info() {
  echo -e "\033[1;32m[INFO]\033[0m $1"
}
echo_error() {
  echo -e "\033[1;31m[ERROR]\033[0m $1"
  exit 1
}

apt-get update; apt-get install curl socat git nload speedtest-cli -y


if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sh || echo_error "Docker installation failed."
else
  echo_info "Docker is already installed."
fi

rm -r Marzban-node

git clone https://github.com/Gozargah/Marzban-node

rm -r /var/lib/marzban-node

mkdir /var/lib/marzban-node

rm ~/Marzban-node/docker-compose.yml

cat <<EOL > ~/Marzban-node/docker-compose.yml
services:
  marzban-node:
    image: gozargah/marzban-node:latest
    restart: always
    network_mode: host
    environment:
      SSL_CERT_FILE: "/var/lib/marzban-node/ssl_cert.pem"
      SSL_KEY_FILE: "/var/lib/marzban-node/ssl_key.pem"
      SSL_CLIENT_CERT_FILE: "/var/lib/marzban-node/ssl_client_cert.pem"
      SERVICE_PROTOCOL: "rest"
    volumes:
      - /var/lib/marzban-node:/var/lib/marzban-node
EOL
curl -sSL https://raw.githubusercontent.com/Tozuck/Node_monitoring/main/node_monitor.sh | bash
rm /var/lib/marzban-node/ssl_client_cert.pem

cat <<EOL > /var/lib/marzban-node/ssl_client_cert.pem
-----BEGIN CERTIFICATE-----
MIIEnDCCAoQCAQAwDQYJKoZIhvcNAQENBQAwEzERMA8GA1UEAwwIR296YXJnYWgw
IBcNMjUwNDE3MTgwNjIzWhgPMjEyNTAzMjQxODA2MjNaMBMxETAPBgNVBAMMCEdv
emFyZ2FoMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqprsNUdiCgvR
+pNG2HU0HS7SoJCoaKvgQCdnKGoUBe4jYMyrDZKdp95QSYt52liyE1tEH66wNoJg
dOczPBlSjEyTPoSOpWpMOuuH8h/GWBjqv4e2lSruQB3agPXTg3vi1ebSjR6gm7V/
jc+8x7e4+A3OnAkbNz+hrY/biLsMufgMKjHpoYBpn92JZv6GCF3HdtNOOkW6SdmN
HWY2YO0gnhXFHbx/iy13v8wW6ncf7w+pForshZRaPmXpmq3QzhhrprNBIFhu4pY0
AsLwmqau9VA2YdaHfXLmduKkQEUrxk3co4zknOId11v22YGMswC6cv+dbBC10opp
djSsvoWC5MQ62NHofOOngoSfVwd00TwtGpnu30iBcnDq2041w9rvzt/dNFQlLvKh
hyeHP5GHiG6PNO22MrFnI7lfZ93QlLUNdG4b9WSoodloZK6TPas0ucfUkVaX9BjE
3CK3ATpeYN+aUuVa2R0p7Nqka3nluwTGlY16tXeVZ4ZH353sApvDzR+jw1KWXHbL
c5kk+7RL+tjK94WUDYbiRo8qVWC3YTzp0fRDrOXGAlr6Vn6pz54Z+2poRoumMGFI
5b6UUPbQ4UVZIBHBKpC6sriJFtooOkylpW9hgvb3lquzjmMwrfMuEzTy9VPY/6ep
/qEbg99qkDHWm2dkOOl7TOAl39Hx+ucCAwEAATANBgkqhkiG9w0BAQ0FAAOCAgEA
gGZAHdKs6NXS728yIbSSGrXk9Xzmx/Hi3DPT20T3K9af5ZaWgZ1tCpNw8yEiBcQp
CS8Bfy1Lnj17G2ILqW437YtUyA2aXFocbSWIIcS73LAYI7668z1kyprpj0Q0LD6V
RF3hBHskDlq2ade0v3nu5SgZdyvPo6g4a/W3QDdFxUy56HrlupmqLInOZssfMRF7
c7S1eL0+vmvTLXwZnz4gAmTaFt4KJ8NS709YiQemdgHL8DSU7QYt8QcEH1yZbj2v
70Fgu0CeEZmUnAaRugFOIBBQIsBmC6rO9K4XZOpa3XXue2uXoMaTG60rXOVEChxH
+ioSrb71mq3CEXaNUVQKy+sKzGjJE/e8xQbdb8acDTXc9ExgpQcjPQU0FjOaOYuQ
hRmXQV4y7f2I9j9oiyckNlu4Tpi3nH4efJcTr6OVfUkyn7kKXMT/vk8clJVDS66w
Ox4kgeM8nOdmmL7pjVIQgN6iwH2LNO14vQoXOwvjDM70i1dykEe5lu2sJxnq1Q19
OzY9au4DemDdQ6alBvd5SYrNMBg3A7o2dx88/LdAj606LTf7rvN9Hp03IHNKnUpa
g9YSuDKcmFBruBJAUDVOe9LXnUGO9wd2HbZWUkGO1Yx+nSBbzci0k3dM9ExNP8jN
D2higTN5OyHeCR9UJW4Gqu+r/mzm8XHJXPKIa+fX2AY=
-----END CERTIFICATE-----
EOL

cd ~/Marzban-node
docker compose up -d

echo_info "Finalizing UFW setup..."

ufw allow 22
ufw allow 80
ufw allow 2096
ufw allow 2053
ufw allow 2083
ufw allow 62050
ufw allow 62051

ufw --force enable
ufw reload
speedtest
