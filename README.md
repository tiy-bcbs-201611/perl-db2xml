# Lab for Week 4
## Create some XML from a database query

I will take the following strategy to get my solution to work:

* Create a hash that has a list for each of the 26 letters of the alphabet.
  In each of those lists, I'll store a generated XML node that contains the
  contacts' info.
* Read the contacts' first and last name from the database
* Loop over each record from the database. For each record, get the
  appropriate list from the hash based on the contact's last name, and add
  an XML::Generator node to that list.
* For each letter/list pair in the hash
  * If there are no entries in the list, just skip it
  * Open a file based on that letter
  * Print the contacts to the file
  * Close the file
