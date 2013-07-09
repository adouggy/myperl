#!/usr/bin/perl -w

######################################################
#
# After created your own .apk file, 
# we need to run it again and again,
# belowing script is for such purpose
#
# @Author Ade Li.
# @Date 2013/7/9
#
######################################################

use strict;
use warnings;
use 5.010;

my $caseNumberFrom = 0; # test case start
my $caseNumberTo = 3;   # test case end
my $idx; #indicate current project index
my $now; #indicate current directory
chomp ( $now = `pwd`);

#make sure emulator is running...
#android create avd -n blah_api_16 -t android-16 -b armeabi-v7a
#android list avd
#emulator @blah_api_16

#uninstall old and install new
chdir $now;
$idx = $caseNumberFrom;
for( $caseNumberFrom .. $caseNumberTo ){
	say "uninstall old and install new for $idx:";
	say `adb uninstall net.synergyinfosys.xmppclient_test_$idx`;
	say `adb install project_$idx.apk `;

	$idx ++;
}