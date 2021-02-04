# mediawiki config files

In the `LocalSettings.php` file, which needs to have the MySQL
account credentials, we have the following:

```
## Database settings
$wgDBtype = "mysql";
$wgDBserver = getenv('MYSQL_HOST');
$wgDBname = getenv('MYSQL_DATABASE');
$wgDBuser = getenv('MYSQL_USER');
$wgDBpassword = getenv('MYSQL_PASSWORD');
```

These environment variables are set via the `docker-compose.yml` file
for the pod.
