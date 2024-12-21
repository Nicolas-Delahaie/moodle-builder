<?php
// Moodle configuration file (check out every configs into config-dist.php file)

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype = 'mysqli';
$CFG->dblibrary = 'native';
$CFG->dbhost = 'mysql';
$CFG->dbname = getenv('DB_NAME');
$CFG->dbuser = getenv('DB_ADMIN_USER');
$CFG->dbpass = getenv('DB_ADMIN_PASSWORD');
$CFG->prefix = 'mdl_';
$CFG->dboptions = array(
  'dbpersist' => 0,
  'dbport' => 3306,
  'dbsocket' => '',
  'dbcollation' => 'utf8mb4_0900_ai_ci',
  'debug' => true,
);

$CFG->wwwroot = "http://" . getenv('MOODLE_HOST');
$CFG->dataroot = '/var/www/moodledata';
$CFG->lang = 'fr';
$CFG->directorypermissions = 0777;

require_once(__DIR__ . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!