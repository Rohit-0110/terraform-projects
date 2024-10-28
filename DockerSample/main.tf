# Build image php-httpd
resource "docker_image" "php-httpd-image" {
  name = "php-httpd:challenge"
  build {
    context = "lamp_stack/php_httpd"
    label = {
      challenge = "second"
    }
  }
}

# Build image mariadb
resource "docker_image" "mariadb-image" {
  name = "mariadb:challenge"
  build {
    context = "lamp_stack/custom_db"
    label = {
      challenge = "second"
    }
  }
}

# Docker Network
resource "docker_network" "my_network" {
  name = "my_network"
}

# Webserver
resource "docker_volume" "website_content" {
  name = "website_content"
}

resource "docker_container" "webserver" {
  name     = "webserver"
  image    = "php-httpd:challenge"
  hostname = "php-httpd"
  networks_advanced {
    name = docker_network.my_network.name
  }

  ports {
    internal = 80
    external = 80
    ip       = "0.0.0.0"
  }

  labels {
    label = "challenge"
    value = "second"
  }

  volumes {
    volume_name    = docker_volume.website_content.name
    container_path = "/var/www/html"
  }
}


# Database
resource "docker_volume" "mariadb_volume" {
  name = "mariadb_volume"
}

resource "docker_container" "mariadb" {
  name     = "db"
  image    = "mariadb:challenge"
  hostname = "db"
  networks_advanced {
    name = docker_network.my_network.name
  }

  ports {
    internal = 3306
    external = 3306
    ip       = "0.0.0.0"
  }
  labels {
    label = "challenge"
    value = "second"
  }

  env = [
    "MYSQL_DATABASE=simple-website",
    "MYSQL_ROOT_PASSWORD=1234"
  ]

  volumes {
    volume_name    = docker_volume.mariadb_volume.name
    container_path = "/var/lib/mysql"
  }
}


# Dashboard
resource "docker_container" "phpmyadmin" {
  name     = "db_dashboard"
  image    = "phpmyadmin/phpmyadmin"
  hostname = "phpmyadmin"
  networks_advanced {
    name = docker_network.my_network.name
  }

  ports {
    internal = 80
    external = 8081
    ip       = "0.0.0.0"
  }

  labels {
    label = "challenge"
    value = "second"
  }

  depends_on = [
    docker_container.mariadb
  ]

  env = ["PMA_HOST=db", "PMA_PORT=3306"]
}