# Brocade

Brocade generates barcodes for Rails ActiveRecord models.

I extracted this from one of my projects and, although the code is nice and extensible, right now it only does what I need in that project.  So for example it could produce barcodes in any symbology -- but currently only does Code 128.

There are two parts to Brocade: barcode generation and file management (because the barcodes are saved as image files).  I use [Barby][barby] to generate the barcodes and code copied from [Paperclip][paperclip] to manage the files.


## Features

* No configuration necessary...or possible ;)
* Supports Code 128 symbology.  Could support any symbology.
* Generates barcode images as PNGs via ImageMagick.  Could support other output formats.
* Stores barcode images on disk.  Could support other storage.


## Basic Usage

Brocade is simple to use:

    class Item < ActiveRecord::Base
      has_barcode

      def barcodable
        :serial_number
      end
    end

First declare declare your model `has_barcode`.  Second override the `barcodable` method to return the name of the method Brocade should call to get the data to barcode.

Now you get this:

    >> item = Item.create :serial_number => 42, :name => 'Deep Thought'
    # writes barcode to /path/to/your/app/public/system/barcodes/items/3615/code128.png

-- assuming `item`'s id is 3615.

    >> item.update_attributes :name => 'Deeper Thought'
    # no change to barcode

    >> item.update_attributes :serial_number => 153
    # writes barcode to /path/to/your/app/public/system/barcodes/items/3615/code128.png
    # i.e. writes out a new barcode image over the top of the original one

    >> item.barcode_path
    # => "/path/to/your/app/public/system/barcodes/items/3615/code128.png"

    >> item.barcode_url
    # => "/system/barcodes/items/3615/code128.png"

    >> item.destroy
    # deletes barcode image.


## Installation.

Install as a gem.  In your `config.rb`:

    config.gem 'brocade'


## Dependencies

The [Barby][barby] and [PNG][png] gems, and ImageMagick.


## Problems

Please use GitHub's [issue tracker](http://github.com/airblade/brocade/issues).


## To do

* Tests.  Yes, yes, I know.
* Configurable way to specify data to be barcoded.
* Configurable symbology.
* Multiple symbologies per model.
* Configurable file path and URL.
* Other outputters.
* Other storage.


## Further reading

* [Barcode Basics](http://www.barcodediscount.com/solutions/library/barcode_basics.htm)
* [Barcode Online Reference](http://www.teklynx.com/barcodes/article_1.html)


## Inspiration

* [Barby][barby]
* [Paperclip][paperclip]


## Intellectual Property

Copyright (c) 2010 Andy Stewart. See LICENSE for details.


  [barby]: http://github.com/toretore/barby
  [paperclip]: http://github.com/thoughtbot/paperclip
  [png]: http://seattlerb.rubyforge.org/png/
