## Changelog

### May 2024
  - Bump Keycloak version to 24.0.4

### March 2024
  - Bump Keycloak version to 23.0.7.

### February 2024
  - Bump Keycloak version to 23.0.6.
  - Increase timeouts for remote store connections in Keycloak.
  - Disable MariaDB performance schema by default to reduce the database's
    memory footprint. It can be re-enabled if required.
  - Redo memory allocation calculations. The new calculations should be more
    fair for each service when multiple services run on the same system.
    Keycloak and Infinispan heap size is capped at 4GB, which should be enough
    for smaller deployments with up to 600 000 user sessions. Also, deploying
    Keycloak or Infinispan on servers with less than 2GB of RAM will fail, since
    we expect at least 768MB of RAM reserved for system overhead, and 1280MB of
    RAM for the service. This is a conservative estimate.
    **NB:** The memory cap of 4GB is only applied if both Java and non-Java
    services run on the same server. Otherwise, Java services should be able to
    use almost all available memory. This limit can be controlled using the
    `java_shared_system_mem_max` variable.

### January 2024
  - Change Keycloak embedded Infinispan JGroups stack to use a non default TCP
    port. This should allow hosting a dedicated Infinispan instance on the same
    node as Keycloak. Also changed the discovery mechanism to TCPPING
    (without initial hosts, functionally disabled), MPING could also conflict
    with the Infinispan service.
  - Bump Keycloak version to 23.0.3.
  - Add utility `cluster_servers` dictionary variable with lists of nodes that
    with each type of service in the cluster.
  - Use same version of Java for both Infinispan and Keycloak. If multiple
    versions of Java would be used, it would cause the Ansible playbooks to
    override the alternatives when both Infinispan and Keycloak are hosted on
    the same node. This change also upgrades Infinispan to Java 17.
  - Update PKI generation to correctly create PKI files for all services running
    on a single node.
  - Update rsyslog configurations to catch the logs sent to syslog by all
    services installed by the playbook.
  - Update memory allocation for Java services if multiple services run on the
    same system.

### December 2023
  - Update the playbook files to work with Centos 9 (and newer package versions
    available on Centos 9).
  - Update node and mysqld exporter versions.
  - Move firewall configurations to dedicated role.

### July 2023
  - The database (MariaDB) systemd overrides file has been renamed to
    `overrides.conf` to reflect that more than just file number limit can be
    changed.
  - Database error logs have been moved to the journal, instead of the
    `/var/log` directory. This aligns the logging mechanism with the rest of the
    services.
  - Added the rsyslog role that allows sending logs to remote log servers. The
    logs can be sent as either plain-text data or encrypted using TLS.

### June 2023
  - Keycloak was upgraded to version 21.1.2.

### March 2023
  - Set a proper name for Infinispan and Keycloak services in syslog.
  - Keycloak was updated to version 21.0.1.
  - Infinispan was updated to version 14.0.7.
  - Infinispan cross-datacenter timeout parameters were changed to allow more
    leeway in high contention scenarios and short network interrupts.
  - Added access to Infinispan metrics endpoint for Prometheus servers.
  - Set proper names for Keycloak nodes for session stickyness.
  - Updated nginx load balancing based on `AUTH_SESSION_ID` cookie, instead of
    just the source IP address.
  - Tweaked Galera configuration.
  - Moved Infinispan persistence to a different database, based on cluster
    names. Note that this will increase the database usage.


### January 2023
  - Keycloak was updated to version 20.0.3.
  - Infinispan was updated to version 13.0.13.
  - Infinispan persistence was changed to JDBC, storing the caches in a shared
    database inside the MariaDB cluster. This allows switching Infinispan
    versions without losing the local persistence data that was previously
    stored in a local (per-instance and per-version) RocksDB database.
  - Configured Keycloak to use the IP addresses of Infinispan instances, instead
    of hostnames. Using the hostname (from the Ansible inventory file) made
    Keycloak confused about the identities of the Infinispan servers it
    connected to, since Infinispan sent the IP address as the identifier, while
    Keycloak expected the servers to match their hostnames.


### December 2022
  - the EPEL modules are being deprecated (including the `epel-modulear`
    repository). The repository has been forcibly enabled, but will likely need
    to be removed in the future.
  - updated the nginx configuration to use stopping regex matches for location
    blocks (i.e. using the `~` modifier instead of the default (None) modifier).
    This is meant to increase matching precision, as the default modifier matches
    the longest described match of any `location`. An explanation of `location`
    blocks can be found on [Stack Overflow](https://stackoverflow.com/a/59846239).
  - access to the entire master realm has been limited using the same ACL that
    limits access to the admin console. This was necessary because despite not
    being able to access the admin console, an attacker could still attempt to
    attack the realm's login page.
