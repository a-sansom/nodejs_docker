This is just an experimental repository for seeing what's possible with Docker (Dockerfile and docker-compose.yml that references the Dockerfile) and VScode for development/debugging purposes.

Run npm install to install the `express` package and its dependencies, then build the Docker image/container to run the application.

See comments in the `Dockerfile` and `docker-compose.yml` files for usage.

Simply put, running `docker-compose up -d --build` will build a new `alexsansom/deleteme` image (with a `latest` tag), create a container from it, and run the container.

The running container is a Nodejs `express` application that prints some text to the screen when you visit `http://localhost:3000` in the browser. If you edit `simple-express-example.js`, the application is restarted (not the container) and refreshing the browser will show the changes. This is becuase the container uses `nodemon` to monitor for changes.

### Step debugging express script using the Dockerfile and VSCode

Possibly naive in intiial thinking that you can just take any exsiting Dockerfile/docker-compose.yml file and use it within VScode for step debugging. Docs (see links below) suggest you can use an existing Dockerfile/docker-compose.yml file, but it doesn't seem to be that straightforward as VSCode needs to alter the container to make things work.

An approach to achieve this (not going to be the only approach) is to create a separate docker-compose file, `docker-compose.VSCODE.yml` to reference the existing `Dockerfile`, but to tag the resulting image differently and override the default `CMD` that's used (with a `command` in the compose file).

Then, create a `.devcontainer.json` project file that references the `docker-compose.VSCODE.yml` file.

Open the project in VSCode, and you're prompted (by the existnece of `.devcontainer.json`) to open the folder in a container, for development.

When the folder is re-opened in the container (you can use `Remote-Conatiners: Reopen Folder in Container` in command palette), the tagged image is built (if doesn't already exist), the container is created/modified by VSCode (for its purposes) and you can then set a breakpoint in the code and run the aplication (`F5` or `Debug: Start Debugging` from command palette), visit the site in the browser (`http://localhost:3000/`) and debug breakpoints should be hit.

The debug configuration used with `Debug: Start Debugging` seems to default to the first defined set of configuration in the `.vscode/launch.json` file. This is currently `nodemon`, so, when debugging, any changes to source files are reloaded and will be shown on browser refresh (which is not the case for the general `node` config, which requires a debuggin session restart for changes to be visible).

Stopping the debug session means that the application is no longer available in the browser. But, *the container is still running* (see via `docker ps`). This is due to the `docker-compose.VSCODE.yml` configration `command: sleep infinity` which is the override to the default `CMD` in the underlying `Dockerfile`.

Inspiration of using the `command` override is from the docker-compose container templates official repository. See:

    https://github.com/microsoft/vscode-dev-containers/blob/30f79f47ec0dca47fc00a007e92d82b10831d61d/container-templates/docker-compose/.devcontainer/docker-compose.yml

    https://code.visualstudio.com/docs/remote/containers#_extending-your-docker-compose-file-for-development

    https://github.com/microsoft/vscode-dev-containers/tree/30f79f47ec0dca47fc00a007e92d82b10831d61d

    https://code.visualstudio.com/docs/remote/containers#_quick-start-open-a-folder-in-a-container

The running Docker container is stopped when you close VSCode (the folder that was opened 'in the container'). Using `docker images` will show that there is a new image with the tag `:vscode`, as that's what was used for the `image` in `docker-compose.VSCODE.yml`.

Overall, the above describes that we're using a single `Dockerfile`, but createing two separate Docker images. One so that the application can just run in a container. The second, so we can step debug it with VSCode.

Probably less that ideal. Lack of Docker *and* VSCode knowledge here may be hampering a better solution. Will be interesting to see if you have to go to the same lengths to get step debuggin working with other tools, such as Webstorm.