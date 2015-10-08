
$settings['hash_salt'] = file_get_contents(DRUPAL_ROOT . '/../config/docker/web/drupal-salt.txt');

$databases['default']['default'] = array (
  'database' => 'drupal',
  'username' => 'drupal',
  'password' => 'drupalpw',
  'prefix' => '',
  'host' => 'db',
  'port' => '3306',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
);

$settings['install_profile'] = 'minimal';
$config_directories[CONFIG_SYNC_DIRECTORY] = '../config/drupal/sync';

if (file_exists(__DIR__ . '/settings.local.php') && (getenv('ENVIRONMENT') == 'DEV')) {
  include __DIR__ . '/settings.local.php';
}
