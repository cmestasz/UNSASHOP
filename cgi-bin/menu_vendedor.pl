#!perl/bin/perl.exe

# Recibe: action (check [retorna todas las tiendas], edit [modifica cualquier valor de la tienda], delete [borra la tienda])
#           check => nada
#           edit => id, name, description, open (1 o 0)
#           delete => id
# Retorna: check => <shops> <shop> <id>id</id> <name>nombre</name> <description>descripcion</description> <open>1 o 0</open> </shop> </shops>
#           edit => <errors> <error> <element>elemento</element> <message>mensaje de error</message> </error> </errors>
#           delete => nada
# Check se deberia llamar al cargar la pagina para mostrar todas las tiendas
# Si errors tiene 0 hijos, todo correcto. Si no se deberia imprimir cada error independientemente

use strict;
use warnings;
use CGI;
use CGI::Session;
use CGI::Cookie;
use DBI;

my $cgi = CGI->new;
$cgi->charset("UTF-8");
my $action = $cgi->param("action")

my %cookies = CGI::Cookie->fetch();
my $session_cookie = $cookies{"id_session_vendedor"};

my $db_user = "unsashop";
my $db_password = "c!YxWLaRyvODyTWr";
my $dsn = "dbi:mysql:database=unsashop;host=127.0.0.1";
my $dbh = DBI->connect($dsn, $db_user, $db_password);


if ($session_cookie) {
    my $session_id = $session_cookie->value();
    my $session = CGI::Session->load($session_id);
    my $seller_id = $session->param("session_id");

    if ($action eq "check") {
        my $sth = $dbh->prepare("SELECT `id`, `nombre`, `descripcion`, `abierto` FROM tienda WHERE vendedor_id = '$seller_id'");
        $sth->execute();
        print_shops($sth);
    } elsif ($action eq "edit") {
        my $id = $cgi->param("id");
        my $name = $cgi->param("name");
        my $description = $cgi->param("description");
        my $open = $cgi->param("open");

        my %errors;
        if ($name && (length($name) == 0 || length($name) > 30)) {
            $errors{name} = "Nombre invalido."
        }
        if ($description && (length($description) == 0 || length($description) > 60)) {
            $errors{description} = "Descripcion invalida."
        }
        if ($open && ($open ne "0" && $open ne "1")) {
            $errors{open} = "Estado invalido."
        }

        edit_shop();
    } elsif ($action eq "delete") {
        my $id = $cgi->param("id");
        my $sth = $dbh->prepare("DELETE FROM tienda WHERE id = '$id'");
        $sth->execute();
    }
}

sub print_shops {
    print "<shops>\n";
    while (my @row = $_[0]->fetchrow_array) {
        print<<XML;
        <shop>
            <id>$row[0]</id>
            <name>$row[1]</name>
            <description>$row[2]</row>
            <open>$row[3]</open>
        </shop>
XML
    }
    print "</shops>\n"
}

sub edit_shop {
    if (%errors == 0) {
        if ($name || $description || $open) {
            my $query = "UPDATE tienda SET ";
            if ($name) {
                $query = $query."name = '$name' ";
            }
            if ($description) {
                $query = $query."description = '$description' ";
            }
            if ($open) {
                $query = $query."open = '$open' ";
            }
            $query = $query."WHERE id = '$id'"
            my $sth = $dbh->prepare($query);
            $sth->execute;

            return;
        }
        $errors{edit} = "No ha cambiado nada.";
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

