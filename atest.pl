#!/usr/bin/perl -w

######################################################
#
# for auto generate .apk file with different package 
# name, install to emulator and run from instrument.
#
# @Author Ade Li.
# @Date 2013/7/2
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
my $projectPath = '/Users/ade/Documents/workspace/XmppClient';
my $projectPrefix = 'project_';
my $packagePath = 'net/synergyinfosys/xmppclient';
my $package = 'net.synergyinfosys.xmppclient';

#0, clean workspace
say 'Clean proto project first!';
chdir $projectPath;
say `ant clean`;
chdir $now;



#clean old copied project
say 'Deleting old projects';
`rm -rf project_*`;

#copy project
say 'Copy total:' . ($caseNumberTo-$caseNumberFrom+1) . ' projects';
$idx = $caseNumberFrom;
for( $caseNumberFrom .. $caseNumberTo ){
	say 'No.' . $idx;
	my $p = 'project_'. $_;
	`mkdir $p`;
	`cp -rf $projectPath/* ./$p`;
	$idx ++;
}


#change package name for each project
$idx = $caseNumberFrom;
for( $caseNumberFrom .. $caseNumberTo ){
	chdir $now;
	say "dealing with $projectPrefix$idx";
	chdir $projectPrefix . $idx;
	my $newPackage = "test_$idx";

	#modify AndroidManifest.xml first
	&replaceAFile( 'AndroidManifest.xml', "package=\"$package\"", "package=\"$package". '_' . "$newPackage\""  );

 	#change android manifest app name
    #@string/app_name
    &replaceAFile( 'AndroidManifest.xml', "@string/app_name", "Test_$idx"  );

	#modify all java file which referenced R.java
	opendir DIR, 'src/'.$packagePath or die "Can not open 'src/$packagePath" . $!;
    my @filelist = grep { $_ ne '.' and $_ ne '..' and $_ ne 'test' } readdir DIR;
    for my $f ( @filelist ){
    	say 'parsing '. $f;
    	&replaceAFile( 'src/'.$packagePath.'/'.$f, "$package.R", "$package" . '_' . "$newPackage.R"  );
    }

    opendir DIR, 'src/'.$packagePath.'/test' or die "Can not open 'src/$packagePath/test" . $!;
    my @filelist = grep { $_ ne '.' and $_ ne '..' } readdir DIR;
    for my $f ( @filelist ){
    	say 'parsing '. $f;
    	&replaceAFile( 'src/'.$packagePath.'/test/'.$f, "$package.R", "$package" . '_' . "$newPackage.R"  );
    }

    #modify xmpp login name and password
	opendir DIR, 'src/'.$packagePath.'/test' or die "Can not open src/$packagePath/test" . $!;
     @filelist = grep { $_ ne '.' and $_ ne '..' } readdir DIR;
    for my $f ( @filelist ){
    	say 'parsing '. $f;
    	&replaceAFile( 'src/'.$packagePath.'/test/'.$f, "login_name_need_to_be_replace", "test_$idx"  );
    }

	$idx ++;
}


#compile
chdir $now;
$idx = $caseNumberFrom;
for( $caseNumberFrom .. $caseNumberTo ){
	chdir $now;
	say "compiling $projectPrefix$idx";
	chdir $projectPrefix . $idx;

	say `ant release`;

	$idx ++;
}


#copy all apk out
chdir $now;
$idx = $caseNumberFrom;
for( $caseNumberFrom .. $caseNumberTo ){
	chdir $now;
	say "copying .apk from $projectPrefix$idx";
	say `mv ./$projectPrefix$idx/bin/XmppClient-release.apk ./$projectPrefix$idx.apk`;
	$idx ++;
}


=xxx
#uninstall old and install new
chdir $now;
$idx = $caseNumberFrom;
for( $caseNumberFrom .. $caseNumberTo ){
	say "uninstall old and install new for $idx:";
	say `adb uninstall net.synergyinfosys.xmppclient_test_$idx`;
	say `adb install project_$idx.apk `;

	$idx ++;
}



#run! forest run...
chdir $now;
$idx = $caseNumberFrom;
for( $caseNumberFrom .. $caseNumberTo ){
	say "running.. asynchronized....running...";
	my $cmd = "adb shell am instrument -w net.synergyinfosys.xmppclient_test_$idx/android.test.InstrumentationTestRunner";

	system "$cmd &";
	$idx ++;
}
=cut

############################################################################################################################################
sub replaceAFile {
	my ($filename, $re, $to) = @_;
	open my $fh, '<', $filename or die "can't open file: $filename, $!";
	my $content;
	while( <$fh> ){
		if( s/$re/$to/ ){
			say "replaced $to -> $re";
		}
		$content .= $_;
	}
	open my $out, '>', $filename or die "can't open file: $filename, $!";
	print $out $content;
}

