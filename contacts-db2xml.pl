#!/usr/bin/env perl
use warnings;
use strict;
use DBI;
use XML::Generator;

# The general strategy I'm going to take will be:
#
# * Create a hash that has a list for each of the 26 letters of the alphabet.
#   In each of those lists, I'll store a generated XML node that contains the
#   contacts' info.
# * Read the contacts' first and last name from the database
# * Loop over each record from the database. For each record, get the
#   appropriate list from the hash based on the contact's last name, and add
#   an XML::Generator node to that list.
# * For each letter/list pair in the hash
#   * If there are no entries in the list, just skip it
#   * Open a file based on that letter
#   * Print the contacts to the file
#   * Close the file

# Just prepare my SQL statement
my $select = <<SELECT;
  SELECT person.FirstName
       , person.LastName
    FROM Person.Person person
ORDER BY person.LastName
SELECT

# Create a hash that has a list for each of the 26 letters of the alphabet.
# In each of those lists, I'll store a generated XML node that contains the
# contacts' info.
my $contacts_ref;
for my $letter ('A' .. 'Z') {
  $contacts_ref->{$letter} = [];
}

my $generator = XML::Generator->new(':pretty');

# Read the contacts' first and last name from the database
print("Getting contacts from the database...\n");
my $dbh = DBI->connect("dbi:ODBC:DSN=AdventureWorks") or die(DBI->errstr);
my $sth = $dbh->prepare($select) or die($dbh->errstr);
$sth->execute() or die($sth->errstr);

print("Processing records...\n");
# Loop over each record from the database.
while (my $row_ref = $sth->fetchrow_arrayref) {
  # Get the first and last names from the row
  my ($first_name, $last_name) = @$row_ref;

  # Upper case the first letter of the last name
  my $last_name_initial = uc(substr($last_name, 0, 1));

  # Get the appropriate list from the hash
  my $contact_ref = $contacts_ref->{$last_name_initial};

  # Push a new XML::Generator node into the list
  push(@$contact_ref, $generator->contact({
    "firstName" => $first_name,
    "lastName" => $last_name
  }));
}

print("Writing files...\n");
# For each letter/list pair in the hash
while (my ($initial, $contact_ref) = each(%$contacts_ref)) {
  # If there are no entries in the list, just skip it
  next unless scalar(@$contact_ref);
  print("\t./output/$initial.xml\n");

  # Open a file based on that letter
  open(my $fh, '>', "output/$initial.xml");

  # Print the contacts to the file
  print($fh $generator->contacts(@$contact_ref));

  # Close the file
  close($fh);
}
