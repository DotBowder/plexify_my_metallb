# plexify_my_metallb

Helper scripts for the setup of a Plex Media server in Kubernetes with a Metallb load balancer.

## Description:

To setup a Plex Media server in Kubernetes using Metallb for local network access, the following Kubernetes objects are needed.

* **Namespace**,**ConfigMaps**,**Services**,**Deployment**

This script will generate a yaml file for each one of the needed objects. They can then be modified to add custom environment features like persistent volume claims.

The variables at the beginning of this script are labeled as CRITICAL or as arbitrary.

* **CRITICAL**
  * Unique values to a specific account or configuration. eg: My account with cloudflare has a different email than yours, therefore the variable holding my email is CRITICAL.
* **arbitrary**
  * Unique values that have no major consequences as to what value they hold. These arbitrary values only need to be unique.

  **NOTE**: In step 1, the helm installation of metallb is commented out, If you wish to install metallb, uncomment the helm commands.

  ## Variables:

  **METALLB_CONFIG_IP_RANGE** is the CRITICAL ip address pool available to metallb.

  > **NOTE**: the ip range format should look like this example: "172.16.0.210-172.16.0.219"

  **PLEX_FQDN** is the CRITICAL fully qualified domain name for your plex server.

  **METALLB_PLEX_IP** is the CRITICAL metallb ip address to be acquired by your plex server.

  > **NOTE**: This IP address should fall within the range defined in METALLB_CONFIG_IP_RANGE and should not already be assigned to another service.

  **METALLB_CONFIG_NAME** is the CRITICAL name of the metallb configuration.

  > **NOTE**: the helm installation of metallb dictated this name as "my-release-metallb-config" and should not be changed unless you modify the helm assigned name of the metallb config.

  **NAMESPACE_NAME** is the arbitrary name of the plex namespace.

  **METALLB_SHARING_KEY** is the arbitrary value that binds the two service objects into one.

  **PLEX_CONFIG_NAME** is the arbitrary name of the plex configmap.

  **PLEX_CONTAINER_NAME** is the arbitrary name of the plex deployment container.

  **PLEX_APP_NAME** is the arbitrary app name of the plex deployment.

  **PLEX_TCP_SERVICE_NAME** is the arbitrary name of the tcp services of plex.

  **PLEX_UDP_SERVICE_NAME** is the arbitrary name of the udp services of plex.
