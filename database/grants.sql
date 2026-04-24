CREATE DATABASE IF NOT EXISTS medistore_dwh;

GRANT ALL PRIVILEGES ON sac.* TO 'sac_user'@'%';
GRANT ALL PRIVILEGES ON medistore_dwh.* TO 'sac_user'@'%';

FLUSH PRIVILEGES;
