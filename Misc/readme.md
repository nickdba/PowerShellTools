# Keepass

## Introduction

Contains various functions for the management of keepass via powershell.

## Requirements

| Requirement | Version |
|-------------|---------|
| KeePass     | 2.2+    |
| Powershell  | 4.0+    |

## How to use

First you will need to setup the environment for KeePass. This prevents you having to enter the master password all the time as it's stored in an encrypted format.

```powershell
    Set-KeepassEnvironment -EnvironmentName "devops" -KeepassDBPath "\\fileshare\database.kdbx" -KeePassMasterPassword "securepassword" -KeePassexePath "C:\Program Files (x86)\KeePass Password Safe 2"
```
This will save a file called `KeePassEnvironment.json` under the users profile folder.

Once the environment has been set up it can be used by other functions eg:

```powershell
    $kenv = Get-KeePassEnvironment
    Find-KeePassPassword -KeepassEnvironment $kenv -Title "testdatabse01"
```