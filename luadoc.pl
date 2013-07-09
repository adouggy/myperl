#!/usr/bin/perl -w

######################################################
#
# this script is for batch parsing java file with 
# documentation language to lua api and docs and 
# compress to the exectution environment for LDT plugin.
#
# @Author Ade Li.
# @Date 2013/6/25
#
######################################################

use strict;
use warnings;
use 5.010;
use Archive::Zip;

#for input file and middle lua file
my $inputFolderName = 'java';
my $outputFolderName = 'lua';
my $res;
my $status;
my $apiZipFile = 'api.zip';
my @eeFiles = ('myplugin.rockspec', 'docs', $apiZipFile);

######################################################
# clean up
######################################################
&cleanup();


#####################################################
# 
# read and parse java file
#
######################################################
say "dealing java files to lua docs";

my @filelist = &openFolder($inputFolderName);
for my $file (@filelist){
	say 'parsing ..' . $file;
	#load input file into memory
	my $fileContent = &readFile('./java/' . $file);
	my $outputFileName;
	if( $file =~ /(.*)\.java/i ){
		$outputFileName = $1 . '.lua';
	}

	#parse java file, find out java comment and output to middle lua file
	open ( my $outputfh, '>', './lua/'.$outputFileName ) or die print $!;
	while( $fileContent =~ /\/\*\*(.*?)\*\//sg ){
		#print $1;
		print $outputfh $1;
	}
}

	######################################################
	#
	# using lua documentor to generate api and docs
	#
	######################################################
	say 'Prepare to use lua documentor ..';
	say 'for api:';
	$res = `sudo lua -lluarocks.require ./luadocumentor/luadocumentor.lua -f api -d . ./lua`;
	say $res;
	say 'for doc:';
	$res = `sudo lua -lluarocks.require ./luadocumentor/luadocumentor.lua -f doc -d ./docs ./lua`;
	say $res;

	

######################################################
#
# zip lua files
#
######################################################
my @files = &openFolder('./');
my @luaFiles;
for( @files ){
	if(-e $_ and $_ =~ /.*\.lua$/){
		push @luaFiles, $_;
	}
}
&zipAll(\@luaFiles, 'api.zip');

######################################################
#
# zip all for Execution Environment
#
######################################################
&zipAll(\@eeFiles, 'myplugin.zip');

######################################################
# clean up
######################################################
#&cleanup();

######################################################
# functions
######################################################
sub zipAll{
	my ($fromFilesRef, $toFile) = @_;
	my $status;

	say 'Prepare to zip files:';	
	my $obj = Archive::Zip->new();
	for(@$fromFilesRef) {
		if( -e -d $_ ){ #if its a folder, just simple add its files and this folder.
			$status = $obj->addDirectory($_);
			say 'Add folder:' . $_;
			opendir DIR, $_ or die "Can not open $_" . $!;
    		my @filelist = grep { $_ ne '.' and $_ ne '..' } readdir DIR;
    		for my $f ( @filelist ){
    			$f = $_ . '/' . $f;
    			$status = $obj->addFile($f);
				say 'Add file' . $f ;
    		}
		}elsif( -e $_ ){
			$status = $obj->addFile($_);
			say 'Add file' . $_ ;#. " status:" . $status;
		}
	}
	say 'creating file:' . $toFile;
	$status = $obj->writeToFileNamed($toFile);
	say 'Zip status:' . $status;
}

sub cleanup{
	say 'clean up..';
	my $res;
	$res = `rm -rf *.zip`;
	$res = `rm -rf ./api`;
	$res = `rm -rf ./docs`;
	$res = `rm -rf ./myplugin`;
	$res = `rm -rf *.lua`;
}

sub readFile{
	my ($inputFileName) = @_;
	open ( my $fh, '<', $inputFileName ) or die print "can\'t read file $inputFileName" . $!;
	my $fileContent;
	while( <$fh> ){
		#print $_;
		$fileContent .= $_;
	}
	return $fileContent;
}

sub openFolder{
	my ($inputFolderName) = @_;
	opendir DIR, $inputFolderName or die "Can not open $_" . $!;
	my @filelist = grep { $_ ne '.' and $_ ne '..' } readdir DIR;
	return @filelist;
}
