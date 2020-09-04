<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');

require_once(__DIR__.'/db_find_user.php');

$userkey = get_required_arg(USERKEY);
fail_on_extra_args();

$info = db_find_user_by_userkey($userkey);
if( empty($info) ) { send_failure(INVALID_USERKEY); }

$userid = $info[USERID];

$db = new TGDB;

$sql = 'select * from tg_user_opponents where userid=?';
$result = $db->get($sql,'i',$userid);

$mtches = array();
if( $result )
{
  while( $row = $result->fetch_assoc() )
  {
    $last_loss   = $row['last_loss'];
    $match_id    = $row['match_id'];
    $match_start = $row['match_start'];
    $fbid        = $row['fbid'];
    $username    = $row['username'];
    $alias       = $row['alias'];
    if( isset($last_loss) && isset($match_start) && isset($match_id) )
    {
      $match = array(
        'match_id' => $match_id, 
        'last_loss' => $last_loss, 
        'match_start' => $match_start 
      );

      if( isset($fbid) ) { 
        $match['fbid'] = $fbid;
        $matches[] = $match;
      }
      elseif( isset($alias) )
      {
        $match['name'] = $alias;
        $matches[] = $match;
      }
      elseif( isset($username) )
      {
        $match['name'] = $username;
        $matches[] = $match;
      }
    }
  }
}

send_success( array( 'matches' => $matches ) );

?>