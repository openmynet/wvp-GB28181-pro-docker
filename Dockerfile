# docker build -t wvp-alpine .
FROM ubuntu:20.04 AS build

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

WORKDIR /home

# 使用国内镜像源加速软件安装
RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND="noninteractive" && \
    apt-get install -y --no-install-recommends openjdk-11-jre git maven curl nodejs npm

RUN git clone https://hub.fastgit.org/648540858/wvp-GB28181-pro.git
# RUN git clone https://github.com/648540858/wvp-GB28181-pro.git

# 使用了自己的settings.xml作为maven的源,加快打包速度
COPY maven/settings.xml /usr/share/maven/conf/settings.xml
COPY application-docker.yml /opt/app/config/application.yml

# 编译前端界面
RUN cd ./wvp-GB28181-pro/web_src && \
    export SASS_BINARY_SITE="https://npm.taobao.org/mirrors/node-sass/" && \
    npm install && \
    npm run build

# wvp打包
RUN cd /home/wvp-GB28181-pro && \
    mvn compile && \
    mvn package && \
    cp /home/wvp-GB28181-pro/target/wvp*.jar /opt/app/gb28181p.jar && \
    cp /home/wvp-GB28181-pro/src/main/resources/wvp.sqlite /opt/app/gb28181p.sqlite


# 使用精简的基础镜像
FROM amazoncorretto:8u312-alpine-jre

ENV TZ=Asia/Shanghai
EXPOSE 18080/tcp
EXPOSE 5060/tcp
EXPOSE 5060/udp
ENV LC_ALL zh_CN.UTF-8

WORKDIR /opt/app
COPY --from=build /opt/app /opt/app/
CMD ["/bin/sh","-c","java ${JVM_CONFIG} -jar gb28181p.jar --spring.config.location=/opt/app/config/application.yml"]
