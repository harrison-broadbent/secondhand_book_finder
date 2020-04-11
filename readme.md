# Second Hand Book Finder

A Ruby script to find secondhand copies of the books in your [Goodreads](https://www.goodreads.com/) shelves. 

Currently queries [Brotherhood Books](http://brotherhoodbooks.org.au/).

IN-PROGRESS: eBay

## Setup
- Goodreads API
  - Register for a developer key on the [Goodreads API Website](https://www.goodreads.com/api). 
  - create a folder `keys/`, and inside create 2 text files called `api_key.txt` and `api_secret_key.txt`.
  - From your Goodreads developer profile, copy your API key into `api_key.txt`, and your secret key into `api_secret_key.txt`. 

- Script
  - Run `bundle install` to install the required gems. 
 
## Usage
On the first run, you will have to authenticate the script. 

To do that, follow the link the script outputs to the terminal and login to Goodreads. 

This authenticates the application, and the unique credentials are stored so the application can re-authenticate itself on subsequent runs. 

## Output
The application outputs a list of titles it has matched online. 

There are quite a few false positives as we use a simple naïve text inclusion check to determine if the title is available, however, the number of false negatives seems to be low based on some manual investigation. 
