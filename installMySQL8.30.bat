@echo off
chcp 65001 > nul

setlocal enabledelayedexpansion

:ask_choice1
set /p choice="您是否有 MySQL 压缩包？ [Y/N]: "
if /i "%choice%"=="N" (
    echo 正在下载 MySQL 压缩包...
    curl -o "mysql-8.3.0-winx64.zip" "https://cdn.mysql.com//Downloads/MySQL-8.3/mysql-8.3.0-winx64.zip"
    set "mysql_zip=mysql-8.3.0-winx64.zip"
) else if /i "%choice%"=="Y" (
    :validate_input
    set /p "mysql_zip=请输入 MySQL 压缩包路径（必须为 .zip 格式）："
    if exist "!mysql_zip!" (
        goto :input_valid
    ) else (
        echo 无效的路径，请重新输入。
        goto :validate_input
    )
) else (
    echo 无效的选项，请重新输入。
    goto ask_choice1
)
:input_valid



:ask_choice2
set /p choice="是否停止与删除现有的 MySQL 服务？[Y/N]："
if /i "%choice%"=="Y" (
    powershell -Command "Start-Process cmd -ArgumentList '/c net stop mysql' -Verb RunAs"
    powershell -Command "Start-Process cmd -ArgumentList '/c sc delete mysql' -Verb RunAs"
) else if /i "%choice%"=="N" (
    echo 操作已取消
    exit
) else (
    echo 无效的选项，请重新输入。
    goto ask_choice2
)


timeout /t 1 > nul
if exist "C:\MySQL" (
    rd /s /q "C:\MySQL"
    timeout /t 1 > nul
)
mkdir "C:\MySQL"

timeout /t 1 > nul
echo 解压 MySQL 压缩包到 C:\MySQL\mysql-8.3.0-winx64 目录...
mkdir "C:\MySQL\mysql-8.3.0-winx64"
tar -xf "%mysql_zip%" -C C:\MySQL\mysql-8.3.0-winx64 --strip-components=1
timeout /t 2 > nul

(
    echo [mysqld]
    echo port=3306
    echo basedir=C:\\MySQL\\mysql-8.3.0-winx64
    echo datadir=C:\\MySQL\\mysql-8.3.0-winx64\\data
    echo max_connections=200
    echo character-set-server=utf8
    echo default-storage-engine=INNODB
) > C:\MySQL\mysql-8.3.0-winx64\my.ini
echo 已成功创建 my.ini 文件...

rem echo 等待两秒
timeout /t 2 > nul

rem 新建管理员cmd运行mysql安装命令
powershell -Command "Start-Process cmd -ArgumentList '/k', '\"cd C:\MySQL\mysql-8.3.0-winx64\bin\" && mysqld --initialize --console && mysqld --install && net start mysql && echo root@localhost后所带字段为临时密码，登陆成功后请修改密码！ && echo 1、登录MySQL：mysql -u root -pXXXXXX && echo 2、修改密码：ALTER USER ''root''@''localhost'' IDENTIFIED BY ''your_new_password''; && echo 3、安装出现问题请重新执行该脚本' -Verb RunAs"

pause