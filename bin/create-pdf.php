<?php

include 'vendor/autoload.php';

use LineConverter\LineConverter;

while ($line = fgets(STDIN)) {
  print LineConverter::convertLine($line);
}
