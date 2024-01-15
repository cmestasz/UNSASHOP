#!perl/bin/perl.exe

# Recibe: name, description
# Retorna: <errors> <error> <element>elemento</element> <message>mensaje de error</message> </error> </errors>
# Si errors tiene 0 hijos, todo correcto. Si no se deberia imprimir cada error independientemente

use strict;
use warnings;
use CGI;
use CGI::Session;
use CGI::Cookie;
use DBI;

my $cgi = CGI->new;
$cgi->charset("UTF-8");
my $name = $cgi->param("name");
my $description = $cgi->param("description");

my %cookies = CGI::Cookie->fetch();
my $session_cookie = $cookies{"id_session_vendedor"};

my $db_user = "unsashop";
my $db_password = "c!YxWLaRyvODyTWr";
my $dsn = "dbi:mysql:database=unsashop;host=127.0.0.1";
my $dbh = DBI->connect($dsn, $db_user, $db_password);

if ($session_cookie) {
    my $session_id = $session_cookie->value();
    my $session = CGI::Session->load($session_id);
    my $id = $session->param("session_id");
    
    my %errors;
    if (!$name || length($name) == 0 || length($name) > 30) {
        $errors{name} = "Nombre invalido.";
    }
    if (!$description || length($description) == 0 || length($description) > 30) {
        $errors{description} = "Descripcion invalida.";
    }

    register();
}

sub register {
    print $cgi->header("text/xml");
    if (%errors == 0) {
        my $sth = $dbh->prepare("INSERT INTO tienda (`nombre`, `descripcion`, `vendedor_id`, `abierto`) VALUES ('$name', '$description', '$id', 1)");
        $sth->execute;
        
        return;
    }
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
