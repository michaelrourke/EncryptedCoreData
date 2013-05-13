Encrypted Core Data
===================

Here are the code fragments I use for an iOS/OS X app called SamuraiSafe (a password safe manager) that implements encryption of every core data entity.

The atomic binary core data file may be present in iCloud, on the iOS or OS X device, so it is not a suitable candidate for iOS native encryption.

As every core data entity is individually encrypted, it is clearly not terribly space efficient - but how many passwords does a person have?

The user supplies a password string when he/she wishes to access the (Core Data) file. This is stretched using SHA384 (multiple rounds) to produce the key used for encryption/decryption.

Each entity is encrypted with AES with a 256 bit key, and includes a SHA1 HMAC to detect decryption failure (or data corruption).

Looking at the core data schema you will see that each entity contains a single persistent binary data attribute that contains the encrypted data, and all the working attributes are transient. *awakeFromFetch* decrypts each entity, when required, and *willSave* rebuilds the persistent data from the transient attributes.

Note that the *Password* entity is distinct from the *Entry* entity, so that the decryption of the password may be decoupled from the decryption of the entity. This minimises the presence of clear text passwords in the memory of the running application.

The *PasswordFile* class is a singleton representing the (single) open file and importantly maps the *managedObjectContext* to the appropriate open file. This is needed to supply the encryption key, and also to handle errors. This is easily extended for apps with multiple encrypted core data files open at a time.

Note that *PasswordFile* *ManagedDocument* and *Application* clases are basically stubs containing only the essential methods to demonstrate how to use the model classes.