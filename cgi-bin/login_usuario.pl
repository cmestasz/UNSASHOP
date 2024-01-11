#!perl/bin/perl.exe

use strict;
use warnings;
use CGI;
use CGI::Session;
use CGI::Cookie;
use DBI;

my $cgi = CGI->new;
$cgi->charset("UTF-8");
my $db_user = "unsashop";
my $db_password = "c!YxWLaRyvODyTWr";
my $dsn = "dbi:mysql:database=unsashop;host=127.0.0.1";
my $dbh = DBI->connect($dsn, $db_user, $db_password);

my $user = $cgi->param("user");
my $password = $cgi->param("password");
my $session_time = 86400;

my $sth = $dbh->prepare("SELECT id FROM usuario WHERE login_usuario=? AND login_contrasena=?");
$sth->execute($user, $password);

print $cgi->header("text/xml");
print "<status>";

my @user_row = $sth->fetchrow_array;
if (@user_row) {
    my $session = CGI::Session->new();
    $session->param("user_id", $user_row[0]);
    $session->expire(time + $session_time);
    $session->flush();

    my $cookie = $cgi->cookie(-name => "user_session_id",
                            -value => $session->id(),
                            -expires => time + $session_time,
                            "-max-age" => time + $session_time);
    $cookie->bake();

    print "correct";
} else {
    print "wrong";
}

print "</status>"