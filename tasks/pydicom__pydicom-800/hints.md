Thanks for pointing this out - I wasn't aware of that section of the standard.  Do you know of a solution that respects the privacy issues pointed out in #125? 

> By not following the DICOM formatting rule, receiving systems that are processing DICOM instances created with this library are not capable of converting the generated “2.25” UID back to a UUID

Why would it be necessary for the receiving software to generate a "real UUID" from this (and therefore the variant and the version)?  Just curious, as if we want to be standard compliant it doesn't really matter.



I think the solution proposed by @cancan101 in #125 to use the uuid v4 algorithm is fine. The uuid v1 algorithm leaks the MAC address. The open source dcm4che (Java) implementation for example also uses the uuid v4 algorithm, the two C# implementation I known of use the .NET Guid.NewGuid() method, which will also returns v4 uuids. 

DICOM is all about interoperability, there may be receiving systems that (implicitly) depend on it. A Level 2 (Full) C-STORE SCP may, (but is not required) validate the attributes of an incoming SOP instance. Personally, I have never encountered a DICOM system that had trouble with it, most systems just threat a UID as 64 bytes and are happy with it as long as it is unique.

Possible (performance) scenario
Large DICOM archives need to maintain a relational database to maintain which images are stored in the system. To ensure data integrity, these systems put often a constraint on the uniqueness of the SOP Instance UID column. Most DBMS systems will create a non-cluster index to ensure that this constraint can be met. A uuid is only 16 bytes, compared to a UID that is 64 bytes, which can make the difference of keeping the index in memory or not. Some DBMS systems have a native data type to support uuid columns. The complication is of course that these systems also need to support images with “Organizationally Derived” UIDs and this optimization only makes sense if a majority of UIDs are uuid derived UIDs.