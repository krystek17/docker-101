CREATE DATABASE IF NOT EXISTS `wordpress`;
CREATE DATABASE IF NOT EXISTS `drupal`;
GRANT ALL ON `wordpress`.* TO 'user'@'%';
GRANT ALL ON `drupal`.* TO 'user'@'%';

