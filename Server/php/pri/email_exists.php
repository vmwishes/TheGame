<?php

require_once(__DIR__.'/const.php');
require_once(__DIR__.'/util.php');
require_once(__DIR__.'/db_find_user.php');

$email = get_required_arg(EMAIL);
fail_on_extra_args();

$info = db_find_user_by_email($email);
if( empty($info) ) { send_failure(INVALID_EMAIL); }

send_success();

?>
