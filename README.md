# etherdraw

实时协作绘图工具

## 特点:

    快速、轻量级、易维护


## 参数:

    PORT: 服务启动端口。默认为5000
    DB_TYPE: 数据存储类型。默认为dirty, 支持dirty|mysql
    MYSQL_HOST: DB_TYPE=mysql时生效, mysql服务器地址
    MYSQL_PORT: DB_TYPE=mysql时生效, mysql服务器端口
    MYSQL_USER: DB_TYPE=mysql时生效, mysql服务器用户
    MYSQL_PASS: DB_TYPE=mysql时生效, mysql服务器密码
    MYSQL_DATABASE: DB_TYPE=mysql时生效, 应用的数据库名称, 默认为etherdraw
    DIRTY_DB: DB_TYPE=dirty时生效, 默认为/data/dirty.db
    SSL_KEY: 可下载的url,启动时下载该文件并设置生效 (Alpha)
    SSL_CERT: 可下载的url,启动时下载该文件并设置生效 (Alpha)
    RESET: 是否重新初始化文件。默认为0。设置为1,则保存的持久化文件丢失
    
    docker run -e PORT=5000 -e DB_TYPE=mysql --link mysql:mysql -e RESET=1 etherdraw
    docker run -e PORT=5000 -e DB_TYPE=dirty etherdraw


##mysql支持:

    正式版本需要使用mysql, 用户提高系统性能。
    默认不关联mysql,如果需要mysql,可以使用如下两种方式:
    1、系统部署在好雨云上, 直接在依赖中关联mysql, 重启即可
    2、启动容器后,访问http://ip:port/admin,登陆后直接修改settings.json,配置mysql连接信息,重启即可


##作者:

    见页面:https://github.com/JohnMcLear/draw/graphs/contributors

##源码:
    https://github.com/JohnMcLear/draw.git
    
## 备注:
    国内构建可以将docker中屏蔽的代码打开
