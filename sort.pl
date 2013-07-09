#!/usr/bin/perl

undef $/;
$txt=<IN>;
  
$txt=~s/^(\d+)(.+?)^(?!\1)/$1$2\n/smg;
  
print OUT  $txt; 
