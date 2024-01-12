#!perl/bin/perl.exe

# Recibe: user, password, type (usuario o vendedor)
# Retorna: [status => correct/incorrect]
# Obs: Crea una sesion que guarda el id del usuario/vendedor y una cookie que guarda la sesion

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
my $type = $cgi->param("type");
my $session_time = 86400;

login();

sub login {
    if ($user && length($user) != 0 && $password && length($password) != 0 && $type && ($type eq "usuario" || $type eq "vendedor")) {
        my $sth = $dbh->prepare("SELECT id FROM $type WHERE login_usuario = '$user' AND login_clave = '$password'");
        $sth->execute();

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

            print $cgi->header("text/xml", -cookie=>$cookie);
            print "<status>correct</status>\n";
            return;
        }
    }
    print $cgi->header("text/xml");
    print "<status>incorrect</status>\n";
}

