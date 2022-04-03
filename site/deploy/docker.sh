#!/bin/bash

docker build --network host -f deploy/Dockerfile --tag $IMGREPO .

# M1 Mac users may need to use buildx to specify the proper platform for the build.
# Comment out the line above and uncomment this one as necessary.
# docker buildx build -f deploy/Dockerfile --tag $IMGREPO --platform=linux/amd64 .

docker push $IMGREPO

# Uncomment to run a container locally using the new image (for testing).
# docker run --rm -it -p 127.0.0.1:8080:80 $IMGREPO