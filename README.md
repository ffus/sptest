# sptest
基于 Speedtest CLI 的一键测速脚本，支持 `Debian/Ubuntu` 和 `CentOS/RHEL`

# sptest 的使用
#### 一键安装和测速
```
# 国外
bash <(curl -sS https://raw.githubusercontent.com/ffus/sptest/main/sptest.sh)

# 国内
bash <(curl -sS https://mirror.ghproxy.com/raw.githubusercontent.com/ffus/sptest/main/sptest.sh)
```
再次使用可直接执行 `speedtest`

#### 一键卸载
```
# 国外
bash <(curl -sS https://raw.githubusercontent.com/ffus/sptest/main/sptest.sh) -u

# 国内
bash <(curl -sS https://mirror.ghproxy.com/raw.githubusercontent.com/ffus/sptest/main/sptest.sh) -u
```
---

也可以尝试先将 `sptest.sh` 下载到本地，然后上传到国内机，再执行脚本
```
# 安装并测速
bash sptest.sh

# 卸载
bash sptest.sh -u
```

#### 指定 server-id 测速
```
speedtest -s [server-id]  # Specify a server from the server list using its id
```
这里我提供几个国内的 5G 测速节点id：
| 节点id | 赞助商 |
|---------|---------|
| 60584 | ShenZhen-5G |
| 60794 | GuangZhou-5G |
| 54312 | China Mobile Zhejiang 5G |
| 17145 | China Telecom AnHui 5G |
| 26352 | China Telecom JiangSu 5G |
| 5396 | China Telecom JiangSu 5G |
| 36663 | China Telecom JiangSu 5G |
| 24447 | China Unicom 5G |
| 27154 | ChinaUnicom-5G |

指定节点示例：
```
speedtest -s 5396
```
指定的节点可能会连接不上，这取决于节点与主机的连接性，可以尝试更换其他节点


#### 测试效果
主要输出内容：
```
   Speedtest by Ookla

      Server: Emtel Ltd - Marseille (id: 59444)
         ISP: Oracle Cloud
Idle Latency:     0.86 ms   (jitter: 0.10ms, low: 0.69ms, high: 0.93ms)
    Download:  2864.64 Mbps (data used: 1.4 GB)                                                   
                  0.91 ms   (jitter: 0.14ms, low: 0.78ms, high: 1.55ms)
      Upload:  2890.53 Mbps (data used: 2.8 GB)                                                   
                  1.00 ms   (jitter: 13.49ms, low: 0.73ms, high: 207.95ms)
 Packet Loss:     0.0%
  Result URL: https://www.speedtest.net/result/c/62b720d3-ec68-4862-b2e4-a9b6501825d6
```
可将最后一行链接在浏览器中打开，效果如图：
<!-- ![打开链接：https://www.speedtest.net/result/c/62b720d3-ec68-4862-b2e4-a9b6501825d6 即可查看](https://raw.githubusercontent.com/ffus/sptest/main/demo.png) -->
![打开链接：https://www.speedtest.net/result/c/62b720d3-ec68-4862-b2e4-a9b6501825d6 即可查看](https://us.v-cdn.net/6034893/uploads/N6LF4EVVC17K/demo.png)
