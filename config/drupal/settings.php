
$config_directories[CONFIG_SYNC_DIRECTORY] = '../config/drupal/sync';

if (file_exists(__DIR__ . '/settings.local.php') && (getenv('ENVIRONMENT') == 'DEV')) {
  include __DIR__ . '/settings.local.php';
}

$databases['default']['default'] = array (
  'database' => getenv('DRUPAL_DATABASE') ?: 'drupal',
  'username' => getenv('DRUPAL_DATABASE_USER') ?: 'drupal',
  'password' => getenv('DRUPAL_DATABASE_PASSWORD') ?: 'drupalpw',
  'prefix' => '',
  'host' => getenv('DRUPAL_DATABASE_HOST') ?: 'db',
  'port' => '3306',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
);
