# sptest
基于 Speedtest CLI 的一键测速脚本，支持 `Debian/Ubuntu` 和 `CentOS/RHEL`

# 使用
### 一键测速
```
bash <(curl -sS https://raw.githubusercontent.com/ffus/sptest/main/sptest.sh)
```
下次使用可直接执行 `speedtest`

### 指定 server-id 测速
```
speedtest -s [server-id]  # Specify a server from the server list using its id
```
这里我提供几个国内的 5G 测速节点id：
| 节点id | 名称 | 赞助商 |
|---------|---------|---------|
| 60584 | ShenZhen | ShenZhen-5G |
| 60794 | Guangzhou | Guangzhou-5G |
| 17145 | Hefei | China Telecom AnHui 5G |
| 5396 | Suzhou | China Telecom JiangSu 5G |
| 36663 | Zhenjiang | hina Telecom JiangSu 5G |
| 24447 | Shanghai | China Unicom 5G |
| 27154 | TianJin | ChinaUnicom-5G

# 测试效果
```
root@arm424:~# bash <(curl -sS https://raw.githubusercontent.com/ffus/sptest/main/sptest.sh)
Speedtest is already installed. Running speedtest...

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
