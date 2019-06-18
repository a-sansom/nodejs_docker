This is just an experimental repository for seeing what's possible with Docker (Dockerfile and docker-compose.yml that references the Dockerfile) and VScode.

See comments in the `Dockerfile` and `docker-compose.yml` files for usage.

Simply put, running `docker-compose up -d --build` will build a new `alexsansom/deleteme` image (with a `latest` tag), create a container from it, and run the container.

The running container is a Nodejs `express` application that prints some text to the screen when you visit `http://localhost:3000` in the browser. If you edit `simple-express-example.js`, the application is restarted (not the container) and refreshing the browser will show the changes. This is becuase the container uses `nodemon` to monitor for changes.
