#!perl/bin/perl.exe

# Recibe: user, password, type (usuario o vendedor), name, card_number, card_expire, card_code
# Retorna: [status => correct/incorrect]
# Obs: Crea una sesion que guarda el id del usuario/vendedor y una cookie que guarda la sesion

use strict;
use warnings;
use CGI;
use CGI::Session;
use CGI::Cookie;
use DBI;
use DateTime;

my $cgi = CGI->new;
$cgi->charset("UTF-8");
my $db_user = "unsashop";
my $db_password = "c!YxWLaRyvODyTWr";
my $dsn = "dbi:mysql:database=unsashop;host=127.0.0.1";
my $dbh = DBI->connect($dsn, $db_user, $db_password);

my $user = $cgi->param("user");
my $password = $cgi->param("password");
my $type = $cgi->param("type");
my $name = $cgi->param("name");
my $card_number = $cgi->param("card_number");
my $card_expire = $cgi->param("card_expire");
my $card_code = $cgi->param("card_code");

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
if (!$name || length($name) == 0) {
    $errors{name} = "Nombre invalido."
}
if (!$card_number || length($card_number) != 16) {
    $errors{card_number} = "Número de tarjeta invalido."
}
if (!$card_expire || DateTime->now > $card_expire) {
    $errors{card_expire} = "Fecha de expiración invalida."
}
if (!$card_code || length($card_code) != 3) {
    $errors{card_code} = "Código de seguridad invalido."
}

register();

sub register {
    print $cgi->header("text/xml");
    if (%errors == 0) {
        my $sth = $dbh->prepare("SELECT id FROM tarjeta WHERE numero = '$card_number' AND caducidad = '$card_expire' AND codigo = '$card_code'");
        $sth->execute();

        my @user_row = $sth->fetchrow_array;
        if (@user_row) {
            $sth = $dbh->prepare("INSERT INTO $type ('login_usuario', 'login_clave', 'nombre', 'tarjeta_id') VALUES ('$user', '$password', '$name', '$user_row[0]')");
            $sth->execute();
            return;
        }

        $errors{login} = "La tarjeta no existe."
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
