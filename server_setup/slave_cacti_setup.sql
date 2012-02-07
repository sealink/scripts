-- http://code.google.com/p/mysql-cacti-templates/wiki/MySQLTemplates
-- Permissions needed for MySQL templates etc
grant SUPER, PROCESS on *.* to 'cacti'@'%' identified by 'precious_password';
-- heartbeat slave lag specific permissions 
grant select on info.heartbeat to 'cacti'@'%';

