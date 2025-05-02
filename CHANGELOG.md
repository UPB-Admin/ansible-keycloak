## Changelog

### May 2025

- Configure the certificates to have the `CA: true` basic constraint and add the
  "basic constraints critical" setting. This is the same behavior as
  `openssl req -x509` and is a reasonable default for self-signed
  certificates. The `CA: true` basic constraint is required by the
  `update-ca-trust` command (according to this Stack Exchange post:
  https://unix.stackexchange.com/a/599944); otherwise, the certificate is not
  added to the certificate bundle. This is especially relevant for the load
  balancers' certificate, to allow clients to trust it at system level.
  **NOTE**: applying this change will restart all services, as their
  certificates change and the services must reload the certificates.

- Add health checks (check if TCP ports respond) to the Infinispan and Keycloak
  systemd service files. Also remove the `PIDFile` parameter from Keycloak's
  service file as the service does not create the PID file, and using it in
  conjunction with the `ExecStartPost` command makes systemd believe the
  service start fails.


### January 2025
- Add configuration option to ignore dangling lock files in Infinispan
  persistence directory after an unclean service shutdown.
  Not setting this option results in Infinispan refusing to start if the service
  was not cleanly shut down before.

- Add option to log audit events to the log file, besides the databases
  (defaults to true).

- Upgrade Keycloak to 26.0.7. This Keycloak version changes how communication to
  the external Infinispan server is configured (i.e., remote Infinispan servers
  are defined as variables in the Keycloak configuration file, instead of the
  `cache-ispn.xml` file, which has been removed). Other parameters, such as
  serialization protocol to Infinispan have also been changed.

- Also update Infinispan to version 15.0.11.Final to be in lockstep with the
  version used by Keycloak internally.

- Update environment variables for initial (bootstrap) Keycloak administrator
  account.

- Add rule to remove Infinispan persistence directory and restart Infinispan
  when upgrading Keycloak from a version earlier than 26; this is required since
  the marshalling protocol has changed to Infinispan Protostream, and is
  incompatible with the old JBoss Marshalling encoding. The variable used to
  keep track of the latest installed Keycloak version has been renamed to
  improve readability with this occasion.

- Add a "stop" rule to end parsing the data from the services in rsyslog.
  Without this rule, the lines from the Keycloak and Infinispan log files were
  also handled by the other rsyslog rules, which could copy the data to some
  other locations (e.g., the `/var/log/messages` file).

- Slightly improve rsyslog parsing by excluding empty rules (e.g., on a system
  running only LDAP, a `re_match($syslogtag, '^()$')` rule was added
  unnecessarily).

- Change logging configurations to only log success audit events to the `file`
  logger if all audit logs are logged. This is done by configuring the log level
  of the `org.keycloak.events` to `debug` if logging is enabled, which means
  that the events are logged by the `file` logger (since its log level is set to
  `debug` to capture all events of `debug` level or higher), but not the
  `console` logger (since its level is set to `info`, which is higher).

- Bump Keycloak to version 26.1.0.

- Remove Keycloak truststore password from the example vault file, as Keycloak
  can import certificates directly (in PEM format), without a truststore.
  If already defined, removing the password from the production vault is not
  required, since the value is simply not used by the playbook.

- Change check in LDAP playbook to allow installation on RedHat-based systems,
  not just CentOS; fail if the system is not RedHat-based, however.

### September 2024
- Bump Keycloak to version 25.0.6.

### August 2024
- Configure firewall port in NetworkManager configuration file. Starting with
  RHEL 9 the configuration using network-scripts has been deprecated, and
  replaced with NetworkManager configuration scripts.

- Add MariaDB and Infinispan services to the "After=" section in the Keycloak
  service file. This will make Keycloak wait for both services to finish
  starting before attempting to start itself (only works if services are
  hosted on the same node).

- Increase rsyslog message maximum size.

- Upgrade Keycloak to version 25.0.2 and Infinispan to version 15.0.5.
  This is a large change that introduces multiple changes: Keycloak now
  supports persisting user sessions in the database as an experimental
  feature. We have enabled this feature by default; consequently, Infinispan
  persistence to the database has been removed and replaced with a local
  file storage persistence.

  Various other changes have been introduced as requirements for the upgrade:
  a new management port has been added to Keycloak and is exposed to the
  reverse proxy on port 9001, Java has been bumped to version 21, Infinispan
  cache configurations have been updated, Keycloak HotRod marshalling has been
  removed, Infinispan role mappings are explicitly set in the
  `groups.properties` file, the `MONITOR` role has been added for the Keycloak
  user in Infinispan.

  **NOTE**: The upgrade removes Infinispan persistence to the database; all
  existing user sessions from before the upgrade will be lost.

  **NOTE**: The playbook does not remove the database used for Infinispan
  persistence. After upgrading and confirming that everything works as
  expected, you can safely drop the `infinispan` database.

- Move Keycloak and Infinispan logs to `/var/log/keycloak` and
  `/var/log/infinispan`, respectively. This is required to allow rsyslog to
  track the log files using the `imfile` module (in `inotify` mode).
  Inotify is blocked by SELinux for normal files.

- Improve rsyslog processing of logs by also reading logs from files.
  This allows us to configure Keycloak and Infinispan to log in JSON format
  for easier parsing, without changing the format of the logs in the journal.
  Logging is configured at role level, instead of globally, which means that
  only the services installed on the system have associated rules in the
  rsyslog file. It is also possible to define additional custom logging from
  either the journal or files.

- Add some security rules to Keycloak and Infinispan systemd services.

- Use the more modern `RSYSLOG_ForwardFormat` template that sends more precise
  timestamp information, as well as the timezone offset information.

- Bump Keycloak to version 25.0.4.


### June 2024
- Fix typo in Infinispan backup configurations.

- Add optional configurations for mTLS rsyslog. The playbook only generates
  the private key and certificate sign request, but does not (as it cannot)
  automatically sign the CSR to generate a certificate. This means that the
  playbook must be run twice - once to generate the certificate sign request,
  and a second time to configure the certificate and restart rsyslog.

- Add SELinux port configurations for rsyslog, to allow connecting to
  non-standard syslog ports.


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

  **NOTE**: The memory cap of 4GB is only applied if both Java and non-Java
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
