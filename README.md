# wsl-setup
```bash
wget -q "https://raw.githubusercontent.com/Himeyama/wsl-setup/master/ubuntu-setup.sh" -O- | bash
```

WSL 再起動時に以下を実行

```bash
echo nameserver 1.1.1.1 | sudo tee /etc/resolv.conf
```

ルーターの DNS でも OK

```bash
echo nameserver 192.168.0.1 | sudo tee /etc/resolv.conf
```
