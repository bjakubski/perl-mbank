use inc::Module::Install;

name     'Finance-Bank-mBank';
all_from 'lib/Finance/Bank/mBank.pm';
author   'Bartek Jakubski <b.jakubski@gmail.com>';
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

