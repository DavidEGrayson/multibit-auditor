Multibit auditor
====

This is a Ruby program that can read the private key files exported by
[Multibit](https://multibit.org/) (a Bitcoin wallet) and tell you what Bitcoin
addresses they correspond to.

Installation
====

1. Install [Ruby](http://www.ruby-lang.org/).
2. Download this repository or clone it to your computer using git.
3. Run the following command to install the ecdsa gem:
        
        gem install ecdsa
        
4. The ecdsa gem is served from [Rubygems.org](http://rubygems.org).  In case
   the server or your connection to it has been compromised, you might want to
   briefly scan over the Ruby code for the gem.  It will be in a "gems"
   directory somewhere on your computer.

Usage
====

1. In Multibit, select "Tools > Export Private Keys".
2. Select "Do not password protect export file".
3. Click "Export Private Keys".
4. Run the following command:
        
        ruby audit.rb <path to exported private key file>


This program prints out the bitcoin addresses corresponding to the private keys in the file.


Possible future improvements
====

* Add a script for fetching the balance in each address using the [blockchain.info API](https://blockchain.info/address/16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM?format=json).
* Add the ability to decrypt password-protected export files.
* Add the ability to read multibit wallet files (files with the .wallet extension).
