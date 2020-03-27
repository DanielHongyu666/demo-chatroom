# App Server 说明

## 要求

golang 版本需要高于 1.12。

## 配置

在 `config.yaml` 中配置您在融云开发者后台开通的 AppKey 和 Secret，以及对应的服务端口。

`app.version` 字段用于客户端版本更新，可以按需添加或删除。

## 编译

```shell
go mod download
go build .
```

> 如果您下载相关依赖较慢，可以在 shell 中设置下代理

> 如: `export GOPROXY=https://mirrors.aliyun.com/goproxy/`

## 启动

```shell
./appserver
```
