**PICA-Modification** is a Perl module to handle modifications on identified
PICA+ records. A simple modification, implemented with package
`PICA::Modification` consists of the following attributes: 

* **add**: stringified PICA+ record with fields to be added

* **del**: comma-separated list of PICA+ field to be removed

* **id**: fully qualified record identifier ` PREFIX:ppn:PPN` (optional)

* **iln**: ILN of a level 1 record to modify (required for modifications that
  include level 1 fields).

* **iln**: EPN of a level 2 record to modify (required for modifications that
  include level 2 fields).

Creation of new records or levels is not supported.  An edit must at least
contain a field to add or a field to delete.

PICA::Modification is extended to `PICA::Modification::Request` which adds the
following attributes:

* **request**: unique identifier of the request

* **creator**: optional string to identify the creator of the request

* **status**: requests's status which is one of 0 for unprocessed, 
  1 for processed or solved, and -1 for failed or rejected

* **created**: timestamp when the request was created

* **updated**: timestamp when the request was last updated or checked

All timestamps are GMT with format `YYYY-MM-DD HH:MM::SS`.

To manage collections of modifications and modification requests, this module
provides the package `PICA::Modification::Queue`.
