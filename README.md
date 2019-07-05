# Using Docker containers with Node.js/express

(See also ["Using Docker containers with Node.js script 'as an executable'"](https://github.com/a-sansom/nodejs_executable_docker)).

This is just an experimental repository for seeing what's possible with Docker (`Dockerfile` and `docker-compose.yml` that references the `Dockerfile`) and VS Code and Webstorm [1] IDEs for development/debugging purposes of a Node.js express application.

Build the Docker image/container to run the application.

See comments in the `Dockerfile` and `docker-compose.yml` files for general usage.

Simply put, running `docker-compose up -d --build` will build a new `alexsansom/nodejs_docker` image (with a `latest` tag), create a container from it, and run the container (outside/independently of any IDE's Docker capabilities).

The running container is a Node.js `express` application that prints some text to the screen when you visit `http://localhost:3000` in the browser. If you edit `simple-express-example.js` in the IDE, the application is restarted (not the container) and refreshing the browser will show the changes. This is because the container uses `nodemon` to monitor for changes.

The Node.js `express` package is globally installed in the Docker container so only the application code is included in this directory. This means that there's no need to install any Node related tools locally to run/debug the application.

[1] The same steps here are applicable to PHPStorm too as it also has the ability to add remote Node.js interpreters and to control Docker containers.

## Step debugging `express` script using `Dockerfile`/`docker-compose.*` and VS Code

Included in this repository is the file `.vscode/extensions.json`. When this directory is opened in VS Code, because of this file, a dialogue offering to install the extensions listed in the file will appear, which you should accept. The extensions installed are related to Docker and remote debugging, which are needed for step debugging in a Docker container.

Possibly naive in initial thinking that you can just take any existing `Dockerfile`/`docker-compose.yml` file and use it within VS Code for step debugging. Docs (see links below) suggest you can use an existing `Dockerfile`/`docker-compose.yml` file, but it's not that straightforward as VS Code needs to alter the container to make things work.

To achieve this though we can create a separate docker-compose file, `docker-compose.extend.yml` that also references the existing `Dockerfile`, but also adds a `command` that will, when the file is used, override the default `CMD` in the `Dockerfile`.

Then, create a `.devcontainer.json` project file that references both the `docker-compose.yml` and the `docker-compose.extend.yml` files.

Open the project in VS Code, and you're prompted (by the existence of `.devcontainer.json`) to open the folder in a container, for development.

When the folder is re-opened in the container (you can use `Remote-Containers: Reopen Folder in Container` in command palette also), a tagged Docker image is built (if one doesn't already exist), the Docker container is created/modified by VS Code (and left in a 'sleep' like state, where it's running (show this by running `docker ps`) but the express app is *not* available in the browser).

You can then set a breakpoint in the code and start/run the application (`F5` or `Debug: Start Debugging` from command palette), visit the site in the browser (`http://localhost:3000/`) and any debug breakpoint(s) should be hit.

The debug configuration used with `Debug: Start Debugging` seems to default to the first defined set of configuration in the `.vscode/launch.json` file. This is currently `nodemon`, so, when debugging, any changes to source files are reloaded and will be shown on browser refresh (which is not the case for the general `node` config, which requires a debugging session restart for changes to be visible).

Stopping the debug session means that the application is no longer available in the browser. But, *the container is still running* (see via `docker ps`). This is due to the `docker-compose.extend.yml` configuration `command: sleep infinity` which is the override to the default `CMD` in the underlying `Dockerfile`.

The running Docker container is stopped when you close VS Code (the folder that was opened 'in the container').

Overall, the above describes that we're using a single `Dockerfile`, but the use of multiple `docker-compose.*` files allows us the ability to either run a container 'normally', or run a container for step debugging purposes via VS Code.

Inspiration of using the `command` override is from the docker-compose container templates official repository. See:

    https://github.com/microsoft/vscode-dev-containers/blob/30f79f47ec0dca47fc00a007e92d82b10831d61d/container-templates/docker-compose/.devcontainer/docker-compose.yml

    https://code.visualstudio.com/docs/remote/containers#_extending-your-docker-compose-file-for-development

    https://github.com/microsoft/vscode-dev-containers/tree/30f79f47ec0dca47fc00a007e92d82b10831d61d

    https://code.visualstudio.com/docs/remote/containers#_quick-start-open-a-folder-in-a-container

## Step debugging `express` script using `Dockerfile`/`docker-compose.*` and Webstorm (2019.1.3)

This seems reasonably straightforward in comparison to VS Code. All that's required is to setup a `Run/Debug configuration` for a remote interpreter, as is described in the Webstorm documentation [1].

Basically, select a new Node.js configuration, and for the `Node interpreter` use the `...` to add a new `Docker Compose` remote interpreter, selecting the `docker-compose.yml` in this directory for the `Configuration file` field value.

Saving those settings adds the new configuration at the top of the IDE's GUI. You can then set a breakpoint, click the 'Debug nodejs_docker (docker-compose)'  button next to the list of configurations and then access the application at `localhost:3000` in the browser which then hits the breakpoint.

The Webstorm settings are stored in the `.idea/` directory files in this repository, so the debug configuration etc should be available when the directory is opened in the IDE.

After clicking the 'Debug' button (or just the 'Run' button) you can see the running Docker container with `docker ps`. The container is stopped either when, during debugging you edit the file and save it (`nodemon` restarts the app, and the container is stopped which requires a new debug session to be started. This looks it could be related to the other parameters used when the IDE starts the container/debug session, see below), or you stop the debug session manually. VS Code seems to handle edit/save without the need to restart the session.

Looks like Webstorm uses a similar method to achieve debugging, using multiple `docker-compose.*` files to provide overrides of your initial one. Looking at the console having triggered debugging, you can see, as the first line, something like:

    ... /Users/alex/Library/Caches/WebStorm2019.1/tmp/docker-compose.override.10.yml ... --exit-code-from nodejs_docker --abort-on-container-exit ...
    ...

So, instead of us defining the docker-compose 'extend' (VS Code), Webstorm is creating an 'override' [2] automatically.

    [1] https://www.jetbrains.com/help/webstorm/configuring-remote-node-interpreters.html#ws_node_configure_remote_node_interpreter_docker
    [2] https://docs.docker.com/compose/extends/#multiple-compose-files