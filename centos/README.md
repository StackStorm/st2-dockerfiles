# StackStorm CentOS Docker Container

This is a fork off of the the StackStorm container (https://github.com/StackStorm/st2-dockerfiles) to change the OS to CentOS instead of Ubuntu. It fixes the systemd errors associated with a CentOS container and runs the container in a non-privileged environment.

## Disclaimer
This is an experimental release of the CentOS container. The container is not guaranteed to be in a stable condition.

## TL;DR

Open `https://localhost` in a browser. The default password is `admin:admin`. The password can be changed in `conf/stackstorm.env`

## Usage

### Prerequisites
* Docker Engine 1.13.0+

### development

Stackstorm Docs link

Packs should be developed in their own repository. This is to allow StackStorm the ability to install the packs in a production environment. Eventually submodules of these packs will be added to the `packs/` directory. No packs will be allowed in the master branch unless they are submodules.


### systemd fix
There are four fixes to allowing systemd to work inside a container.
1. Mounting /run as a tmpfs
2. Mounting the /sys/fs/cgroup as a read-only volume inside the Container
3. Removing all default systemd wants and only enabling services necessary to the application
4. Entrypoint is /sbin/init

## Known Issues

## Kubernetes Deployments
Below are Helm Chart snippets to run this container

### Values yaml
Sample of some expected Helm Values yaml
```
logLevel: INFO

# mongodb:
#   host: 
#   mongodbDatabase: 
#   userName: 
#   password: 

# rabbitmq:
#   host: 
#   secret:
#     name: 
#     userKey: 
#     passKey: 

# redis:
#   host: 
#   secret:
#     name: 
#     passKey: 

stackstorm:
  # base image
  image:
    registry: "docker.io"
    repository: "stackstorm/st2/all-in-one-st2"
    tag: "3.5.0-1"
    pullPolicy: "IfNotPresent"
  user: "stackstorm"
  password: "stanley"

  # for st2web
  dnsresolver:
    image:
      registry: docker.io
      repository: janeczku/go-dnsmasq
      tag: release-1.0.7

  # components scaling
  actionrunner:
    replicas: 4
  api:
    replicas: 1
  auth:
    replicas: 1
  scheduler:
    replicas: 4
  rulesengine:
    replicas: 2
  web:
    replicas: 2
  timersengine:
    replicas: 1
  stream:
    replicas: 2
  sensor:
    replicas: 1
  notifier:
    replicas: 2
  garbagecollector:
    replicas: 1
  workflowengine:
    replicas: 4

st2conf:
  docker: |+
    [actionrunner]


# rbac:
#     assignments:
#     mappings:
#     roles:
```


### Deployment
In the Deployment yaml for `containers`, the command to run a ST2 Component, the `st2api` as an example:

`st2api`
```
      containers:
      - name: st2api
        image: {{ .Values.stackstorm.image.registry }}/{{ .Values.stackstorm.image.repository }}:{{ .Values.stackstorm.image.tag }}
        imagePullPolicy: {{ .Values.stackstorm.image.pullPolicy }}
        command: 
          - /opt/stackstorm/st2/bin/st2api
          - --config-file=/etc/st2/st2.conf
          - --config-file=/etc/st2/st2.docker.conf
          - --config-file=/etc/st2/st2.user.conf        
        env:
          value: st2api
        ports:
        - containerPort: 9101
          protocol: TCP
          name: http
```


`st2web` example:
```
      containers:
      - name: st2web
        image: {{ .Values.stackstorm.image.registry }}/{{ .Values.stackstorm.image.repository }}:{{ .Values.stackstorm.image.tag }}
        imagePullPolicy: {{ .Values.stackstorm.image.pullPolicy }}
        command: 
          - /bin/bash
          - -c
          - ST2WEB_TEMPLATE='/etc/nginx/conf.d/st2-https.template' && envsubst '${ST2_AUTH_URL} ${ST2_API_URL} ${ST2_STREAM_URL}' < ${ST2WEB_TEMPLATE} > /etc/nginx/conf.d/st2.conf && exec nginx -g 'daemon off;'
        env:
        - name: ST2_SERVICE
          value: st2web
        ports:
        - containerPort: 443
      - name: dns-resolver
        image: {{ .Values.stackstorm.dnsresolver.image.registry }}/{{ .Values.stackstorm.dnsresolver.image.repository }}:{{ .Values.stackstorm.dnsresolver.image.tag }}
        imagePullPolicy: {{ .Values.stackstorm.image.pullPolicy }}
        env:
        - name: DNSMASQ_ENABLE_SEARCH
          value: "1"
        ports:
        - containerPort: 53
          protocol: UDP
```