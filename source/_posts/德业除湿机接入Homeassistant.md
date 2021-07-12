---
title: 德业除湿机接入Homeassistant
date: 2021-07-12 09:10:00
tags: Homeassistant
---



# 获取Token

使用postman发送post命令

![homeassistant-1](C:\msys64\home\Administrator\workspace\blog-source\source\_posts\homeassistant-1.jpg "retrieve token")

获取响应中的token，待后续使用

![homeassitant-2](C:\msys64\home\Administrator\workspace\blog-source\source\_posts\homeassistant-2.png)

# 获取设备列表

Authorization字段使用上一步中得到的token，注意前面要加"JWT "，得到product_id、device_id，待后续使用

​	![homeassistant-3](C:\msys64\home\Administrator\workspace\blog-source\source\_posts\homeassistant-3.png)

![homeassistant-4](C:\msys64\home\Administrator\workspace\blog-source\source\_posts\homeassistant-4.jpg)

# 获取设备控制信息

Authorization字段使用上一步中得到的token，注意前面要加"JWT "，得到mqtt信息，待后续使用

![homeassistant-5](C:\msys64\home\Administrator\workspace\blog-source\source\_posts\homeassistant-5.jpg)

