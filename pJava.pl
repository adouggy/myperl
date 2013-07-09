#!/usr/bin/perl -w

######################################################
#
# This script it trying to find out java class and functions
#
# @Author Ade Li.
# @Date 2013/7/2
#
######################################################

use strict;
use warnings;
use 5.010;

my $reClass = '
	.*?\s* 					#开头，可能有public/private或者啥都没有
	class\s+				#class关键字
	([^\s]*)\s*				#捕获class的名字
	(?:implements\s+.*?)?	#肯那个会实现点接口
	(?:extends\s+.*?)?		#可能会继承点啥
	\{						#后面跟一个大括号,递归捕获其中的内容
		(
	         (
	         	?: \{ (?-1) \}	#?-1负责捕获嵌套的{}的上一层东东，也就是class的body
	         		|			#the |
	         	[^{}]++			#内容咯...
	         )*
      	)
	\}
	';

my $reFunctions = '
	\w+\s+ 					#访问修饰符
	(?:static\s+)?			#可能会有static
	\w+\s+					#返回值，如果没有，就是构造函数，这里不考虑
	(\w+)\s*				#函数名,捕获
	\(';

my $content = &readFile('./test.java');


while( $content =~ m/$reClass/msgx ){
	chomp (my $className = $1);
	say ">>>>>>>>Class:".$className;

	chomp (my $classBody = $2);
	while( $classBody =~ m/$reFunctions/msgx){
		chomp (my $funName = $1);
		say "\tFunctions:".$funName;
	}

	#这里假设innerClass只有一层嵌套，多层的话就不考虑了
	while( $classBody =~ m/$reClass/msgx ){
		chomp (my $innerClassName = $1);
		say "\t>>>InnerClass:".$innerClassName;
		chomp (my $innerClassBody = $2);
		while( $innerClassBody =~ m/$reFunctions/msgx){
			chomp (my $funName = $1);
			say "\t\tFunctions:".$funName;
		}
	}
}

################################################################################################################
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