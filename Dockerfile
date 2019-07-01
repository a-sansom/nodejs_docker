# Make changes to this file. Then, build a new image with:
#
#     docker build -t alexsansom/nodejs_docker .
#
# Run a container, in detached mode, with port 3000 mapped from the host (Mac) to client container, and mount the current directory as a Docker volume, based on the image, with:
# NOTE: (pwd) is fish shell specific for printing present working directory. Could be ($pwd) in other shells.
#
#     docker run -d -p 3000:3000 -v (pwd):/app alexsansom/nodejs_docker
#
# Alternatively, using docker-compose(.yml) that encompasses CLI params in the file, to build new image(s):
#
#     docker-compose --verbose build
#
# Or, build new image(s), create new container(s) and run them in detached mode:
#
#     docker-compose up -d --build
#
# Tail a container's logs with:
#
#     docker logs --follow <container_id>
#
FROM node:10

# The Node express server will be running on port 3000, so needs exposing.
EXPOSE 3000

# Set the context of where we will be executing commands in the container.
WORKDIR /app

# Install 'nodemon' in the container as a global node package.
# See https://docs.docker.com/engine/reference/builder/#run
RUN ["npm", "install", "-g", "nodemon"]

# Run the 'application', with 'node'.
#CMD ["node", "simple-express-example.js"]
# Run the 'application', with 'nodemon' so that changes are immediately
# reflected (the node application, not the container, is restarted when files
# change).
CMD ["nodemon", "simple-express-example.js"]

# Both ENTRYPOINT and CMD achieve a running node(mon) 'application'. But, the
# intent of each command is different. The closest to a decent, easy to
# understand explanation on the difference yet seen is each commands section
# in this 'best practices' guide:
# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
#ENTRYPOINT ["nodemon", "simple-express-example.js"]