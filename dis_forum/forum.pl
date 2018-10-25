
$basedir = "/apache/htdocs/cpforum";          	# Path to the dir.
$baseurl = "http://localhost/cpforum";        	# The Url of the dir.
$cgi_url = "http://localhost/cgi-bin/forum.pl"; # The Url to this file.

$mesgdir  = "messages";     # The name of the reply directory.
$imgdir   = "$baseurl/img"; # The Image Directory
$datafile = "data.txt";     # The Data File.
$mesgfile = "forum.html";   # Don't change this if your are a beginner.
$ext      = "html";         # The extension of the files. Usually HTML.
$title    = "Code Project Discussion Forum"; # Title of the Forums.
$return   = "$baseurl/$mesgfile";  # Don't touch this.
#####################################################################
# Configure Options

$allow_html = 1;	# 1 = YES; 0 = NO
$use_time = 1;		# 1 = YES; 0 = NO

$enforce_max_len = 0;   # 2 = YES, error; 1 = YES, truncate; 0 = NO
%max_len = ('name', 50, 
            'email', 70, 
            'subject', 80, 
            'body', 3000,
            'origsubject', 80,
            'origname', 50,
            'origemail', 70,
            'origdate', 50);
######################################################################
&get_number;    # Get the Data Number
&parse_form;    # Get Form Information
&get_variables; # Put items into nice variables
&new_file;      # Creates the Reply Forum.
&main_page;     # Open the Main File to add link
&return_html;   # Redirects
&increment_num; # Increment Number

######################################################################
# Get Data Number Subroutine
sub get_number {
   open(NUMBER,"$basedir/$datafile");
   $num = <NUMBER>;
   close(NUMBER);
 	  if ($num == 999999 || $num !~ /^\d+$/)  {
    		$num = "1";
  	  }
          else {
      		$num++;
          }
}
######################################################################
# Parse Form Subroutine
sub parse_form {

local($name,$value);
read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
@pairs = split(/&/, $buffer);
foreach $pair (@pairs) {
 	($name, $value) = split(/=/, $pair);
        $value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
        $value =~ s/\0//g;
        $value =~ s/<!--(.|\n)*-->//g;

if ($allow_html != 1) { $value =~ s/<([^>]|\n)*>//g; }
else {
     unless ($name eq 'body') {
     $value =~ s/<([^>]|\n)*>//g;
     }
}
$FORM{$name} = $value;
}
# Make sure that message fields do not exceed allowed value
if ($enforce_max_len) {
 foreach $name (keys %max_len) {
    if (length($FORM{$name}) > $max_len{$name}) {
    if ($enforce_max_len == 2) { &error('field_size'); }
    else { $FORM{$name} = sprintf("%.$max_len{$name}s",$FORM{$name}); }
     }
    }
  }
}
######################################################################
# Get Variables
sub get_variables {

if ($FORM{'followup'}) {
   $followup = "1";
   @followup_num = split(/,/,$FORM{'followup'});
   ($myfiru,$mysecu) = split(/,/,$FORM{'followup'});
local(%fcheck);
foreach $fn (@followup_num) {
      if ($fn !~ /^\d+$/ || $fcheck{$fn}) { &error('followup_data'); }
      $fcheck{$fn} = 1;
}

   @followup_num = keys %fcheck;
   $num_followups = @followups = @followup_num;
   $last_message = pop(@followups);
   $origdate = "$FORM{'origdate'}";
   $origname = "$FORM{'origname'}";
   $origsubject = "$FORM{'origsubject'}";
}
else { $followup = "0"; }

if ($FORM{'name'}) {
   $name = "$FORM{'name'}";
   $name =~ s/"//g;
   $name =~ s/<//g;
   $name =~ s/>//g;
   $name =~ s/\&//g;
}

$email = "$FORM{'email'}";
 
if ($FORM{'subject'}) {
   $subject = "$FORM{'subject'}";
   $subject =~ s/\&/\&amp\;/g;
   $subject =~ s/"/\&quot\;/g;
}

if ($FORM{'body'}) {
   $body = "$FORM{'body'}";
   $body =~ s/\cM//g;
   $body =~ s/\n\n/<p>/g;
   $body =~ s/\n/<br>/g;
   $body =~ s/&lt;/</g; 
   $body =~ s/&gt;/>/g; 
   $body =~ s/&quot;/"/g;
}

# Emotion Icons
$confused = "<img align=\"absmiddle\" src=\"$imgdir/icon_confused.gif\">"; 
$cry = "<img align=\"absmiddle\" src=\"$imgdir/icon_cry.gif\">"; 
$happy = "<img align=\"absmiddle\" src=\"$imgdir/icon_happy.gif\">";
$hate = "<img align=\"absmiddle\" src=\"$imgdir/icon_hate.gif\">";
$mad = "<img align=\"absmiddle\" src=\"$imgdir/icon_mad.gif\">"; 

$body =~ s/:confused:/$confused/g;
$body =~ s/:cry:/$cry/g; 
$body =~ s/:happy:/$happy/g; 
$body =~ s/:hate:/$hate/g; 
$body =~ s/:mad:/$mad/g; 

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$month = ($mon + 1);
@months = ("January","February","March","April","May","June","July","August","September","October","November","December");
$year += 1900;
$long_date = sprintf("%s %02d, %4d at %02d:%02d:%02d",$months[$mon],$mday,$year,$hour,$min,$sec);

$year %= 100;
if ($use_time == 1) {
$date = sprintf("%02d:%02d:%02d %02d/%02d/%02d",$hour,$min,$sec,$month,$mday,$year);
}
else { $date = sprintf("%02d/%02d/%02d",$month,$mday,$year); }
}      
######################################################################
# Creating the Reply Forum Routine
sub new_file {

open(NEWFILE,">$basedir/$mesgdir/$num\.$ext") || die $!;

print NEWFILE qq~
<html>
<head>
<title>$subject</title>
<script language="Javascript" src="$baseurl/mouse.js"></script>
<LINK href="$baseurl/global.css" rel="stylesheet" type="text/css">
</head>
<body>
<p>
<table border="0" bgcolor="#99CCFF" cellpadding="1" width="100%" cellspacing="0"><tr><td>
<table border="0" bgcolor="#D5EAFF" cellpadding="0" width="100%" cellspacing="0">
<tr>
<td><font class="newMsg">You are replying to</font>
<a class="newMsg" onMouseover="AL(this)" onMouseout="BL(this)" href="mailto: $email">$name</a></td>
</tr>
<tr>
<td><font class="newMsg">Subject: </font><font class="MsgContent">$subject</font></td>
</tr>
<tr>
<td><font class="newMsg">Message: </font><br><font class="MsgContent">$body</font></td>
</tr></table>
</td></tr></table>
<p>
~;

print NEWFILE qq~
<table border="0" bgcolor="#ffffcc" cellpadding="0" cellspacing="0">
<form method="post" action=\"$cgi_url\" onsubmit="return chkFrm()" name="myform">
~;

print NEWFILE "<input type=\"hidden\" name=\"followup\" value=\"";

if ($followup == 1) {
   foreach $followup_num (@followup_num) {
	   print NEWFILE "$followup_num,";
   }
}
print NEWFILE "$num\">\n";
print NEWFILE "<input type=hidden name=\"origname\" value=\"$name\">\n";

if ($email) {
print NEWFILE "<input type=hidden name=\"origemail\" value=\"$email\">\n";
}

print NEWFILE "<input type=hidden name=\"origsubject\" value=\"$subject\">\n";
print NEWFILE "<input type=hidden name=\"origdate\" value=\"$long_date\">\n";

print NEWFILE qq~
<tr valign="top">
<td>&nbsp;</td>
<td><a class="newMsg" name="postfp">Reply</a></td>
</tr>

<tr valign="top">
<td><font class="newMsg">Name:</font></td>
<td><input type="text" name="name" size="50"></td>
</tr>

<tr valign="top">
<td><font class="newMsg">E-mail:</font></td>
<td><input type="text" name="email" size="50"></td>
</tr>

<tr valign="top">
<td><font class="newMsg">Subject:</font></td>
<td><input type="text" name="subject" size="50" value="$subject"></td>
</tr>

<tr valign="top">
<td><font class="newMsg">Message:</font></td>
<td><textarea cols="49" rows="9" name="body"></textarea></td>
</tr>

<tr valign="top">
<td><font class="newMsg">Emotion Icons:</font></td>
<td>&nbsp;
<img src="$imgdir/icon_confused.gif" onClick="eConf()">
<img src="$imgdir/icon_cry.gif" onClick="eCry()">
<img src="$imgdir/icon_happy.gif" onClick="eHappy()">
<img src="$imgdir/icon_hate.gif" onClick="eHate()">
<img src="$imgdir/icon_mad.gif" onClick="eMad()"></td>
</tr>

<tr valign="top">
<td>&nbsp;</td>
<td>&nbsp;</td>
</tr>

<tr valign="top">
<td>&nbsp;</td>
<td><input type="submit" value="Post Message"> <input type="reset" value="Reset"></td>
</tr>
</form></table>
<p>
~;
print NEWFILE qq~ 
<center>[ <a onMouseover="AL(this)" onMouseout="BL(this)" class="newMsg" href="$baseurl/$mesgfile">$title</a> ]</center>
~;
print NEWFILE "</body></html>\n";
close(NEWFILE);
}
######################################################################
# Main WWWBoard Page Subroutine

sub main_page {
 
   open (MAIN,"$basedir/$mesgfile") || die $!;
   @LINES=<MAIN>;
   chomp (@LINES);
   close(MAIN);
   $SIZE=@LINES;

$dblx = "xx";
$ap = "$num";
$pa = "_h1";
$pp = "_h0";
$fx = "#";
$sff = "$return$fx$dblx$num$dblx";

$tmpVar = "&nbsp;&nbsp;&nbsp;&nbsp;";
open (MAIN,">$basedir/$mesgfile") || die $!;
for ($v=0;$v<=$SIZE;$v++) {
   $_=$LINES[$v];
   print MAIN "$_\n";
   if (($followup == 0) && (/<!--begin-->/)) {
    	print MAIN qq~<tr bgcolor="#FEF9E7" id="$ap$pp">
<td width="50%">
<table border="0" cellpadding="0" cellspacing="0" width="100%"><tr><td width="4%" bgcolor="#fef9e7"><a name="$dblx$num$dblx"></a>~;
print MAIN qq~
<img align="absmiddle" src="$imgdir/news_un.gif"></td>
<td width="100%"> <a onMouseover="AL(this)" onMouseOut="BL(this)" href="$sff" id="DynMessLink" name="$num" class="newMsg"><b>$subject</b></a>
</td></tr></table></td><td width="30%"><a onMouseover="AL(this)" onMouseOut="BL(this)" href="mailto: $email" class="newMsg">
$name</a></td><td nowrap align="right" width="20%">
<font class="newMsg"><b>$date</b></font></td></tr>

<tr id="$ap$pa" style="display:none"><td colspan="4" width="100%">
<table border="0" cellspacing="0" cellpadding="0" width="100%" bgcolor="#ffffff">
<tr><td width="2%" bgcolor="#FEF9E7"></td><td bgcolor="#D5EAFF" width="100%" colspan="2">
<font class="Msgcontent">$body<p>
<a onMouseover="AL(this)" onMouseOut="BL(this)" href="$baseurl/$mesgdir/$num.$ext">
<font face="Verdana, Arial, Helvetica, Sans-Serif" size="2" color="#0000FF" style="font-size: 9pt">
[Reply]</font></a><br></table></td></tr>
	<!--insert: $num-->
	~;
   }
   elsif ($myfiru = /<!--insert: $last_message-->/) {
    	print MAIN qq~<tr bgcolor="#FEF9E7" id="$ap$pp">
<td width="50%">
<table border="0" cellpadding="0" cellspacing="0" width="100%"><tr><td width="10%" bgcolor="#fef9e7">$tmpVar<a name="$dblx$num$dblx"></a>~;
print MAIN qq~
<img align="absmiddle" src="$imgdir/news_un.gif"></td>
<td width="100%"> <a onMouseover="AL(this)" onMouseOut="BL(this)" href="$sff" id="DynMessLink" name="$num" class="newMsg"><b>$subject</b></a>
</td></tr></table></td><td width="30%"><a onMouseover="AL(this)" onMouseOut="BL(this)" href="mailto: $email" class="newMsg">
$name</a></td><td nowrap align="right" width="20%">
<font class="newMsg"><b>$date</b></font></td></tr>

<tr id="$ap$pa" style="display:none"><td colspan="4" width="100%">
<table border="0" cellspacing="0" cellpadding="0" width="100%" bgcolor="#ffffff">
<tr><td width="5%" bgcolor="#FEF9E7"></td><td bgcolor="#D5EAFF" width="100%" colspan="2">
<font class="Msgcontent">$body<p>
<a onMouseover="AL(this)" onMouseOut="BL(this)" href="$baseurl/$mesgdir/$num.$ext">
<font face="Verdana, Arial, Helvetica, Sans-Serif" size="2" color="#0000FF" style="font-size: 9pt">
[Reply]</font></a><br></table></td></tr>
	<!--insert: $num-->
	~;
   }
}
close (MAIN); 
}
######################################################################
sub return_html {
print "Location: $return\n\n";
}
######################################################################
sub increment_num {
   open(NUM,">$basedir/$datafile") || die $!;
   print NUM "$num";
   close(NUM);
}
################## END OF SCRIPT #####################################
