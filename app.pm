use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';

use Cwd qw/ abs_path /;
use File::Basename qw/ dirname /;

use lib dirname(dirname abs_path $0);
use ForeignWords::CLI qw/ cli_main /;

cli_main();
