# MI SHAJIB'S DOCKER BOILERPLATE

### Technologies Used

- Docker: DevOPS Technology used for setting up virtual environments for running containerized applications
- MySQL: Database technology
- Apache: Web-server application
- Nginx: Web-server application
- PHP Laravel: Server-side Web Framework
- Vue: Front-end framework for building progressive web applications
- Bootstrap: Front-end CSS styling framework

# Docker for developer environment

### Install Docker

Visit https://docs.docker.com/get-docker for instructions.

### Install Docker Compose (linux only)

Visit https://docs.docker.com/compose/install for instructions.

### Switch to Linux containers (windows only)

Right-click on the Docker icon in Taskbar and choose "Switch to Linux containers..."

### Prepare repositories

Clone backend, frontend and docker repositories into one folder. For example:

```
~/mishajib/backend
~/mishajib/docker
~/mishajib/frontend
```

You can choose any folder names while cloning repositories, for example:

```
~/mishajib/backend
~/mishajib/docker
~/mishajib/frontend
```

### Prepare backend folder

Backend requires permissions to write into `storage` and `bootstrap/cache` folders.

**Linux/macOS:**

```
sudo chmod -R ag+w <path-to-backend-folder>/bootstrap/cache
sudo chmod -R ag+w <path-to-backend-folder>/storage
```

**Windows:**  
Use File Explorer to change permissions for these folders.

### Configure `docker-compose`

In Docker repo folder, copy `.env.example` to `.env` and edit it accordingly:

* `COMPOSE_CONVERT_WINDOWS_PATHS=1`  
  Uncomment this line on Windows OS. That will tell Docker to interconvert unix/win paths.
* `BACKEND_DIR`  
  Absolute or relative path to the folder with cloned backend repo.
* `FRONTEND_DIR`  
  Absolute or relative path to the folder with cloned frontend repo.
* `LISTEN_IP`  
  IP address to listen incoming HTTP connections. If you already have `apache`/`nginx` listening on `127.0.0.1:80` port
  then you can bind docker containers to listen on another IP (default `127.0.0.2`).  
  **Warning:** If already have `apache`/`nginx` working on your host, make sure they are not bound to `0.0.0.0`, that
  will prevent `nginx` container from starting. Rebind your host `apache`/`nginx` to `127.0.0.1` instead.  
  **macOS users:** By default macOS doesn't bind other 127.0.0.* to loopback adapter, so you have to do that yourself:  
  ```sudo ifconfig lo0 alias 127.0.0.2 up```

**macOS** / **Windows** only:
You have to allow docker engine to bind mount your frontend/backend folders into containers:

1. Open Docker Agent preferences
2. Select **Resources** &rarr; **File Sharing** in the left menu.
3. Add the folder you cloned repos into (`/mishajib` from previous examples).

### Configure hosts

Docker containers configured to work on `mishajib.local` (frontend) and `api.mishajib.local` (backend).  
You have to add these records to your `/etc/hosts` (linux/macos) or `%WIN_DIR%\System32\drivers\etc\hosts` (win).

```
127.0.0.2 mishajib.local
127.0.0.2 api.mishajib.local
```

You'll need root/administrator privileges to edit this file.

### Build and run containers

Open terminal/console in the folder with cloned Docker repo and run:

```
docker-compose build
```

Building could take some time, because Docker will pull all needed images from Docker Hub.

When it's done you're ready to run containers:

```
docker-compose up -d
```

First run could take some time, because frontend/backend will install needed dependencies. WAIT 10 MINUTES after
executing docker-compose up -d for the first time.

To start/stop containers you can use `docker-compose stop` and `docker-compose start`.  
To remove containers you can use `docker-compose down`.  
To show containers status you can use `docker-compose ps`, it should show something like that:

```
   Name                  Command               State                  Ports               
------------------------------------------------------------------------------------------
mi-backend    /entrypoint.sh php-fpm           Up      9000/tcp                           
mi-frontend   /entrypoint.sh yarn serve  ...   Up      8080/tcp                           
mi-mysql      docker-entrypoint.sh mysqld      Up      127.0.0.2:3336->3306/tcp, 33060/tcp
mi-nginx      /docker-entrypoint.sh ngin ...   Up      127.0.0.1:32782->80/tcp            
```

### Problems

#### 1. Pecl Installation Problem

If this error showed when you tried to build the backend's docker image:

```
# pecl install imagick-3.4.3
No releases available for package "pecl.php.net/imagick"
```

**Solution**

Based on this [**docker-library issue**](https://github.com/docker-library/php/issues/1134), It happened because there's
a connection problem with image `php:7.4-fpm-alpine` that backend's docker uses.

The easiest solution that you can do is change the image that backend's docker use in the file `backend/Dockerfile` line
3

```
FROM php:7.4-fpm-alpine
```

with

```
FROM php:7.4-fpm-alpine3.12
```

**PS: Trial and Error that has been tried**

I has tried to remove the pecl installation for imagick first in the file `backend/Dockerfile` line 35-36

```
  && pecl install imagick-3.4.3 \
  && docker-php-ext-enable imagick \
```

and thinking about doing the installation after the docker's image and container created. But the error still persists
and a new problem occurs.

It's turn out that the connection problem that occurs also happened in the `composer install` process. This is an
example of one of the error messages that appear:

```
...
- Installing psr/simple-cache (1.0.1): Downloading


    Failed to download psr/simple-cache from dist: The "https://codeload.github.com/php-fig/simple-cache/legacy.zip/408d5eafb83c57f6365a3ca330ff23aa4a5fa39b" file could not be downloaded: php_network_getaddresses: getaddrinfo failed: Try again

failed to open stream: php_network_getaddresses: getaddrinfo failed: Try again
Now trying to download from source

  - Installing psr/simple-cache (1.0.1): Cloning 408d5eafb8 from cache
...
```

It takes quite a while for one dependency installation and unfortunately it happens in the all dependency
installations--around 30 second. So you can imagine how long it take if there > 100 dependencies.

#### 2. mi-backend and mi-frontend status is always `Restart`

If your mi-backend and mi-frontend status is always `Restart` and when you open the docker containers' Logs you get this
error message:

```
docker | /entrypoint.sh: set: line 2: illegal option -
```

This problem occurs because of the these files:

1. backend/entrypoint.sh
2. frontend/entrypoint.sh

is using Dos-type EOL (end-of-line): \r\n. While the image we use for backend and frontend images is Unix-based, so it
required Unix-type of EOL: \n.

**Solution**

Open these files in Notepad++ (our old pal), then go to menu `Edit` -> `EOL Conversion` -> `Unix (LF)`. Don't forget to
save the files!

Anyway, You can tried to find another solution in google with keyword: "Convert Dos-type EOL to Unix-type EOL"

### Containers description

There are 4 containers:

* `mi-nginx`  
  Listens incoming web requests (HTTP) and dispatches them to **frontend** or **backend**.

* `mi-mysql`  
  MySQL database for **backend**. On first run it will be seeded with admin user account and dev hotel id/context.  
  Login/password: `admin@mishajib.local`/`123123123`.  
  You can access this DB from your host using `127.0.0.2:3336`.  
  Database content preserved between container restarts, but cleaned up upon `down` command.

* `mi-frontend`  
  **Frontend**. Served using `yarn serve` command, with Hot Code Reload enabled. Exposes port `8080`.

* `mi-backend`  
  **Backend**. Server using `php-fpm` (7.2). Exposes port `9000`.

You can restart container using `docker-compose restart <container-name>`, for
example: `docker-compose restart mi-backend`.  
If you'll omit container name, then all containers will be restarted.

---

*Happy coding, do something wonderful ;)*
