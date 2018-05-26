Encrypted Core Data
===================

Here are the code fragments I use for an iOS/macOS app called [**SamuraiSafe**](http://samarama.net) (a password safe manager) that implements encryption of every core data entity.

The atomic binary core data file may be present in iCloud, on the iOS or macOS device, so it is not a suitable candidate for iOS native encryption.

As every core data entity is individually encrypted, it is clearly not space efficient. But how many passwords does a person have?

The user supplies a password string when he/she wishes to access the (Core Data) file. This is stretched using SHA384 (multiple rounds) to produce the 256 bit key used for encryption/decryption (some bits are discarded).

Each entity is encrypted with AES with a 256 bit key, and includes a SHA1 HMAC to detect decryption failure (or data corruption).

Looking at the core data schema you will see that each entity contains a single persistent binary data attribute that contains the encrypted data (gD eD or pD), and all the working attributes are transient. *awakeFromFetch* decrypts each entity, when required, and *willSave* rebuilds the persistent data from the transient attributes. (The names are purposely short as they are exposed in the binary core data file.)

![Core Data Entities](https://raw.githubusercontent.com/michaelrourke/EncryptedCoreData/master/CoreDataEntities.PNG)

Note that the *Password* entity is distinct from the *Entry* entity, so that the decryption of the password may be decoupled from the decryption of the entity. This minimises the presence of clear text passwords in the memory of the running application. This has also permitted easy implementation of a Password History feature (with an extended schema from the one presented here).

The *PasswordFile* class is a singleton representing the open file and importantly maps the *managedObjectContext* to the appropriate open file. This is needed to supply the encryption key, and also to handle errors. This is easily extended for apps with multiple encrypted core data files open at a time.

Note that *PasswordFile* *ManagedDocument* and *Application* classes are stubs containing only the essential methods to demonstrate how to use the model classes.

Michael
