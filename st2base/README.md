# st2community base Docker Image
This is an intermediate Docker image with StackStorm Community installed in it.
We use this "base" intermediate image to build child containers for each st2 service and define granular resources like ports, volumes, users per each container.

## Build base intermediate image
```
docker build \
  --build-arg ST2_VERSION=${ST2_VERSION} \
  --tag stackstorm/st2base:${ST2_VERSION} .
```
This is a temporary image with StackStorm Community packages installed in it.

## Build st2 components docker images
```
for component in st2*-community; do
  docker build stackstorm/${component} --tag ${component}
done
```
These are production Docker images for each component that will be deployed to the StackStorm docker registry.
