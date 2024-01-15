#!perl/bin/perl.exe

# Recibe: user, password, type (usuario o vendedor)
# Retorna: <errors> <error> <element>elemento</element> <message>mensaje de error</message> </error> </errors>
# Si errors tiene 0 hijos, todo correcto. Si no se deberia imprimir cada error independientemente
# Obs: Crea una sesion que guarda el id del usuario/vendedor y una cookie que guarda la sesion

use strict;
use warnings;
use CGI;
use CGI::Session;
use CGI::Cookie;
use DBI;

my $cgi = CGI->new;
$cgi->charset("UTF-8");
my $user = $cgi->param("user");
my $password = $cgi->param("password");
my $type = $cgi->param("type");
my $session_time = 86400;

my $db_user = "unsashop";
my $db_password = "c!YxWLaRyvODyTWr";
my $dsn = "dbi:mysql:database=unsashop;host=127.0.0.1";
my $dbh = DBI->connect($dsn, $db_user, $db_password);

my %errors; 
if (!$user || length($user) == 0) {
    $errors{user} = "Usuario invalido."
}
if (!$password || length($password) == 0) {
    $errors{password} = "Clave invalida."
}
if (!$type || ($type ne "usuario" && $type ne "vendedor")) {
    $errors{type} = "Tipo invalido."
}

login();

sub login {
    if (%errors == 0) {
        my $sth = $dbh->prepare("SELECT `id`, `nombre` FROM $type WHERE login_usuario = '$user' AND login_clave = '$password'");
        $sth->execute();

        my @user_row = $sth->fetchrow_array;
        if (@user_row) {
            my $session = CGI::Session->new();
            $session->param("session_id", $user_row[0]);
            $session->param("session_name", $user_row[1]);
            $session->expire(time + $session_time);
            $session->flush();

            my $cookie = $cgi->cookie(-name => "id_session_$type",
                                    -value => $session->id(),
                                    -expires => time + $session_time,
                                    "-max-age" => time + $session_time);

            print $cgi->header("text/xml", -cookie => $cookie);
            return;
        }
        $errors{login} = "El usuario y la clave no coinciden."
    }
    print $cgi->header("text/xml");
    print_errors();
}

sub print_errors {
    print "<errors>\n";
    for my $key (keys %errors) {
        print<<XML;
        <error>
            <element>$key</element>
            <message>$errors{$key}</message>
        </error>
XML
    }
    print "</errors>\n";
}

