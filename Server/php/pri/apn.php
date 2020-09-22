<?php

require_once(__DIR__.'/util.php');
require_once(__DIR__.'/db.php');
require_once(__DIR__.'/db_find_user.php');

require_once(__DIR__.'/email.php');  # @@@ REMOVE THIS

require_once __DIR__ . '/vendor/autoload.php';  // for JWT
use \Firebase\JWT\JWT;


const APN_TOKEN_ID = 'DYZK645FC9';
const APN_TEAM_ID  = '642SNV9NK2';

const APNS_ADDRESS = 'https://api.sandbox.push.apple.com:443';

function send_apn_message($target_id, $message)
{
  $db = new TGDB;
  $sql = 'select * from tg_users where userid=?';
  $result = $db->get($sql,'i',$target_id);

  $n = $result->num_rows;
  if( $n < 1 ) { api_error("Invalid target ID ($target_id) sent to send_apn_message"); }
  if( $n > 1 ) { api_error("Multiple entries for userid ($target_id) in tg_users"); }

  $target   = $result->fetch_assoc();
  $devtoken = $target[DEVTOKEN];

  if( empty($devtoken) ) { return NOTIFICATION_FAILURE; }

  $now = time();

  $badge = $now % 20;

  $notification = json_encode(
    array(
      'aps' => array (
        'alert' => array(
          'title' => $message,
          'subtitle' => 'subtitle',
          'body' => 'body'
        ),
        'badge' => $badge
      )
    )
  );

  $jwt = get_apn_token();

  $expires = $now + 3*86400; // 3 days from now

  $header = array(
    "authorization: bearer $jwt",
    'apns-push-type: alert',
    "apns-expiration: $expires",
    'apns-topic: com.vmwishes.game.the'
  );

  $jwt_json = json_encode($jwt);

  $curl = curl_init(APNS_ADDRESS . "/3/device/$devtoken");
  curl_setopt($curl, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_2TLS);
  curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($curl, CURLOPT_POST, true);
  curl_setopt($curl, CURLOPT_HTTPHEADER, $header);
  curl_setopt($curl, CURLOPT_POSTFIELDS, $notification);

  $response = curl_exec($curl);

  $return_code = SUCCESS;

  if( $response === false )
  {
    $info = curl_getinfo($curl);
    error_log("CURL FAILURE\n"
      . '     HEADER: ' . json_encode($header) . "\n"
      . '  CURL_INFO: ' . print_r($info,true) . "\n"
    );
    $return_code = CURL_FAILURE;
  }
  elseif( preg_match('/BadDeviceToken/',$response) )
  {
    $return_code = NOTIFICATION_FAILURE;
  }
  elseif( strlen($response) > 0 )
  {
    $info = curl_getinfo($curl);
    error_log("APNS FAILURE\n"
      . "   RESPONSE: '$response'\n"
      . '     HEADER: ' . json_encode($header) . "\n"
      . '       DATA: ' . $notification . "\n"
      . '  CURL_INFO: ' . print_r($info,true) . "\n"
    );
    $return_code = APNS_FAILURE;
  }

  curl_close($curl);

  return $return_code;
}

function get_apn_token()
{
  $db = new TGDB;
  $sql = 'select * from tg_apns_token where id=?';
  $result = $db->get($sql, 's', APN_TOKEN_ID);

  $now = time();

  $n = $result->num_rows;
  if($result->num_rows == 1)
  {
    $result = $result->fetch_assoc();
    if ( $now < $result['created'] + 2400 ) // 40 minutes
    {
      return $result['token'];
    }
  }

  $key = file_get_contents(__DIR__ . '/apnkey.p8');

  $payload = array(
    'iss' => APN_TEAM_ID,
    'iat' => $now
  );

  $token = JWT::encode($payload, $key, 'ES256', APN_TOKEN_ID);

  $sql = 'replace into tg_apns_token values (?,?,?)';
  $db->get($sql,'ssi',APN_TOKEN_ID,$token,$now);

  return $token;
}
