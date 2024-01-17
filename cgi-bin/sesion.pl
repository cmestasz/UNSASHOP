#!perl/bin/perl.exe

# Recibe: action (check [revisa si la sesion esta abierta] o close [cierra la sesion]), type (usuario o vendedor)
# Retorna: <status> <logged_in>1 o 0</logged_in> <name>nombre(solo si la sesion esta abierta)</name> </status>
# Se deberia llamar al check siempre al cargar cualquier pagina del usuario o del vendedor

use strict;
use warnings;
use CGI;
use CGI::Session;
use CGI::Cookie;

my $cgi = CGI->new;
$cgi->charset("UTF-8");
my $type = $cgi->param("type");
my $action = $cgi->param("action");

my %cookies = CGI::Cookie->fetch();
my $session_cookie = $cookies{"id_session_$type"};

print ($cgi->header("text/xml"));
print "<status>\n";
if ($action eq "check") {
    if ($session_cookie) {
        my $session_id = $session_cookie->value();
        my $session = CGI::Session->load($session_id);
        my $name = $session->param("session_name");
        print "<logged_in>1</logged_in>\n<name>$name</name>\n";
    } else {
        print "<logged_in>0</logged_in>\n";
    }
} elsif ($action eq "close") {
    print "<logged_in>0</logged_in>\n";
    if ($session_cookie) {
        my $session_id = $session_cookie->value();
        my $session = CGI::Session->load($session_id);
        $session_cookie->expires("-1h");
        $session->delete();
        $session->flush();
    }
}
print "</status>";