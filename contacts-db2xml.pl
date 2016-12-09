#!/usr/bin/env perl
use warnings;
use strict;
use DBI;
use XML::Generator;

my $select = <<SELECT;
  SELECT person.FirstName
       , person.LastName
    FROM Person.Person person
ORDER BY person.LastName
SELECT

my $contacts_ref;
for my $letter ('A' .. 'Z') {
  $contacts_ref->{$letter} = [];
}

my $generator = XML::Generator->new(':pretty');

my $dbh = DBI->connect("dbi:ODBC:DSN=AdventureWorks") or die(DBI->errstr);
my $sth = $dbh->prepare($select) or die($dbh->errstr);
$sth->execute() or die($sth->errstr);

while (my $row_ref = $sth->fetchrow_arrayref) {
  my ($first_name, $last_name) = @$row_ref;
  my $last_name_initial = uc(substr($last_name, 0, 1));
  my $contact_ref = $contacts_ref->{$last_name_initial};
  push(@$contact_ref, $generator->contact({"firstName" => $first_name, "lastName" => $last_name}));
}

while (my ($initial, $contact_ref) = each(%$contacts_ref)) {
  next unless scalar(@$contact_ref);
  open(my $fh, '>', "output/$initial.xml");
  print($fh $generator->contacts(@$contact_ref));
  close($fh);
}
