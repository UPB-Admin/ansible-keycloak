## Changelog


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
