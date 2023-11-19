# xray-dashboard
a .sh script to easy read xray statistics info.  
xray version 1.8.4

## usage
1. copy or download xray-dashboard.sh to you device.
2. give file right power to run.
```sh
chmod 777 xray-dashboard.sh
```
3. open file and **modify api_server** to adapter your xray options.
4. jsut run.
```
./xray-dashboard.sh
```
![image](https://github.com/Mesimpler/xray-dashboard/assets/50081549/d5a5711e-dce9-4278-a903-12355866049f)

## alert
no error catch, you should ensure you can correct run xray api command.
```
xray api statsquery -s 127.0.0.1:10085 -pattern ""
```
