# Second Hand Book Finder

A Ruby script to find secondhand copies of the books in your [Goodreads](https://www.goodreads.com/) shelves. 

Currently queries [eBay](www.ebay.com).

## Setup
- Goodreads API
  - Register for a developer key on the [Goodreads API Website](https://www.goodreads.com/api). 
  - create a folder `keys/`, and inside create 2 text files called `api_key.txt` and `api_secret_key.txt`.
  - From your Goodreads developer profile, copy your API key into `keys/api_key.txt`, and your secret key into `keys/api_secret_key.txt`. 

- Script
  - Run `bundle install` to install the required gems. 
 
## Usage

Run `ruby client.rb` to run the script.

On the first run, you will have to authenticate the script. 

To do that, follow the link the script outputs to the terminal and login to Goodreads. 

This authenticates the application, and the unique credentials are stored so the application can re-authenticate itself on subsequent runs. 

## Output
The application outputs a list of all titles it has found on eBay that are under a certain price threshold ($15 by default) and the corresponding link to the listing. 
You can adjust the price threshold by editing line 80 of client.rb.

After the first run of the script, the application will also make a note of all the titles it has found. If new titles are found on subsequent runs, this will be detected and the terminal output will make special note of these new titles. 
