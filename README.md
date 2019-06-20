# Using Docker containers and NodeJS

This is just an experimental repository for seeing what's possible with Docker (`Dockerfile` and `docker-compose.yml` that references the `Dockerfile`) and VSCode and Webstorm IDEs for development/debugging purposes.

Run `npm install` to install the `express` package and its dependencies, then build the Docker image/container to run the application.

See comments in the `Dockerfile` and `docker-compose.yml` files for general usage.

Simply put, running `docker-compose up -d --build` will build a new `alexsansom/deleteme` image (with a `latest` tag), create a container from it, and run the container (outside/independently of VSCode).

The running container is a Nodejs `express` application that prints some text to the screen when you visit `http://localhost:3000` in the browser. If you edit `simple-express-example.js`, the application is restarted (not the container) and refreshing the browser will show the changes. This is because the container uses `nodemon` to monitor for changes.

## Step debugging `express` script using `Dockerfile`/`docker-compose.*` and VSCode

Possibly naive in initial thinking that you can just take any exsiting Dockerfile/docker-compose.yml file and use it within VSCode for step debugging. Docs (see links below) suggest you can use an existing Dockerfile/docker-compose.yml file, but it's not that straightforward as VSCode needs to alter the container to make things work.

To achieve this though we can create a separate docker-compose file, `docker-compose.extend.yml` that also references the existing `Dockerfile`, but also adds a `command` that will, when the file is used, override the default `CMD` in the `Dockerfile`.

Then, create a `.devcontainer.json` project file that references both the `docker-compose.yml` and the `docker-compose.extend.yml` files.

Open the project in VSCode, and you're prompted (by the existence of `.devcontainer.json`) to open the folder in a container, for development.

When the folder is re-opened in the container (you can use `Remote-Containers: Reopen Folder in Container` in command palette also), a tagged image is built (if doesn't already exist), the container is created/modified by VSCode (and left in a 'sleep' like state, where it's running - `docker ps` - but the express app is not available in the browser).

You can then set a breakpoint in the code and start/run the aplication (`F5` or `Debug: Start Debugging` from command palette), visit the site in the browser (`http://localhost:3000/`) and debug breakpoints should be hit.

The debug configuration used with `Debug: Start Debugging` seems to default to the first defined set of configuration in the `.vscode/launch.json` file. This is currently `nodemon`, so, when debugging, any changes to source files are reloaded and will be shown on browser refresh (which is not the case for the general `node` config, which requires a debugging session restart for changes to be visible).

Stopping the debug session means that the application is no longer available in the browser. But, *the container is still running* (see via `docker ps`). This is due to the `docker-compose.extend.yml` configration `command: sleep infinity` which is the override to the default `CMD` in the underlying `Dockerfile`.

The running Docker container is stopped when you close VSCode (the folder that was opened 'in the container').

Overall, the above describes that we're using a single `Dockerfile`, but the use of multiple `docker-compose.*` files allows us the ability to either run a container 'normally', or run a container for step debugging purposes via VSCode.

Inspiration of using the `command` override is from the docker-compose container templates official repository. See:

    https://github.com/microsoft/vscode-dev-containers/blob/30f79f47ec0dca47fc00a007e92d82b10831d61d/container-templates/docker-compose/.devcontainer/docker-compose.yml

    https://code.visualstudio.com/docs/remote/containers#_extending-your-docker-compose-file-for-development

    https://github.com/microsoft/vscode-dev-containers/tree/30f79f47ec0dca47fc00a007e92d82b10831d61d

    https://code.visualstudio.com/docs/remote/containers#_quick-start-open-a-folder-in-a-container

## Step debugging `express` script using `Dockerfile`/`docker-compose.*` and Webstorm (2019.1.3)

This seems reasonably straightforward in comparison to VSCode. All that's required is to setup a `Run/Debug configuration` for a remote interpreter, as is described in the Webstorm documentation [1].

Basically, select a new Node.js configuration, and for the 'Node interpreter' use the '...' to add a new 'Docker Compose' remote interpreter, selecting the `docker-compose.yml` in this directory for the 'Configuration file' field value.

Saving those settings adds the new configuration at the top of the IDE's GUI. You can then set a breakpoint, click the 'Debug Deleteme (docker-compose)'  button next to the list of configurations and then access the application at `localhost:3000` in the browser which then hits the breakpoint.

The Webstorm settings are stored in the `.idea/` directory files in this repository, so the debug configuration etc should be available when the directory is opened in the IDE.

After clicking the 'Debug' button (or just the 'Run' button) you can see the running Docker container with `docker ps`. Which is stopped either when during debugging you edit the file and save it (requires a new debug sessions to be started), or you stop the debug session manually. VSCode seems to handle edit/save without the need to restart the session.

Looks like Webstorm uses a similar method to achieve debugging, using multiple `docker-compose.*` files to provide overrides of your initial one. Looking at the console having triggered debugging, you can see, as the first line, something like:

    /Users/alex/Library/Caches/WebStorm2019.1/tmp/docker-compose.override.10.yml
    ...

So, instead of us defining the docker-compose 'extend' (VSCode), Webstorm is creating an 'override' [2] automatically.

    [1] https://www.jetbrains.com/help/webstorm/configuring-remote-node-interpreters.html#ws_node_configure_remote_node_interpreter_docker
    [2] https://docs.docker.com/compose/extends/#multiple-compose-files