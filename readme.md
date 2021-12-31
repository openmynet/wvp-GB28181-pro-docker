# wvp-GB28181-pro docker 镜像制作
> 制作独立的 wvp-GB28181-pro docker 镜像
> 该镜像中仅包含 wvp-GB28181-pro 程序，不包含 zlmediakit、redis、录像辅助程序
> zlmediakit、redis、录像辅助程序 将独立按需部署

## 镜像制作
```bash
docker build -t wvp-alpine .

```
## 运行
> 修改需要运行的 docker-compse.yml 文件中涉及到 ip 部分的内
```yaml
  gb28181p:
    environment:
      SIP_IP: "192.168.0.177"
      MEDIA_IP: "192.168.0.177"
```

1. sqlite 模式
```bash
# 使用内部的 sqlite 数据库
docker-compose up -d
# 或者 使用外部的 sqlite 数据库 （当前目录下的wvp.sqlite）
docker-compose -f ./docker-compose.sqlite.yml up -d 

```
2. mysql 模式
```bash
docker-compose -f ./docker-compose.mysql.yml up -d 

```

## 测试
1. 下载gb28181客户端 [https://happytimesoft.com/products/gb28181-device/index.html](https://happytimesoft.com/products/gb28181-device/index.html)
   1. [x64下载](https://happytimesoft.com/downloads/happytime-gb28181-device-x64.zip)
   2. [x86下载](https://happytimesoft.com/downloads/happytime-gb28181-device.zip)
2. 解压并修改 `config.xml` 配置文件
3. 双击运行 `GB28181Device.exe`

## 各个组件之间的关系
```bash
#1 gb28181客户端 到 wvp服务器
GB28181.Client  --:5060--> wvp.server (5060: gb28181数据端口)

#2 gb28181客户端 到 媒体服务器
GB28181.Client  --:10010--> zlmediakit.server (10010: 固定视频流端口)[rtp-proxy-port: 10010]
# or
GB28181.Client  --:30000-30500--> zlmediakit.server  (30000-30500: 动态视频流端口)

#3 wvp服务器 到 媒体服务器
wvp.server -- :8000 --> zlmediakit.server (http-port: 8000, 视频播放及zlm管理端口)
```
**wvp配置细节说明（非常重要）**
```yaml
# application.yml
sip:
  ip: 192.168.1.100 # ip或域名 要求可以被gb28181设备访问 
media:
  ip: 192.168.1.100 # ip或域名 要求可以在局域网或者公网中可以访问到
```